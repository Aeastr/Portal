// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Portal",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "PortalTransitions",
            targets: ["PortalTransitions"]),
        .library(
            name: "PortalHeaders",
            targets: ["PortalHeaders"]),
        .library(
            name: "_PortalMirror",
            targets: ["_PortalMirror"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Aeastr/LogOutLoud.git", from: "2.1.2"),
        .package(url: "https://github.com/Aeastr/Obfuscate.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "PortalTransitions",
            dependencies: [
                .product(name: "LogOutLoud", package: "LogOutLoud"),
                .product(name: "LogOutLoudConsole", package: "LogOutLoud")
            ],
            path: "Sources/PortalTransitions"
        ),
        .target(
            name: "PortalHeaders",
            dependencies: [
                .product(name: "LogOutLoud", package: "LogOutLoud"),
                .product(name: "LogOutLoudConsole", package: "LogOutLoud")
            ],
            path: "Sources/PortalHeaders"
        ),
        .target(
            name: "_PortalMirror",
            dependencies: [
                "PortalTransitions",
                .product(name: "Obfuscate", package: "Obfuscate")
            ],
            path: "Sources/_PortalMirror"
        ),
        .testTarget(
            name: "PortalHeadersTests",
            dependencies: ["PortalHeaders"],
            path: "Tests/PortalHeadersTests"
        ),
        .testTarget(
            name: "PortalTransitionsTests",
            dependencies: ["PortalTransitions"],
            path: "Tests/PortalTransitionsTests"
        ),
        .testTarget(
            name: "_PortalMirrorTests",
            dependencies: ["_PortalMirror"],
            path: "Tests/_PortalMirrorTests"
        ),
    ]
)
