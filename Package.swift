// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Sparrow",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Sparrow", targets: ["Sparrow"]),
        .executable(name: "sparrow", targets: ["SparrowCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "Sparrow",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
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
