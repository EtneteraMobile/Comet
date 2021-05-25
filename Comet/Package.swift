// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Comet",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Comet",
            targets: ["Comet"]
        )
    ],
    targets: [
        .target(
            name: "Comet",
            path: "Sources"
        ),
        .testTarget(
            name: "CometTests",
            dependencies: ["Comet"]
        )
    ]
)
