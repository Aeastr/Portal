# PortalPrivate

**⚠️ Note: This module uses private UIKit APIs via runtime introspection (obfuscated). Consider the implications for your use case.**

`PortalPrivate` reimplements Portal transitions using UIKit's portal view for true view instance sharing, providing perfect state preservation and single-render performance.

---

## Overview

PortalPrivate uses view mirroring to display the exact same view instance at both source and destination. Unlike standard Portal which creates separate views, PortalPrivate shows a live mirror of the original view using Apple's `_UIPortalView`.

## Technical Implementation

### Obfuscation Strategy

The module uses several techniques to access `_UIPortalView` safely:

1. **Compile-Time Macro Obfuscation** - Class names obfuscated using the [`#Obfuscate()`](https://github.com/Aeastr/Obfuscate) macro at compile-time
   - The macro converts string literals to base64-encoded byte arrays at compile-time
   - At runtime, the string is decoded from the byte array, preventing direct string matching in the binary
   - Uses Swift macros (freestanding expression macro) to perform the transformation during compilation
2. **Runtime Introspection** - Classes are resolved dynamically via `NSClassFromString()`
3. **Type Erasure** - Private API objects stored as generic `UIView` or `AnyObject` types
4. **Key-Value Coding** - Properties set using `setValue:forKey:` instead of direct access
5. **Graceful Fallback** - Automatic fallback when APIs unavailable
6. **No Compile-Time References** - No imports or direct symbols in binary

This approach provides the functionality while minimizing detection risk through obfuscation.

## Key Differences from Portal

| Feature | Portal | PortalPrivate |
|---------|--------|----------------|
| View Instances | Separate | Single shared |
| Size Flexibility | Different sizes | **Same size only** |
| State Preservation | Recreated | Perfect |
| Performance | Two renders | Single render |
| API Safety | App Store safe | Private API |

---

## API Reference

### Basic Setup

```swift
import PortalTransitions
import PortalTransitionsPrivate

struct ContentView: View {
    @State private var showDetail = false

    var body: some View {
        PortalContainer {
            // Source with AnimatedLayer
            AnimatedLayer(portalID: "myView") {
                MyComplexView()
                    .frame(width: 100, height: 100) // Set size here!
                    .portalPrivate(id: "myView")
            }

            // Trigger transition
            .portalPrivateTransition(
                id: "myView",
                isActive: $showDetail,
                animation: .spring(response: 0.4, dampingFraction: 0.8)
            )

            .sheet(isPresented: $showDetail) {
                // Destination - will be same size as source!
                PortalPrivateDestination(id: "myView")
            }
        }
    }
}
```

### Portal Source Modifiers

#### `.portalPrivate(id:)`
Basic portal with string ID:
```swift
MyView()
    .portalPrivate(id: "portal1")
```

#### `.portalPrivate(item:)`
Portal using an Identifiable item:
```swift
PhotoView(photo)
    .portalPrivate(item: photo)
```

#### With Group ID
For coordinated animations:
```swift
CardView()
    .portalPrivate(id: "card1", groupID: "stack")

PhotoView()
    .portalPrivate(item: photo, groupID: "gallery")
```

### Transition Modifiers

#### Single Portal
```swift
// Boolean state
.portalPrivateTransition(
    id: "myPortal",
    isActive: $showDetail,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
)

// Optional item
.portalPrivateTransition(
    item: $selectedPhoto,
    animation: .smooth(duration: 0.4)
)
```

#### Multiple Portals (Coordinated)
```swift
// Multiple IDs
.portalPrivateTransition(
    ids: ["portal1", "portal2", "portal3"],
    groupID: "group",
    isActive: $showAll,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
)

// Multiple items with stagger
.portalPrivateTransition(
    items: $selectedPhotos,
    groupID: "photoGrid",
    animation: .smooth(duration: 0.4),
    staggerDelay: 0.05
)
```

### Destination Views

```swift
// String ID
PortalPrivateDestination(id: "myPortal")

// Identifiable item
PortalPrivateDestination(item: photo)
```

---

## Critical Limitation: Same Size Only

**The most important thing to understand about PortalPrivate:**

Source and destination views are **always the same size**. This is because `_UIPortalView` mirrors the exact rendered pixels - it's not creating a new view, it's showing the same view in two places.

```swift
// Source - 100x100
AnimatedLayer(portalID: "demo") {
    MyView()
        .frame(width: 100, height: 100)
        .portalPrivate(id: "demo")
}

// Destination - will ALWAYS show as 100x100
PortalPrivateDestination(id: "demo")
    .frame(width: 500, height: 500) // ❌ This does NOTHING!
```

### Frame Modifier Placement

**Critical:** Apply frame modifiers **inside** AnimatedLayer **before** `.portalPrivate()`:

```swift
// ✅ CORRECT
AnimatedLayer(portalID: "view") {
    MyView()
        .frame(width: 100, height: 100) // Size set here
        .portalPrivate(id: "view")
}

// ❌ WRONG - May cause sizing issues
AnimatedLayer(portalID: "view") {
    MyView()
        .portalPrivate(id: "view")
}
.frame(width: 100, height: 100) // Outside frame may not work
```

---

## When to Use PortalPrivate

### ✅ Good Use Cases

- **List → Detail** transitions where items should look identical
- **Card stacks** moving between positions
- **Tab switching** with consistent content
- **Picture-in-picture** scenarios
- **Sidebars/panels** sliding in/out
- Any case where **same size is desired**

### ❌ When to Use Regular Portal Instead

- **Thumbnail → Fullscreen** transitions
- **Hero animations** needing size changes
- **Grid → Detail** with different layouts
- **App Store apps** (Portal is safe, PortalPrivate uses private API)
- Any case where **different sizes are needed**

---

## Complete Example

```swift
struct PhotoGrid: View {
    @State private var selectedPhoto: Photo?
    let photos: [Photo]

    var body: some View {
        PortalContainer {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100))]) {
                    ForEach(photos) { photo in
                        AnimatedLayer(portalID: "\(photo.id)") {
                            Image(photo.name)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .portalPrivate(item: photo)
                        }
                        .onTapGesture {
                            selectedPhoto = photo
                        }
                    }
                }
            }
            .sheet(item: $selectedPhoto) { photo in
                VStack {
                    // Shows at exactly 100x100 - same as source!
                    PortalPrivateDestination(item: photo)

                    Text(photo.caption)
                }
            }
            .portalPrivateTransition(
                item: $selectedPhoto,
                animation: .spring(response: 0.4, dampingFraction: 0.8)
            )
        }
    }
}
```

---

## Technical Implementation

PortalPrivate works by:

1. **Creating a UIHostingController** with your SwiftUI view
2. **Storing in SourceViewContainer** which manages the UIView
3. **Using _UIPortalView** to mirror that UIView at destination
4. **Same pixels** rendered in both locations (not a copy!)

This architecture is why size must be the same - you're literally seeing the same rendered view through a "portal".

---

## Migration from Portal

```swift
// Portal (before)
MyView()
    .portal(id: "view", .source)

Portal(id: "view", .destination) {
    MyView() // Separate instance
}

.portalTransition(
    id: "view",
    isActive: $show,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
) {
    MyView() // Third instance for animation
}

// PortalPrivate (after)
AnimatedLayer(portalID: "view") {
    MyView() // Only one instance!
        .portalPrivate(id: "view")
}

PortalPrivateDestination(id: "view") // Mirror of same instance

.portalPrivateTransition(
    id: "view",
    isActive: $show,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
)
// No layer view needed - uses the mirrored instance
```

---

## Examples

Full working examples are included:
- [Static ID](../Sources/PortalPrivate/Examples/PortalExample_StaticID.swift)
- [Card Grid](../Sources/PortalPrivate/Examples/PortalExample_CardGrid.swift)
- [List](../Sources/PortalPrivate/Examples/PortalExample_List.swift)
- [Comparison](../Sources/PortalPrivate/Examples/PortalExample_Comparison.swift)

---

## Related Documentation

- [PortalView](./PortalView) - Low-level `_UIPortalView` wrapper
- [Portal Usage](./Usage) - Standard Portal API
- [Debugging](./Debugging) - Debug overlays and logging
