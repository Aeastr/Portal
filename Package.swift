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
            name: "_PortalPrivate",
            targets: ["_PortalPrivate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Aeastr/Chronicle.git", from: "3.0.1"),
        .package(url: "https://github.com/Aeastr/Obfuscate.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "PortalTransitions",
            dependencies: [
                .product(name: "Chronicle", package: "Chronicle"),
                .product(name: "ChronicleConsole", package: "Chronicle")
            ],
            path: "Sources/PortalTransitions"
        ),
        .target(
            name: "PortalHeaders",
            dependencies: [
                .product(name: "Chronicle", package: "Chronicle"),
                .product(name: "ChronicleConsole", package: "Chronicle")
            ],
            path: "Sources/PortalHeaders"
        ),
        .target(
            name: "_PortalPrivate",
            dependencies: [
                "PortalTransitions",
                .product(name: "Obfuscate", package: "Obfuscate")
            ],
            path: "Sources/_PortalPrivate"
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
            name: "_PortalPrivateTests",
            dependencies: ["_PortalPrivate"],
            path: "Tests/_PortalPrivateTests"
        ),
    ]
)
