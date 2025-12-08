<div align="center">
  <img width="200" height="200" src="/Resources/icon/icon.png" alt="Portal Logo">
  <h1><b>Portal</b></h1>
  <p>
    Element transitions across navigation contexts, scroll-based flowing headers, and view mirroring for SwiftUI.
  </p>
</div>

<p align="center">
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-17%2B-purple.svg" alt="iOS 17+"></a>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-6.2-orange.svg" alt="Swift 6.2"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></a>
  <a href="https://github.com/Aeastr/Portal/actions/workflows/build.yml"><img src="https://github.com/Aeastr/Portal/actions/workflows/build.yml/badge.svg" alt="Build"></a>
  <a href="https://github.com/Aeastr/Portal/actions/workflows/tests.yml"><img src="https://github.com/Aeastr/Portal/actions/workflows/tests.yml/badge.svg" alt="Tests"></a>
</p>

<div align="center">
  <img width="600" src="/Resources/examples/example1.gif" alt="Portal Demo">
</div>


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/Aeastr/Portal", from: "4.0.0")
]
```

Then import the module you need:

```swift
import PortalTransitions  // Element transitions (iOS 17+)
import PortalHeaders      // Flowing headers (iOS 18+)
import _PortalPrivate     // View mirroring with private API
```

> Targeting iOS 15/16? Pin to `v2.1.0` or the `legacy/ios15` branch.


## Modules

### PortalTransitions

Animate views between navigation contexts — sheets, navigation stacks, tabs — using a floating overlay layer.

```swift
// 1. Wrap your app in PortalContainer
PortalContainer {
    ContentView()
}

// 2. Mark the source view
Image("cover")
    .portal(id: "book", .source)

// 3. Mark the destination view
Image("cover")
    .portal(id: "book", .destination)

// 4. Apply the transition
.fullScreenCover(item: $selectedBook) { book in
    BookDetail(book: book)
}
.portalTransition(item: $selectedBook)
```

The view animates smoothly from source to destination when the cover presents, and back when it dismisses.

**iOS 17+** · Uses standard SwiftUI APIs

---

### PortalHeaders

Scroll-based header transitions that flow into the navigation bar, like Music or Photos.

```swift
NavigationStack {
    ScrollView {
        PortalHeaderView()

        // Your content
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .portalHeaderDestination()
}
.portalHeader(title: "Favorites", subtitle: "Your starred items")
```

As the user scrolls, the title transitions from inline to the navigation bar with configurable snapping behavior.

**iOS 18+** · Uses advanced scroll tracking APIs

---

### _PortalPrivate

> **WARNING: Private API Usage**
>
> This module uses Apple's private `_UIPortalView` API. Apps using private APIs **may be rejected by App Store Review**. Use at your own discretion. Portal, Aether, and any maintainers assume no responsibility for App Store rejections, app crashes, or any other issues arising from the use of this module. By importing `_PortalPrivate`, you accept full responsibility for any consequences.

Same API as PortalTransitions, but uses Apple's private `_UIPortalView` for true view mirroring instead of layer snapshots. The view instance is shared rather than recreated.

Class names are obfuscated at compile-time. See the [wiki](wiki/_PortalPrivate.md) for details.


## Documentation

The **[Portal Wiki](https://github.com/Aeastr/Portal/wiki)** has full guides and API reference for each module.

The wiki is included at `/wiki` when you clone, so it's available offline.


## Examples

Each module includes working examples in `Sources/*/Examples/`:

| PortalTransitions | PortalHeaders | _PortalPrivate |
|:---|:---|:---|
| [Card Grid](Sources/PortalTransitions/Examples/PortalExampleCardGrid.swift) | [With Accessory](Sources/PortalHeaders/Examples/PortalHeaderExampleWithAccessory.swift) | [Card Grid](Sources/_PortalPrivate/Transitions/Examples/PortalPrivateExampleCardGrid.swift) |
| [List](Sources/PortalTransitions/Examples/PortalExampleList.swift) | [Title Only](Sources/PortalHeaders/Examples/PortalHeaderExampleTitleOnly.swift) | [List](Sources/_PortalPrivate/Transitions/Examples/PortalPrivateExampleList.swift) |
| [Grid Carousel](Sources/PortalTransitions/Examples/PortalExampleGridCarousel.swift) | [No Accessory](Sources/PortalHeaders/Examples/PortalHeaderExampleNoAccessory.swift) | [Comparison](Sources/_PortalPrivate/Transitions/Examples/PortalPrivateExampleComparison.swift) |


## Contributing

Contributions welcome. See the [Contributing Guide](CONTRIBUTING.md) for details.

Released under the [MIT License](LICENSE.md).


## Contact

- [Twitter](https://x.com/AetherAurelia)
- [Threads](https://www.threads.net/@aetheraurelia)
- [Bluesky](https://bsky.app/profile/aethers.world)
- [LinkedIn](https://www.linkedin.com/in/willjones24)

<p align="center">Built with 🍏🌀🚪 by Aether</p>
