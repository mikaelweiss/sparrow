import ArgumentParser
import Foundation

public struct Run: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Start the development server")

    @Option(name: .long, help: "Port to run on")
    var port: Int = 3000

    @Flag(name: .long, help: "Show verbose build output")
    var verbose: Bool = false

    public init() {}

    public func run() throws {
        print("  Starting Sparrow development server...")

        let cwd = FileManager.default.currentDirectoryPath

        print("  Building...")
        let buildArgs = verbose ? ["swift", "build", "--verbose"] : ["swift", "build"]
        let buildResult = shell(buildArgs, cwd: cwd)
        guard buildResult == 0 else {
            print("  Build failed.")
            throw ExitCode.failure
        }

        // Discover the executable target name from Package.swift
        let executableName = discoverExecutable(in: cwd) ?? "App"
        print("  Build succeeded. Starting \(executableName) on port \(port)...")

        let runResult = shell(["swift", "run", executableName], cwd: cwd)
        if runResult != 0 {
            print("  Server exited with error.")
            throw ExitCode.failure
        }
    }
}

public struct Build: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Build for production")

    public init() {}

    public func run() throws {
        print("  Building for production...")
        let cwd = FileManager.default.currentDirectoryPath
        let result = shell(["swift", "build", "-c", "release"], cwd: cwd)
        guard result == 0 else {
            print("  Build failed.")
            throw ExitCode.failure
        }
        print("  Build complete.")
    }
}

public struct New: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Create a new Sparrow project")

    @Argument(help: "Project name")
    var name: String

    public init() {}

    public func run() throws {
        print("  Creating new Sparrow project: \(name)")

        let fm = FileManager.default
        let projectDir = fm.currentDirectoryPath + "/\(name)"
        let sourcesDir = projectDir + "/Sources"

        try fm.createDirectory(atPath: sourcesDir, withIntermediateDirectories: true)

        // Package.swift
        let packageSwift = """
        // swift-tools-version: 6.2
        import PackageDescription

        let package = Package(
            name: "\(name)",
            platforms: [.macOS(.v15)],
            dependencies: [
                .package(url: "https://github.com/mikaelweiss/sparrow.git", branch: "main"),
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

        @main
        struct \(name): App {
            init() {}

            var routes: [Route] {
                Page("/") {
                    VStack(spacing: 16) {
                        Text("Welcome to \(name)")
                            .font(.largeTitle)
                        Text("Edit Sources/App.swift to get started.")
                            .foreground(.textSecondary)
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

        print("  Created \(name)/Package.swift")
        print("  Created \(name)/Sources/App.swift")
        print("  Created \(name)/.gitignore")
        print("")
        print("  Next steps:")
        print("    cd \(name)")
        print("    sparrow run  (or: kln run)")
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
