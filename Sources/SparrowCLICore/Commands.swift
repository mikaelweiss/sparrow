import ArgumentParser
import Dispatch
import Foundation

private let devLocalPath = "/Users/mikaelweiss/code/code-puppies/sparrow"

// MARK: - JSON Output

private func jsonOutput(_ dict: [String: Any]) {
    if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
       let str = String(data: data, encoding: .utf8) {
        print(str)
    }
}

private func jsonError(_ message: String, code: String = "error") {
    jsonOutput(["status": "error", "message": message, "code": code])
}

public struct Serve: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Start the development server")

    @Option(name: .long, help: "Port to run on")
    var port: Int = 5456

    @Flag(name: .long, help: "Show verbose build output")
    var verbose: Bool = false

    @Flag(name: .long, help: "Structured JSON output (LLM mode)")
    var json: Bool = false

    @Flag(name: .long, help: "Don't open browser on start")
    var noBrowser: Bool = false

    public init() {}

    public func run() throws {
        if !json { print("  Starting Sparrow development server...") }

        let cwd = FileManager.default.currentDirectoryPath

        // Initial build
        if !json { print("  Building...") }
        let buildResult = build(cwd: cwd)
        guard buildResult == 0 else {
            if json {
                jsonError("Build failed", code: "build_failed")
            } else {
                print("  Build failed.")
            }
            throw ExitCode.failure
        }

        let executableName = discoverExecutable(in: cwd) ?? "App"
        let url = "http://localhost:\(port)"

        if !json {
            print("  Build succeeded. Starting \(executableName) on port \(port)...")
            print("  Watching for file changes...")
        }

        // Track the running server process
        var serverProcess: Process? = nil

        func launchServer() -> Process? {
            // Run the binary directly (not via `swift run`) so env vars propagate
            let binaryPath = cwd + "/.build/debug/" + executableName
            guard FileManager.default.fileExists(atPath: binaryPath) else {
                if json {
                    jsonError("Binary not found at \(binaryPath)", code: "binary_not_found")
                } else {
                    print("  Binary not found at \(binaryPath)")
                }
                return nil
            }
            let process = Process()
            process.executableURL = URL(fileURLWithPath: binaryPath)
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
            // Tell the framework we're in dev mode and give it a unique build ID
            var env = ProcessInfo.processInfo.environment
            env["SPARROW_DEV"] = "1"
            process.environment = env
            try? process.run()
            return process
        }

        func killServer() {
            guard let process = serverProcess, process.isRunning else { return }
            process.terminate()
            process.waitUntilExit()
        }

        // Launch initial server
        serverProcess = launchServer()

        if json {
            jsonOutput([
                "status": "running",
                "url": url,
                "pid": serverProcess?.processIdentifier ?? -1,
            ])
        }

        // Open browser (unless --no-browser or --json)
        if !noBrowser && !json {
            shell(["open", url], cwd: cwd)
        }

        // Set up file watcher
        let watcher = FileWatcher(path: cwd) {
            if !json { print("\n  File changed. Rebuilding...") }
            killServer()

            let result = build(cwd: cwd)
            if result == 0 {
                if !json { print("  Build succeeded. Restarting server...") }
                serverProcess = launchServer()
            } else {
                if json {
                    jsonError("Build failed", code: "build_failed")
                } else {
                    print("  Build failed. Waiting for changes...")
                }
                // Don't restart — wait for next file change
            }
        }

        // Forward SIGINT/SIGTERM to kill the server and exit
        // Use a dedicated queue — the main thread blocks during builds/kills,
        // which would prevent signal handlers on .main from firing.
        let signalQueue = DispatchQueue(label: "sparrow.signals")
        let interruptSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: signalQueue)
        let termSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: signalQueue)
        signal(SIGINT, SIG_IGN)
        signal(SIGTERM, SIG_IGN)

        interruptSource.setEventHandler {
            if !json { print("\n  Shutting down...") }
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

        // Start watching (schedules on current run loop)
        watcher.start()

        // Run the run loop to keep the process alive and receive FSEvents
        CFRunLoopRun()
    }

    private func build(cwd: String) -> Int32 {
        let args = verbose ? ["swift", "build", "--verbose"] : ["swift", "build"]
        return shell(args, cwd: cwd)
    }
}

public struct Build: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Build for production")

    @Flag(name: .long, help: "Structured JSON output (LLM mode)")
    var json: Bool = false

    public init() {}

    public func run() throws {
        if !json { print("  Building for production...") }
        let cwd = FileManager.default.currentDirectoryPath
        let result = shell(["swift", "build", "-c", "release"], cwd: cwd)
        guard result == 0 else {
            if json {
                jsonError("Build failed", code: "build_failed")
            } else {
                print("  Build failed.")
            }
            throw ExitCode.failure
        }

        let executableName = discoverExecutable(in: cwd) ?? "App"
        if json {
            jsonOutput([
                "status": "ok",
                "binary": ".build/release/\(executableName)",
                "assets": ".build/release/public/",
            ])
        } else {
            print("  Build complete.")
        }
    }
}

public struct New: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Create a new Sparrow project")

    @Argument(help: "Project name (will prompt if not provided)")
    var name: String?

    @Flag(name: .long, help: "Use local Sparrow checkout instead of GitHub (for development)")
    var local = false

    @Flag(name: .long, help: "Structured JSON output (LLM mode)")
    var json: Bool = false

    public init() {}

    public func run() throws {
        let name: String
        if let provided = self.name {
            name = provided
        } else if json {
            jsonError("Project name is required in JSON mode", code: "missing_name")
            throw ExitCode.failure
        } else {
            print("  Project name: ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces), !input.isEmpty else {
                print("  Error: project name is required.")
                throw ExitCode.failure
            }
            name = input
        }

        if !json { print("  Creating new Sparrow project: \(name)") }

        let fm = FileManager.default
        let projectDir = fm.currentDirectoryPath + "/\(name)"
        let sourcesDir = projectDir + "/Sources"

        try fm.createDirectory(atPath: sourcesDir, withIntermediateDirectories: true)

        // Package.swift
        let depLine: String
        if local {
            depLine = ".package(path: \"\(devLocalPath)\"),"
        } else {
            depLine = ".package(url: \"https://github.com/mikaelweiss/sparrow.git\", branch: \"main\"),"
        }

        let packageSwift = """
        // swift-tools-version: 6.2
        import PackageDescription

        let package = Package(
            name: "\(name)",
            platforms: [.macOS(.v15)],
            dependencies: [
                \(depLine)
            ],
            targets: [
                .executableTarget(
                    name: "\(name)",
                    dependencies: [
                        .product(name: "Sparrow", package: "sparrow"),
                    ],
                    path: "Sources"
                ),
            ]
        )
        """
        try packageSwift.write(toFile: projectDir + "/Package.swift", atomically: true, encoding: .utf8)

        // App.swift
        let appSwift = """
        import Sparrow

        struct Counter: View {
            @State var count = 0

            var body: some View {
                HStack(spacing: 16) {
                    Button("-") {
                        count -= 1
                    }
                    .clipShape(.circle)
                    Text("\\(count)")
                        .font(.title)
                    Button("+") {
                        count += 1
                    }
                    .clipShape(.circle)
                }
            }
        }

        struct Greeter: View {
            @State var name = ""

            var body: some View {
                VStack(spacing: 12) {
                    TextField("Your name", text: \\$name)
                    if !name.isEmpty {
                        Text("Hello, \\(name)!")
                            .font(.title2)
                    }
                }
            }
        }

        @main
        struct \(name): App {
            init() {}

            var routes: [Route] {
                Page("/") {
                    VStack(spacing: 24) {
                        Text("Welcome to \(name)")
                            .font(.largeTitle)
                        Greeter()
                        Counter()
                        Link("sparrowframework.dev", url: "https://sparrowframework.dev")
                    }
                    .padding(32)
                }
            }
        }
        """
        try appSwift.write(toFile: sourcesDir + "/App.swift", atomically: true, encoding: .utf8)

        // .gitignore
        let gitignore = """
        .build/
        Package.resolved
        .env
        .DS_Store
        """
        try gitignore.write(toFile: projectDir + "/.gitignore", atomically: true, encoding: .utf8)

        let createdFiles = ["\(name)/Package.swift", "\(name)/Sources/App.swift", "\(name)/.gitignore"]

        if !json {
            for file in createdFiles {
                print("  Created \(file)")
            }
            print("")

            // Ask about git initialization (skip in JSON mode — no interactive prompts)
            print("  Initialize git repository? [y/n] ", terminator: "")
            let gitAnswer = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
            if gitAnswer == "y" || gitAnswer == "yes" {
                shell(["git", "init"], cwd: projectDir)
                shell(["git", "add", "."], cwd: projectDir)
                shell(["git", "commit", "-m", "Initial Commit"], cwd: projectDir)
                print("  Initialized git repository.")
            }

            print("")
            print("  Next steps:")
            print("    cd \(name)")
            print("    sparrow serve  (or: kln serve)")
        } else {
            jsonOutput([
                "status": "ok",
                "path": "\(name)/",
                "files": createdFiles,
            ])
        }
    }
}

// MARK: - Helpers

@discardableResult
public func shell(_ args: [String], cwd: String) -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = args
    process.currentDirectoryURL = URL(fileURLWithPath: cwd)
    try? process.run()
    process.waitUntilExit()
    return process.terminationStatus
}

/// Runs a subprocess and forwards SIGINT/SIGTERM to it so Ctrl+C kills the child.
@discardableResult
public func shellWithSignalForwarding(_ args: [String], cwd: String) -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = args
    process.currentDirectoryURL = URL(fileURLWithPath: cwd)

    // Forward SIGINT and SIGTERM to the child process
    let interruptSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    let termSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)

    // Ignore default signal handling so we can handle it ourselves
    signal(SIGINT, SIG_IGN)
    signal(SIGTERM, SIG_IGN)

    interruptSource.setEventHandler {
        if process.isRunning { process.interrupt() }
    }
    termSource.setEventHandler {
        if process.isRunning { process.terminate() }
    }
    interruptSource.resume()
    termSource.resume()

    try? process.run()
    process.waitUntilExit()

    interruptSource.cancel()
    termSource.cancel()

    return process.terminationStatus
}

/// Discover the first executable target name from Package.swift.
public func discoverExecutable(in directory: String) -> String? {
    let packagePath = directory + "/Package.swift"
    guard let contents = try? String(contentsOfFile: packagePath, encoding: .utf8) else { return nil }

    let pattern = #"executableTarget\s*\(\s*name:\s*"(\w+)""#
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: contents, range: NSRange(contents.startIndex..., in: contents)),
          let range = Range(match.range(at: 1), in: contents) else { return nil }

    return String(contents[range])
}
