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


## Features

- **Seamless Transitions**  
  Effortlessly animate floating overlays between source and destination views using simple view modifiers.

- **PortalFlowingHeader**  
  Smooth, scroll-based header transitions where content flows from the scroll view into the navigation bar. Perfect for polished, native-feeling iOS experiences. (iOS 18.0+)

- **Works with Standard Presentations**  
  Fully compatible with SwiftUI's built-in presentation methods like `.sheet` and `.navigationDestination`.

- **Flexible Anchoring**  
  Mark any view as a portal source or destination, keyed by static IDs or `Identifiable` items.

- **Easy Integration**  
  Install `PortalContainer` once at your root view and every sheet/navigation stack automatically gains portal support—no custom presentation code required.

- **Customizable Animations**  
  Fine-tune transitions with `PortalTransitionConfig` and drive bespoke transition layers via the `AnimatedPortalLayer` protocol.

- **Modern SwiftUI Support**  
  Built for iOS 17+ with the latest SwiftUI APIs and animation completion criteria

- **Debug Overlays**
  Visual indicators in DEBUG builds showing portal sources, destinations, and animation states. Zero overhead in Release builds.

- **Structured Logging**
  Built-in diagnostics via [LogOutLoud](https://github.com/Aeastr/LogOutLoud) integration. See the [Debugging Guide](https://github.com/Aeastr/Portal/wiki/Debugging) for details.
  
## Package Targets

- **`Portal`** – Core transition system using standard SwiftUI APIs. Separate view instances allow different sizes at source/destination.

- **`PortalFlowingHeader`** – Scroll-based header transitions that flow into the navigation bar. Smooth, native-feeling animations for polished iOS experiences. (iOS 18.0+) 

- **`PortalPrivate`** – Portal transitions powered by view mirroring. Single shared instance with perfect state preservation but same-size constraint. (⚠️ Obfuscated Private API)

- **`PortalView`** – Low-level `_UIPortalView` wrapper for direct UIKit integration.  (⚠️ Obfuscated Private API)


## Examples

Each target includes example implementations:

| **Portal** | **PortalPrivate** | **PortalView** |
|:---|:---|:---|
| [Static ID](Sources/Portal/Examples/PortalExample_StaticID.swift) | [Static ID](Sources/PortalPrivate/Examples/PortalExample_StaticID.swift) | [UIPortalView Example](Sources/PortalView/UIPortalViewExample.swift) |
| [Card Grid](Sources/Portal/Examples/PortalExample_CardGrid.swift) | [Card Grid](Sources/PortalPrivate/Examples/PortalExample_CardGrid.swift) | |
| [List](Sources/Portal/Examples/PortalExample_List.swift) | [List](Sources/PortalPrivate/Examples/PortalExample_List.swift) | |
| [Comparison](Sources/Portal/Examples/PortalExample_Comparison.swift) | [Comparison](Sources/PortalPrivate/Examples/PortalExample_Comparison.swift) | |

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
