import ArgumentParser
import Dispatch
import Foundation

private func previewJsonOutput(_ dict: [String: Any]) {
    if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
       let str = String(data: data, encoding: .utf8) {
        print(str)
    }
}

private func previewJsonError(_ message: String, code: String = "error") {
    previewJsonOutput(["status": "error", "message": message, "code": code])
}

/// Starts the live preview server. Scans for `#Preview` blocks, builds a preview binary,
/// and serves interactive component previews with hot reload.
public struct Preview: ParsableCommand {
    public static let configuration = CommandConfiguration(
        abstract: "Start the live preview server"
    )

    @Option(name: .long, help: "Port to run on")
    var port: Int = 5457

    @Flag(name: .long, help: "Show verbose build output")
    var verbose: Bool = false

    @Flag(name: .long, help: "Structured JSON output (for tool integration)")
    var json: Bool = false

    @Flag(name: .long, help: "Don't open browser on start")
    var noBrowser: Bool = false

    @Flag(name: .long, help: "Run as LSP server (for editor integration)")
    var lsp: Bool = false

    public init() {}

    public func run() throws {
        // LSP mode: run preview server + speak LSP on stdin/stdout.
        // The editor starts this process and kills it when the workspace closes.
        if lsp {
            return try runWithLSP()
        }

        let cwd = FileManager.default.currentDirectoryPath
        let previewDir = cwd + "/.sparrow/preview"
        let url = "http://localhost:\(port)/_preview/"

        // 1. Scan for previews
        if !json { print("  Scanning for previews...") }
        let scanner = PreviewScanner(projectRoot: cwd)
        let entries = scanner.scan()

        if entries.isEmpty {
            if json {
                previewJsonError("No #Preview blocks found", code: "no_previews")
            } else {
                print("  No #Preview blocks found. Add a #Preview { ... } to your views.")
            }
            throw ExitCode.failure
        }

        if !json { print("  Found \(entries.count) preview(s) in \(Set(entries.map(\.filePath)).count) file(s)") }
        if json {
            previewJsonOutput([
                "status": "scanning",
                "message": "Found \(entries.count) previews in \(Set(entries.map(\.filePath)).count) files",
            ])
        }

        // 2. Generate preview binary sources
        if !json { print("  Generating preview binary...") }
        let generator = PreviewRegistryGenerator(
            entries: entries,
            outputDir: previewDir,
            projectRoot: cwd
        )
        do {
            try generator.generate()
        } catch {
            if json {
                previewJsonError("Failed to generate preview: \(error)", code: "generate_failed")
            } else {
                print("  Failed to generate preview binary: \(error)")
            }
            throw ExitCode.failure
        }

        // 3. Build the user's project first (macros expand here)
        if !json { print("  Building project...") }
        let userBuildArgs = verbose ? ["swift", "build", "--verbose"] : ["swift", "build"]
        let userBuildResult = shell(userBuildArgs, cwd: cwd)
        guard userBuildResult == 0 else {
            if json {
                previewJsonError("Project build failed", code: "build_failed")
            } else {
                print("  Project build failed.")
            }
            throw ExitCode.failure
        }

        // 4. Build the preview binary
        if !json { print("  Building preview server...") }
        let previewBuildArgs = verbose
            ? ["swift", "build", "--package-path", previewDir, "--verbose"]
            : ["swift", "build", "--package-path", previewDir]
        let previewBuildResult = shell(previewBuildArgs, cwd: cwd)
        guard previewBuildResult == 0 else {
            if json {
                previewJsonError("Preview build failed", code: "preview_build_failed")
            } else {
                print("  Preview build failed.")
            }
            throw ExitCode.failure
        }

        let binaryPath = previewDir + "/.build/debug/SparrowPreviewRunner"
        guard FileManager.default.fileExists(atPath: binaryPath) else {
            if json {
                previewJsonError("Preview binary not found", code: "binary_not_found")
            } else {
                print("  Preview binary not found at \(binaryPath)")
            }
            throw ExitCode.failure
        }

        if !json {
            print("  Build succeeded. Starting preview server on port \(port)...")
            print("  Watching for file changes...")
        }

        // 5. Launch the preview server
        var serverProcess: Process? = nil

        func launchServer() -> Process? {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: binaryPath)
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
            var env = ProcessInfo.processInfo.environment
            env["SPARROW_PREVIEW_PORT"] = "\(port)"
            process.environment = env
            try? process.run()
            return process
        }

        func killServer() {
            guard let process = serverProcess, process.isRunning else { return }
            let pid = process.processIdentifier
            process.terminate()
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                kill(pid, SIGKILL)
            }
            process.waitUntilExit()
        }

        serverProcess = launchServer()

        if json {
            previewJsonOutput([
                "status": "running",
                "url": url,
                "pid": serverProcess?.processIdentifier ?? -1,
            ])
        }

        // Open browser
        if !noBrowser && !json {
            shell(["open", url], cwd: cwd)
        }

        // 6. File watcher for hot reload
        let watcher = FileWatcher(path: cwd) {
            if !json { print("\n  File changed. Rebuilding...") }
            if json {
                previewJsonOutput(["status": "rebuilding"])
            }

            killServer()

            // Rescan previews (in case new ones were added or removed)
            let newEntries = scanner.scan()
            if !newEntries.isEmpty {
                let newGenerator = PreviewRegistryGenerator(
                    entries: newEntries,
                    outputDir: previewDir,
                    projectRoot: cwd
                )
                try? newGenerator.generate()
            }

            // Rebuild user project
            let userResult = shell(userBuildArgs, cwd: cwd)
            guard userResult == 0 else {
                if json {
                    previewJsonError("Build failed", code: "build_failed")
                } else {
                    print("  Build failed. Waiting for changes...")
                }
                return
            }

            // Rebuild preview binary
            let previewResult = shell(previewBuildArgs, cwd: cwd)
            guard previewResult == 0 else {
                if json {
                    previewJsonError("Preview build failed", code: "preview_build_failed")
                } else {
                    print("  Preview build failed. Waiting for changes...")
                }
                return
            }

            if !json { print("  Build succeeded. Restarting preview server...") }
            serverProcess = launchServer()

            if json {
                previewJsonOutput([
                    "status": "running",
                    "url": url,
                    "pid": serverProcess?.processIdentifier ?? -1,
                ])
            }
        }

        // 7. Signal handling
        let signalQueue = DispatchQueue(label: "sparrow.preview.signals")
        let interruptSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: signalQueue)
        let termSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: signalQueue)
        signal(SIGINT, SIG_IGN)
        signal(SIGTERM, SIG_IGN)

        interruptSource.setEventHandler {
            if !json { print("\n  Shutting down preview server...") }
            watcher.stop()
            killServer()
            Foundation.exit(0)
        }
        termSource.setEventHandler {
            watcher.stop()
            killServer()
            Foundation.exit(0)
        }
        interruptSource.resume()
        termSource.resume()

        watcher.start()
        CFRunLoopRun()
    }

    /// Run in LSP mode: start the preview server in a background thread,
    /// then handle LSP messages on stdin. When the LSP connection closes
    /// (editor kills us), everything shuts down automatically.
    private func runWithLSP() throws {
        let cwd = FileManager.default.currentDirectoryPath
        let previewDir = cwd + "/.sparrow/preview"

        // Do all the preview setup in the background so LSP can respond on the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            let scanner = PreviewScanner(projectRoot: cwd)
            let entries = scanner.scan()
            guard !entries.isEmpty else { return }

            let generator = PreviewRegistryGenerator(
                entries: entries,
                outputDir: previewDir,
                projectRoot: cwd
            )
            try? generator.generate()

            // Build user project
            let userBuildResult = shell(
                ["swift", "build"],
                cwd: cwd
            )
            guard userBuildResult == 0 else { return }

            // Build preview binary
            let previewBuildResult = shell(
                ["swift", "build", "--package-path", previewDir],
                cwd: cwd
            )
            guard previewBuildResult == 0 else { return }

            // Launch preview server
            let binaryPath = previewDir + "/.build/debug/SparrowPreviewRunner"
            guard FileManager.default.fileExists(atPath: binaryPath) else { return }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: binaryPath)
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
            var env = ProcessInfo.processInfo.environment
            env["SPARROW_PREVIEW_PORT"] = "\(self.port)"
            process.environment = env
            try? process.run()

            // Watch for file changes and rebuild
            let watcher = FileWatcher(path: cwd) {
                let newEntries = scanner.scan()
                if !newEntries.isEmpty {
                    let gen = PreviewRegistryGenerator(
                        entries: newEntries,
                        outputDir: previewDir,
                        projectRoot: cwd
                    )
                    try? gen.generate()
                }

                let _ = shell(["swift", "build"], cwd: cwd)
                let _ = shell(["swift", "build", "--package-path", previewDir], cwd: cwd)

                // Restart preview server
                if process.isRunning {
                    process.terminate()
                    process.waitUntilExit()
                }
                let newProcess = Process()
                newProcess.executableURL = URL(fileURLWithPath: binaryPath)
                newProcess.currentDirectoryURL = URL(fileURLWithPath: cwd)
                newProcess.environment = env
                try? newProcess.run()
            }
            watcher.start()
        }

        // Run LSP on the main thread (blocks until stdin closes or shutdown)
        let lspHandler = PreviewLSPHandler(previewPort: port)
        lspHandler.run()
    }
}
