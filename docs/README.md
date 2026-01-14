# Portal Documentation

Element transitions across navigation contexts, scroll-based flowing headers, and view mirroring for SwiftUI.

## Modules

Portal is split into three independent modules. Import only what you need.

### PortalTransitions

Animate views between navigation contexts — sheets, navigation stacks, tabs — using a floating overlay layer.

- **iOS 17+**
- Uses standard SwiftUI APIs
- Safe for App Store

Start with [Basic Usage](PortalTransitions/BasicUsage.md) to set up your first transition.

### PortalHeaders

Scroll-based header transitions that flow into the navigation bar, similar to Music or Photos.

- **iOS 18+**
- Uses advanced scroll tracking APIs
- Safe for App Store

Start with [Basic Usage](PortalHeaders/BasicUsage.md) to create a flowing header.

### _PortalPrivate

Same API as PortalTransitions, but uses Apple's private `_UIPortalView` for true view mirroring instead of layer snapshots.

- **iOS 17+**
- Uses private UIKit API (obfuscated)
- **May be rejected by App Store Review**

See [Overview](PortalPrivate.md) for usage and important disclaimers.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/Aeastr/Portal", from: "4.0.0")
]
```

Then import the module you need:

```swift
import PortalTransitions  // Element transitions
import PortalHeaders      // Flowing headers
import _PortalPrivate     // View mirroring (private API)
```

## Quick Links

- [How Portal Transitions Work](PortalTransitions/HowItWorks.md)
- [Animation Options](PortalTransitions/AnimationOptions.md)
- [Group Animations](PortalTransitions/GroupAnimations.md)
- [Header Snapping Behavior](PortalHeaders/SnappingBehavior.md)

## Contents

### PortalTransitions

#### Getting Started
- [Basic Usage](PortalTransitions/BasicUsage.md)
- [How It Works](PortalTransitions/HowItWorks.md)

#### Customization
- [Animation Options](PortalTransitions/AnimationOptions.md)
- [Animated Layers](PortalTransitions/AnimatedLayers.md)
- [Item-Based Animated Layers](PortalTransitions/ItemBasedAnimatedLayers.md)

#### Advanced
- [Transferring Portals](PortalTransitions/TransferringPortals.md)
- [Group Animations](PortalTransitions/GroupAnimations.md)

#### Development
- [Debug Overlays](PortalTransitions/DebugOverlays.md)

### PortalHeaders

#### Getting Started
- [Basic Usage](PortalHeaders/BasicUsage.md)

#### Customization
- [Snapping Behavior](PortalHeaders/SnappingBehavior.md)

#### Development
- [Debug Overlays](PortalHeaders/DebugOverlays.md)

### _PortalPrivate

- [Overview](PortalPrivate.md)
