// swift-tools-version:5.3

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
            type: .dynamic,
            targets: ["Comet"]
        )
    ],
    targets: [
        .target(
            name: "Comet"
        ),
        .testTarget(
            name: "CometTests",
            dependencies: ["Comet"]
        )
    ]
)
