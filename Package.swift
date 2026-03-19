// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Sparrow",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Sparrow", targets: ["Sparrow"]),
        .library(name: "SparrowMarkdown", targets: ["SparrowMarkdown"]),
        .executable(name: "sparrow", targets: ["SparrowCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-websocket.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "SparrowMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),
        .target(
            name: "Sparrow",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdWebSocket", package: "hummingbird-websocket"),
                "SparrowMarkdown",
            ]
        ),
        .target(
            name: "SparrowCLICore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "SparrowCLI",
            dependencies: [
                "SparrowCLICore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "SparrowTests",
            dependencies: ["Sparrow"]
        ),
        .testTarget(
            name: "SparrowCLICoreTests",
            dependencies: ["SparrowCLICore"]
        ),
    ]
)
