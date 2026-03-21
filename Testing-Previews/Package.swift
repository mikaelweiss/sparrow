// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Testing-Previews",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "/Users/mikaelweiss/code/code-puppies/sparrow"),
    ],
    targets: [
        .executableTarget(
            name: "Testing-Previews",
            dependencies: [
                .product(name: "Sparrow", package: "sparrow"),
            ],
            path: "Sources"
        ),
    ]
)