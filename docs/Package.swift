// swift-tools-version: 6.2
import PackageDescription

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
                .product(name: "Sparrow", package: "sparrow"),
                .product(name: "SparrowMarkdown", package: "sparrow"),
            ],
            path: "Sources"
        ),
    ]
)
