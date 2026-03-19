import Testing
import Foundation
@testable import SparrowCLICore

@Suite("CLI Helpers")
struct CLIHelperTests {

    @Test("discoverExecutable finds executable target name from Package.swift")
    func discoverBasic() throws {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        try FileManager.default.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: tmpDir) }

        let packageSwift = """
        // swift-tools-version: 6.2
        import PackageDescription

        let package = Package(
            name: "MyApp",
            targets: [
                .executableTarget(name: "MyApp", path: "Sources"),
            ]
        )
        """
        try packageSwift.write(toFile: tmpDir + "/Package.swift", atomically: true, encoding: .utf8)

        let result = discoverExecutable(in: tmpDir)
        #expect(result == "MyApp")
    }

    @Test("discoverExecutable returns nil when no Package.swift exists")
    func discoverMissing() {
        let result = discoverExecutable(in: "/nonexistent/path")
        #expect(result == nil)
    }

    @Test("discoverExecutable returns nil when no executable target in Package.swift")
    func discoverNoExecutable() throws {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        try FileManager.default.createDirectory(atPath: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: tmpDir) }

        let packageSwift = """
        // swift-tools-version: 6.2
        import PackageDescription

        let package = Package(
            name: "MyLib",
            targets: [
                .target(name: "MyLib"),
            ]
        )
        """
        try packageSwift.write(toFile: tmpDir + "/Package.swift", atomically: true, encoding: .utf8)

        let result = discoverExecutable(in: tmpDir)
        #expect(result == nil)
    }
}
