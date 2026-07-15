// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Portal",
    platforms: [.iOS(.v15), .macOS("15.0")],
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
        .library(
            name: "PortalPrivate",
            targets: ["_PortalPrivate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Aeastr/Chronicle.git", from: "3.0.1")
    ],
    targets: [
        .target(
            name: "UIPortalBridge",
            dependencies: [],
            path: "Sources/UIPortalBridge"
        ),
        .target(
            name: "PortalTransitions",
            dependencies: [
                .product(name: "Chronicle", package: "Chronicle"),
                .product(name: "ChronicleConsole", package: "Chronicle")
            ],
            path: "Sources/PortalTransitions",
            exclude: ["Examples"]
        ),
        .target(
            name: "PortalHeaders",
            dependencies: [
                .product(name: "Chronicle", package: "Chronicle"),
                .product(name: "ChronicleConsole", package: "Chronicle")
            ],
            path: "Sources/PortalHeaders",
            exclude: ["Examples"]
        ),
        .target(
            name: "_PortalPrivate",
            dependencies: [
                "PortalTransitions",
                "UIPortalBridge"
            ],
            path: "Sources/_PortalPrivate",
            exclude: [
                "PortalPrivateExampleApp.swift",
                "PortalPrivateExampleNoSheetView.swift",
                "Transitions/Examples",
                "View/UIPortalViewExample.swift"
            ]
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
            dependencies: ["_PortalPrivate", "UIPortalBridge"],
            path: "Tests/_PortalPrivateTests"
        ),
    ]
)
