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
        .library(
            name: "PortalFlowingHeader",
            targets: ["PortalFlowingHeader"]),
        .library(
            name: "PortalView",
            targets: ["PortalView"]),
        .library(
            name: "PortalPrivate",
            targets: ["PortalPrivate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Aeastr/LogOutLoud.git", from: "2.1.2"),
        .package(url: "https://github.com/Aeastr/Obfuscate.git", from: "1.0.0")
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
        .target(
            name: "PortalFlowingHeader",
            path: "Sources/PortalFlowingHeader"
        ),
        .target(
            name: "PortalView",
            dependencies: [
                .product(name: "Obfuscate", package: "Obfuscate")
            ],
            path: "Sources/PortalView"
        ),
        .target(
            name: "PortalPrivate",
            dependencies: [
                "Portal",
                "PortalView"
            ],
            path: "Sources/PortalPrivate"
        ),
        .testTarget(
            name: "PortalFlowingHeaderTests",
            dependencies: ["PortalFlowingHeader"],
            path: "Tests/PortalFlowingHeaderTests"
        ),
        .testTarget(
            name: "PortalViewTests",
            dependencies: ["PortalView"]
        ),
        .testTarget(
            name: "PortalPrivateTests",
            dependencies: ["Portal", "PortalView", "PortalPrivate"]
        ),
    ]
)
