<div align="center">
  <img width="200" height="200" src="/assets/icon.png" alt="Portal Logo">
  <h1><b>Portal</b></h1>
  <p>
    Portal is a SwiftUI package for seamless element transitions between views—including across sheets and navigation pushes (NavigationStack, .navigationDestination, etc)—using a portal metaphor for maximum flexibility.
    <br>
    <i>Compatible with iOS 17.0 and later*</i>
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17%2B-purple.svg" alt="iOS 17+"></a>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
</p>

<div align="center">
  <img width="600" src="/assets/example1.gif" alt="Portal Demo">
</div>

---

## Documentation

For full installation steps, usage guides, and examples, visit the [Portal Wiki](https://github.com/Aeastr/Portal/wiki):

> Targeting iOS 15/16? Pin your dependency to `v2.1.0` or the `legacy/ios15` branch.

### Package Targets

- **`Portal`** – Core transition system using standard SwiftUI APIs. Separate view instances allow different sizes at source/destination. **✅ App Store safe.**

- **`PortalPrivate`** – Portal transitions powered by view mirroring. Single shared instance with perfect state preservation but same-size constraint. **⚠️ Private API (obfuscated).**

- **`PortalView`** – Low-level `_UIPortalView` wrapper for direct UIKit integration. **⚠️ Private API (obfuscated).**

**For most users:** Just `import Portal`. The other targets are experimental and intended for advanced scenarios requiring view instance sharing.

---

## Features

- **Seamless Transitions**  
  Effortlessly animate floating overlays between source and destination views using simple view modifiers.

- **Works with Standard Presentations**  
  Fully compatible with SwiftUI’s built-in presentation methods like `.sheet` and `.navigationDestination`.

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

---

## Examples

Portal includes several sample projects to help you get started:

- [Static ID](Sources/Portal/Examples/PortalExample_StaticID.swift)
- [Card Grid](Sources/Portal/Examples/PortalExample_CardGrid.swift)
- [List](Sources/Portal/Examples/PortalExample_List.swift)
- [Comparison](Sources/Portal/Examples/PortalExample_Comparison.swift)

You can find these in the [`Sources/Portal/Examples`](Sources/Portal/Examples) directory, or visit the [Examples documentation](https://github.com/Aeastr/Portal/wiki/Examples) for more details.

---

## Contributing & Support

Contributions are welcome! Please feel free to submit a Pull Request. See the [Contributing Guide](CONTRIBUTING.md) for details.

This project is released under the [MIT License](LICENSE.md). If you like Portal, please give it a ⭐️

---

## Where to find me:  
- here, obviously.  
- [Twitter](https://x.com/AetherAurelia)  
- [Threads](https://www.threads.net/@aetheraurelia)  
- [Bluesky](https://bsky.app/profile/aethers.world)  
- [LinkedIn](https://www.linkedin.com/in/willjones24)

---

<p align="center">Built with 🍏🌀🚪 by Aether</p>
