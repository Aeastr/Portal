// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Portal",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Portal",
            targets: ["Portal"]),
        .library(
            name: "PortalFlowingHeader",
            targets: ["PortalFlowingHeader"]),
    ],
    targets: [
        .target(
            name: "Portal",
            path: "Sources/Portal"
        ),
        .target(
            name: "PortalFlowingHeader",
            path: "Sources/PortalFlowingHeader"
        ),
        .testTarget(
            name: "PortalTests",
            dependencies: ["Portal"]
        ),
    ]
)
