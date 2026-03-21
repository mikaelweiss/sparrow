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

@Suite("Swift Type Name Validation")
struct SwiftTypeNameTests {

    @Test("valid names")
    func validNames() {
        #expect(isValidSwiftTypeName("MyApp"))
        #expect(isValidSwiftTypeName("TodoList"))
        #expect(isValidSwiftTypeName("WeatherTracker"))
        #expect(isValidSwiftTypeName("App2"))
        #expect(isValidSwiftTypeName("_Private"))
        #expect(isValidSwiftTypeName("a"))
    }

    @Test("rejects empty string")
    func rejectsEmpty() {
        #expect(!isValidSwiftTypeName(""))
    }

    @Test("rejects names starting with a digit")
    func rejectsLeadingDigit() {
        #expect(!isValidSwiftTypeName("2Cool"))
        #expect(!isValidSwiftTypeName("123"))
    }

    @Test("rejects names with spaces or special characters")
    func rejectsSpecialChars() {
        #expect(!isValidSwiftTypeName("My App"))
        #expect(!isValidSwiftTypeName("my-app"))
        #expect(!isValidSwiftTypeName("my.app"))
        #expect(!isValidSwiftTypeName("my/app"))
        #expect(!isValidSwiftTypeName("hello!"))
    }

    @Test("rejects Swift keywords")
    func rejectsKeywords() {
        #expect(!isValidSwiftTypeName("class"))
        #expect(!isValidSwiftTypeName("struct"))
        #expect(!isValidSwiftTypeName("import"))
        #expect(!isValidSwiftTypeName("var"))
        #expect(!isValidSwiftTypeName("true"))
        #expect(!isValidSwiftTypeName("nil"))
        #expect(!isValidSwiftTypeName("Self"))
    }
}
