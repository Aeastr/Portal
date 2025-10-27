<div align="center">
  <img width="200" height="200" src="/Resources/icon/icon.png" alt="Portal Logo">
  <h1><b>Portal</b></h1>
  <p>
    Advanced element transitions across navigation contexts, scroll-based flowing headers, and advanced view mirroring capabilities.
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17%2B-purple.svg" alt="iOS 17+"></a>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
  <a href="https://github.com/Aeastr/Portal/actions/workflows/build.yml"><img src="https://github.com/Aeastr/Portal/actions/workflows/build.yml/badge.svg" alt="Build"></a>
  <a href="https://github.com/Aeastr/Portal/actions/workflows/tests.yml"><img src="https://github.com/Aeastr/Portal/actions/workflows/tests.yml/badge.svg" alt="Tests"></a>
</p>

<div align="center">
  <img width="600" src="/Resources/examples/example1.gif" alt="Portal Demo">
</div>


## Installation

Add Portal to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/Aeastr/Portal", from: "4.0.0")
]
```

> Targeting iOS 15/16? Pin your dependency to `v2.1.0` or the `legacy/ios15` branch.

## Documentation & Wiki

The [Portal Wiki](https://github.com/Aeastr/Portal/wiki) has the detailed docs - full API references, guides, and explanations.

The wiki is included as a git submodule at `/wiki`, so you get all the docs when you clone. Great for offline reference and LLMs.


## What's Included

Portal provides three main capabilities:

### 🎯 Element Transitions (`PortalTransitions`)
Animate views between navigation contexts (sheets, navigation stacks, tabs) with floating overlays.
- Simple `.portalSource()` / `.portalDestination()` modifiers
- Works with standard SwiftUI presentations (`.sheet`, `.navigationDestination`)
- Flexible keying by static IDs or `Identifiable` items
- Customizable animations via `AnimatedPortalLayer` protocol
- **iOS 17+** • Standard SwiftUI APIs

### 📱 Flowing Headers (`PortalHeaders`)
Scroll-based header transitions that smoothly flow into the navigation bar.
- Titles and accessories animate to navigation bar on scroll
- Native iOS-feeling transitions with automatic snapping
- Configurable snapping behavior (directional, nearest, none)
- Visual debug overlays and structured logging
- **iOS 18+** • Advanced scroll tracking APIs

### 🔮 View Mirroring (`_PortalMirror`)
Advanced view mirroring using `_UIPortalView` for perfect state preservation.
- Single shared view instance (same size at source/destination)
- Direct UIKit integration available via low-level `PortalView`
- **⚠️ Private API** • Obfuscated for App Store compliance

## Key Features

✅ **One-time setup** – Install `PortalContainer` at your root, every presentation gains portal support
✅ **Debug overlays** – Visual indicators in DEBUG builds, zero overhead in Release
✅ **Structured logging** – Built-in diagnostics via [LogOutLoud](https://github.com/Aeastr/LogOutLoud)
✅ **Modern SwiftUI** – Built for iOS 17+ with latest APIs and animation completion criteria


## Examples

Each target includes example implementations:

| **PortalTransitions** | **_PortalMirror** | **PortalHeaders** |
|:---|:---|:---|
| [Static ID](Sources/PortalTransitions/Examples/PortalExample_StaticID.swift) | [Static ID](Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleStaticID.swift) | [No Accessory](Sources/PortalHeaders/Examples/PortalHeaderExampleNoAccessory.swift) |
| [Card Grid](Sources/PortalTransitions/Examples/PortalExample_CardGrid.swift) | [Card Grid](Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleCardGrid.swift) | [Title Only](Sources/PortalHeaders/Examples/PortalHeaderExampleTitleOnly.swift) |
| [List](Sources/PortalTransitions/Examples/PortalExample_List.swift) | [List](Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleList.swift) | [With Accessory](Sources/PortalHeaders/Examples/PortalHeaderExampleWithAccessory.swift) |
| [Comparison](Sources/PortalTransitions/Examples/PortalExample_Comparison.swift) | [Comparison](Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleComparison.swift) | |

## Contributing & Support

Contributions are welcome! Please feel free to submit a Pull Request. See the [Contributing Guide](CONTRIBUTING.md) for details.

This project is released under the [MIT License](LICENSE.md). If you like Portal, please give it a ⭐️.

## Where to find me:  
- here, obviously.  
- [Twitter](https://x.com/AetherAurelia)  
- [Threads](https://www.threads.net/@aetheraurelia)  
- [Bluesky](https://bsky.app/profile/aethers.world)  
- [LinkedIn](https://www.linkedin.com/in/willjones24)

<p align="center">Built with 🍏🌀🚪 by Aether</p>
