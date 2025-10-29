# PortalView

**⚠️ Warning: This module uses private APIs and is NOT App Store safe. Use for internal tools, testing, or research only.**

`PortalView` is a low-level SwiftUI wrapper for Apple's private `_UIPortalView` API, which allows displaying the same UIView instance in multiple locations simultaneously.

---

## What is _UIPortalView?

`_UIPortalView` is a private UIKit class that creates a "portal" to another view. Unlike copying or recreating a view, a portal shows the **exact same view instance** in multiple places. Changes to the source view (animations, transforms, content updates) are instantly reflected in all portal instances.

### Key Capabilities

- **True instance sharing** - Portal views are not copies; they're windows into the same view
- **Synchronized state** - Animations, transforms, and content updates appear in all portals simultaneously
- **Performance** - No need to redraw or recreate view hierarchies
- **Flexible positioning** - Each portal can be positioned and sized independently

---

## Installation

Add `PortalView` as a target dependency:

```swift
.package(url: "https://github.com/Aeastr/Portal.git", from: "3.0.0")
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "PortalView", package: "Portal")
    ]
)
```

Then import it:

```swift
import PortalTransitionsView
```

---

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

---

## Complete Example

```swift
import SwiftUI
import PortalTransitionsView

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

---

## API Reference

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

## Important Notes

### Sizing

Both `SourceViewRepresentable` and `PortalView` automatically size themselves based on the source view's intrinsic content size. You can override with `.frame()` modifiers.

### Updates

When the source view's content changes, call `container.update(content:)` to reflect changes in all portals.

### Performance

Portal views are lightweight - they don't duplicate rendering. However, creating many portals of complex views may impact layout performance.

---

## Limitations

- **Private API** - Not allowed in App Store submissions
- **iOS only** - `_UIPortalView` is iOS-specific
- **Runtime availability** - May break in future iOS versions
- **Debugging** - View hierarchy debugger shows portal structure, not source content

---

## Related

- [PortalPrivate](./PortalPrivate) - Portal transitions reimplemented with PortalView
- [How Portal Works](./How-Portal-Works) - Understanding Portal's architecture
