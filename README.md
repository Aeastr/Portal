<div align="center">
  <img width="128" height="128" src="/Resources/icon/icon.png" alt="Portal Icon">
  <h1><b>Portal</b></h1>
  <p>
    Element transitions across navigation contexts, scroll-based flowing headers, and view mirroring for SwiftUI.
  </p>
</div>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.2+-F05138?logo=swift&logoColor=white" alt="Swift 6.2+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/iOS-17+-000000?logo=apple" alt="iOS 17+"></a>
  <a href="https://github.com/Aeastr/Portal/actions/workflows/build.yml"><img src="https://github.com/Aeastr/Portal/actions/workflows/build.yml/badge.svg" alt="Build"></a>
  <a href="https://github.com/Aeastr/Portal/actions/workflows/tests.yml"><img src="https://github.com/Aeastr/Portal/actions/workflows/tests.yml/badge.svg" alt="Tests"></a>
</p>

<div align="center">
  <img width="600" src="/Resources/examples/example1.gif" alt="Preview">
</div>


## Overview

Portal provides three modules for different use cases:

- **PortalTransitions** — Animate views between navigation contexts (sheets, navigation stacks, tabs) using a floating overlay layer. Uses standard SwiftUI APIs.
- **PortalHeaders** — Scroll-based header transitions that flow into the navigation bar, like Music or Photos. Uses iOS 18's advanced scroll tracking APIs.
- **_PortalPrivate** — True view mirroring using Apple's private `_UIPortalView` API. The view instance is shared rather than recreated.


## Requirements

- Swift 6.2+
- iOS 17+ (PortalTransitions)
- iOS 18+ (PortalHeaders)

> Targeting iOS 15/16? Pin to `v2.1.0` or the `legacy/ios15` branch.


## Installation

```swift
dependencies: [
    .package(url: "https://github.com/Aeastr/Portal.git", from: "4.0.0")
]
```

| Target | Description |
|--------|-------------|
| `PortalTransitions` | Element transitions (iOS 17+) |
| `PortalHeaders` | Flowing headers (iOS 18+) |
| `_PortalPrivate` | View mirroring with private API |


## Usage

### Element Transitions

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

### Flowing Headers

Scroll-based header transitions that flow into the navigation bar, like Music or Photos.

```swift
NavigationStack {
    ScrollView {
        PortalHeaderView()

        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .portalHeaderDestination()
}
.portalHeader(title: "Favorites", subtitle: "Your starred items")
```

### Private API Mirroring

> **WARNING: Private API Usage**
>
> This module uses Apple's private `_UIPortalView` API. Apps using private APIs **may be rejected by App Store Review**. Use at your own discretion. Portal, Aether, and any maintainers assume no responsibility for App Store rejections, app crashes, or any other issues arising from the use of this module.

Same API as PortalTransitions, but uses Apple's private `_UIPortalView` for true view mirroring instead of layer snapshots. The view instance is shared rather than recreated.

Class names are obfuscated at compile-time. See the [wiki](wiki/_PortalPrivate.md) for details.


## Customization

### Layer Configuration

Customize the animating layer with optional configuration closures:

```swift
// No config — frame/offset handled automatically
.portalTransition(item: $selectedBook) { book in
    Image("cover")
}

// Styling only — add clips, shadows, etc. (frame/offset still automatic)
.portalTransition(item: $selectedBook) { book in
    Image("cover")
} configuration: { content, isActive in
    content.clipShape(.rect(cornerRadius: isActive ? 0 : 12))
}

// Full control — you handle frame/offset (for custom modifier ordering)
.portalTransition(item: $selectedBook) { book in
    Image("cover")
} configuration: { content, isActive, size, position in
    content
        .frame(width: size.width, height: size.height)
        .clipShape(.rect(cornerRadius: isActive ? 0 : 12))
        .offset(x: position.x, y: position.y)
}
```


## How It Works

PortalTransitions creates a transparent `PassThroughWindow` that sits above your entire app UI. Source and destination views register their bounds via `PreferenceKey`. When a transition triggers, the view is rendered in this overlay window and animated between the two positions. The window uses a custom `hitTest` implementation that only captures touches on the animated layer itself—all other touches pass through to your app below, so interaction remains seamless during animations.

PortalHeaders tracks scroll position using iOS 18's `ScrollGeometry` and interpolates between inline and navigation bar states based on content offset thresholds.

_PortalPrivate wraps Apple's private `_UIPortalView` class, which creates a portal to another view's layer. Class names are obfuscated at compile-time to avoid detection. See [UIPortalBridge](https://github.com/Aeastr/UIPortalBridge) for a standalone wrapper.


## Examples

Each module includes working examples in `Sources/*/Examples/`:

| PortalTransitions | PortalHeaders | _PortalPrivate |
|:---|:---|:---|
| [Card Grid](Sources/PortalTransitions/Examples/PortalExampleCardGrid.swift) | [With Accessory](Sources/PortalHeaders/Examples/PortalHeaderExampleWithAccessory.swift) | [Card Grid](Sources/_PortalPrivate/Transitions/Examples/PortalPrivateExampleCardGrid.swift) |
| [List](Sources/PortalTransitions/Examples/PortalExampleList.swift) | [Title Only](Sources/PortalHeaders/Examples/PortalHeaderExampleTitleOnly.swift) | [List](Sources/_PortalPrivate/Transitions/Examples/PortalPrivateExampleList.swift) |
| [Grid Carousel](Sources/PortalTransitions/Examples/PortalExampleGridCarousel.swift) | [No Accessory](Sources/PortalHeaders/Examples/PortalHeaderExampleNoAccessory.swift) | [Comparison](Sources/_PortalPrivate/Transitions/Examples/PortalPrivateExampleComparison.swift) |


## Documentation

The **[Portal Wiki](https://github.com/Aeastr/Portal/wiki)** has full guides and API reference for each module.

The wiki is included at `/wiki` when you clone, so it's available offline.


## Contributing

Contributions welcome. See the [Contributing Guide](CONTRIBUTING.md) for details.


## License

MIT. See [LICENSE](LICENSE.md) for details.


## Related

- [UIPortalBridge](https://github.com/Aeastr/UIPortalBridge) - Standalone wrapper for `_UIPortalView`
- [Transmission](https://github.com/nathantannar4/Transmission) - UIKit-backed presentation and transitions for SwiftUI


## Contact

- [Twitter](https://x.com/AetherAurelia)
- [Threads](https://www.threads.net/@aetheraurelia)
- [Bluesky](https://bsky.app/profile/aethers.world)
- [LinkedIn](https://www.linkedin.com/in/willjones24)
