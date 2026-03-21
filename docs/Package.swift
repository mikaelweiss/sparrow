// swift-tools-version: 6.2
import PackageDescription
import Foundation

// Derive parent package identity from directory name so this works in any worktree
let parentPackage = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .lastPathComponent
    .lowercased()

let package = Package(
    name: "SparrowDocs",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "SparrowDocs",
            dependencies: [
                .product(name: "Sparrow", package: parentPackage),
            ],
            path: "Sources"
        ),
    ]
)
