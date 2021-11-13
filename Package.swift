// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FigSwiftArgumentParser",
    products: [
        .library(
            name: "FigSchema",
            targets: ["FigSchema"]
        ),
        .library(
            name: "FigSwiftArgumentParser",
            targets: ["FigSwiftArgumentParser"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FigUtils"
        ),
        .target(
            name: "FigSchema",
            dependencies: ["FigUtils"]
        ),
        .target(
            name: "FigSwiftArgumentParser",
            dependencies: [
                "FigUtils",
                "FigSchema",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "FigSchemaTests",
            dependencies: [
                "FigSchema",
            ]
        ),
        .testTarget(
            name: "FigSwiftArgumentParserTests",
            dependencies: [
                "FigSwiftArgumentParser",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
