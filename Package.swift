// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Portal",
    platforms: [.iOS(.v15)/*, .macOS(.v13)*/],
    products: [
        .library(
            name: "Portal",
            targets: ["Portal"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Aeastr/LogOutLoud", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "Portal",
            dependencies: [
                "LogOutLoud"
            ]
            , path: "Sources/Portal"
        ),
        .testTarget(
            name: "PortalTests",
            dependencies: ["Portal"]
        ),
    ]
)
