// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Portal",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Portal",
            targets: ["Portal"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Aeastr/LogOutLoud.git", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "Portal",
            dependencies: [
                .product(name: "LogOutLoud", package: "LogOutLoud"),
                .product(name: "LogOutLoudConsole", package: "LogOutLoud")
            ],
            path: "Sources/Portal"
        ),
        .testTarget(
            name: "PortalTests",
            dependencies: ["Portal"]
        ),
    ]
)
