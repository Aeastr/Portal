# _PortalMirror

**⚠️ Warning: This module uses private UIKit APIs. Consider the implications for your use case.**

`_PortalMirror` provides advanced view mirroring using Apple's private `_UIPortalView` for perfect state preservation and true instance sharing. The module includes both low-level view primitives and high-level Portal-style transitions.

---

## What's Included

The `_PortalMirror` module provides two complementary APIs:

### 🔮 View Primitives (PortalView)
Low-level SwiftUI wrapper for `_UIPortalView` - direct control over view mirroring.

### 🎯 Portal Transitions (PortalPrivate)
High-level transition API using `_UIPortalView` for perfect state preservation - same API as `PortalTransitions` but with view mirroring.

---

## What is _UIPortalView?

`_UIPortalView` is a private UIKit class that creates a "portal" to another view. Unlike copying or recreating a view, a portal shows the **exact same view instance** in multiple places. Changes to the source view (animations, transforms, content updates) are instantly reflected in all portal instances.

### Key Capabilities

- **True instance sharing** - Portal views are not copies; they're windows into the same view
- **Synchronized state** - Animations, transforms, and content updates appear in all portals simultaneously
- **Performance** - No need to redraw or recreate view hierarchies
- **Flexible positioning** - Each portal can be positioned and sized independently

### Technical Implementation

The module uses several techniques to access `_UIPortalView` safely:

1. **Compile-Time Macro Obfuscation** - Class names obfuscated using the [`#Obfuscate()`](https://github.com/Aeastr/Obfuscate) macro
   - The macro converts string literals to base64-encoded byte arrays at compile-time
   - At runtime, the string is decoded from the byte array, preventing direct string matching in the binary
   - Uses Swift macros (freestanding expression macro) to perform the transformation during compilation
2. **Runtime Introspection** - Classes are resolved dynamically via `NSClassFromString()`
3. **Type Erasure** - Private API objects stored as generic `UIView` or `AnyObject` types
4. **Key-Value Coding** - Properties set using `setValue:forKey:` instead of direct access
5. **Graceful Fallback** - Automatic fallback when APIs unavailable
6. **No Compile-Time References** - No imports or direct symbols in binary

This approach provides the functionality while minimizing detection risk through obfuscation.

---

## Installation

Add `_PortalMirror` as a target dependency:

```swift
.package(url: "https://github.com/Aeastr/Portal.git", from: "5.0.0")
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "_PortalMirror", package: "Portal")
    ]
)
```

Then import it:

```swift
import _PortalMirror
```

---

# Part 1: Low-Level View Primitives (PortalView)

Use these when you need direct control over view mirroring.

## Basic Usage

### 1. Create a Source Container

Wrap your SwiftUI view in a `SourceViewContainer`:

```swift
@State private var sourceContainer: SourceViewContainer<AnyView>?

var body: some View {
    VStack {
        // Create source container once
        Color.clear
            .onAppear {
                sourceContainer = SourceViewContainer(
                    content: AnyView(myContentView)
                )
            }
    }
}
```

### 2. Display the Source View

```swift
if let container = sourceContainer {
    SourceViewRepresentable(
        container: container,
        content: AnyView(myContentView)
    )
    .frame(width: 200, height: 200)
}
```

### 3. Create Portal Instances

```swift
if let container = sourceContainer {
    PortalView(
        source: container,
        hidesSource: false,      // Keep source visible
        matchesPosition: false    // Independent positioning
    )
    .frame(width: 100, height: 100)
}
```

## Complete PortalView Example

```swift
import SwiftUI
import _PortalMirror

struct ContentView: View {
    @State private var sourceContainer: SourceViewContainer<AnyView>?
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            // Source view
            if let container = sourceContainer {
                SourceViewRepresentable(
                    container: container,
                    content: AnyView(animatedContent)
                )
                .frame(width: 150, height: 150)
            }

            // Portal view - shows same instance
            if let container = sourceContainer {
                PortalView(source: container)
                    .frame(width: 100, height: 100)
            }

            // Controls affect both
            Button("Rotate") {
                withAnimation {
                    rotation += 45
                }
            }
        }
        .onAppear {
            sourceContainer = SourceViewContainer(
                content: AnyView(animatedContent)
            )
        }
    }

    var animatedContent: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 50))
            .foregroundColor(.yellow)
            .rotationEffect(.degrees(rotation))
    }
}
```

## PortalView API Reference

### `SourceViewContainer<Content: View>`

Container that wraps a SwiftUI view in a `UIHostingController` for portaling.

```swift
init(content: Content)
func update(content: Content)
var view: UIView { get }
```

### `PortalView<Content: View>`

SwiftUI view that displays a portal of the source view.

```swift
init(
    source: SourceViewContainer<Content>,
    hidesSource: Bool = false,
    matchesAlpha: Bool = true,
    matchesTransform: Bool = true,
    matchesPosition: Bool = true
)
```

**Parameters:**
- `hidesSource` - Hides the original source view (useful for transitions)
- `matchesAlpha` - Portal opacity matches source
- `matchesTransform` - Portal transform matches source
- `matchesPosition` - Portal position matches source (usually `false` for independent positioning)

### `SourceViewRepresentable<Content: View>`

UIViewRepresentable that displays the source view.

```swift
init(
    container: SourceViewContainer<Content>,
    content: Content
)
```

---

# Part 2: High-Level Transitions (PortalPrivate)

Use these when you want Portal-style transitions with view mirroring.

## Overview

PortalPrivate reimplements Portal transitions using UIKit's portal view for true view instance sharing, providing perfect state preservation and single-render performance.

## Key Differences from PortalTransitions

| Feature | PortalTransitions | PortalPrivate (_PortalMirror) |
|---------|--------|----------------|
| View Instances | Separate | Single shared |
| Size Flexibility | Different sizes | **Same size only** |
| State Preservation | Recreated | Perfect |
| Performance | Two renders | Single render |
| API Safety | App Store safe | Private API |

## Basic Setup

```swift
import PortalTransitions
import _PortalMirror

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

## Portal Source Modifiers

### `.portalPrivate(id:)`
Basic portal with string ID:
```swift
MyView()
    .portalPrivate(id: "portal1")
```

### `.portalPrivate(item:)`
Portal using an Identifiable item:
```swift
PhotoView(photo)
    .portalPrivate(item: photo)
```

### With Group ID
For coordinated animations:
```swift
CardView()
    .portalPrivate(id: "card1", groupID: "stack")

PhotoView()
    .portalPrivate(item: photo, groupID: "gallery")
```

## Transition Modifiers

### Single Portal
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

### Multiple Portals (Coordinated)
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

## Destination Views

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

## When to Use _PortalMirror

### ✅ Good Use Cases

- **List → Detail** transitions where items should look identical
- **Card stacks** moving between positions
- **Tab switching** with consistent content
- **Picture-in-picture** scenarios
- **Sidebars/panels** sliding in/out
- Any case where **same size is desired**
- **Perfect state preservation** is critical (videos, animations, text input)

### ❌ When to Use PortalTransitions Instead

- **Thumbnail → Fullscreen** transitions
- **Hero animations** needing size changes
- **Grid → Detail** with different layouts
- **App Store apps** (PortalTransitions is safe, _PortalMirror uses private API)
- Any case where **different sizes are needed**

---

## Complete PortalPrivate Example

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

## Migration from PortalTransitions

```swift
// PortalTransitions (before)
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

## Important Notes

### Sizing

Both `SourceViewRepresentable` and `PortalView` automatically size themselves based on the source view's intrinsic content size. You can override with `.frame()` modifiers.

### Updates

When the source view's content changes, call `container.update(content:)` to reflect changes in all portals.

### Performance

Portal views are lightweight - they don't duplicate rendering. However, creating many portals of complex views may impact layout performance.

---

## Limitations

- **Private API** - Consider implications for App Store submissions
- **iOS only** - `_UIPortalView` is iOS-specific
- **Runtime availability** - May break in future iOS versions
- **Debugging** - View hierarchy debugger shows portal structure, not source content
- **Same size only** - Source and destination must be identical sizes

---

## Examples

Full working examples are included:
- [Static ID](../Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleStaticID.swift)
- [Card Grid](../Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleCardGrid.swift)
- [List](../Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleList.swift)
- [Comparison](../Sources/_PortalMirror/Transitions/Examples/PortalPrivateExampleComparison.swift)
- [UIPortalView Direct Usage](../Sources/_PortalMirror/View/UIPortalViewExample.swift)

---

## Related Documentation

- [Portal Usage](./Usage) - Standard PortalTransitions API
- [Debugging](./Debugging) - Debug overlays and logging
- [How Portal Works](./How-Portal-Works) - Understanding Portal's architecture
