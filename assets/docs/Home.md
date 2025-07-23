# Portal

**Portal** is a SwiftUI package for seamless element transitions between views—including across sheets and navigation pushes (`NavigationStack`, `.navigationDestination`, etc)—using a portal metaphor for maximum flexibility.

- **Effortless transitions:** Move elements smoothly between views, even across navigation boundaries.
- **Flexible:** Works with sheets, navigation stacks, and custom containers.
- **Modern:** Built for SwiftUI, compatible with iOS 15.0 and later.
- **iOS 17 Optimized:** Takes advantage of modern SwiftUI features like Environment values and completion criteria.

---

## 🚀 Key Features

- **`PortalContainer { ... }`** - Manages the overlay window logic required for floating portal animations across hierarchies.
- **`.portalContainer()`** - View extension for easily wrapping any view hierarchy in a `PortalContainer`.
- **`.portal(id:, .source/.destination)`** - Mark views as source or destination anchors using string IDs.
- **`.portal(item:, .source/.destination)`** - Mark views using `Identifiable` items.
- **`.portalTransition(id: isActive: ...)` & `.portalTransition(item: ...)`** - Drive transitions with boolean bindings or optional `Identifiable` items.
- **`PortalTransitionConfig`** - Comprehensive configuration for animations, timing, and corner styling.
- **iOS 15+ Compatible** - Maintains backward compatibility with fallback implementations.

---

## 🚀 Get Started

- [How to Install](./How-to-Install)
- [Usage](./Usage)
- [Examples](./Examples)
- [How Portal Works](./How-Portal-Works)
- [Animations](./Animations)

---

## Why Portal?

Traditional SwiftUI transitions are limited to a single view hierarchy. **Portal** enables element transitions between views across different hierarchies, maintaining visual continuity.

- **Clean SwiftUI integration:** Uses standard SwiftUI patterns and conventions.
- **Cross-hierarchy support:** Works across sheets, navigation, and any view boundaries.
- **Flexible API:** Supports both static IDs and dynamic `Identifiable` items.

---

## Explore More

- [How to Install](./How-to-Install): Add Portal to your project.
- [Usage](./Usage): Core concepts and API.
- [Examples](./Examples): Real-world patterns and inspiration.
- [Animations](./Animations): Customizing transition animations and timing.

---

**Portal** provides cross-hierarchy element transitions for SwiftUI applications.
Questions, ideas, or want to contribute? [Open an issue](https://github.com/aeastr/portal/issues) or join the discussion!