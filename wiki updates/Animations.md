# Portal Animations

Portal provides a comprehensive animation system with direct parameter control, offering both simple defaults and advanced customization options.

---

## Animation System

Portal uses SwiftUI's native `Animation` type directly, providing maximum flexibility and familiarity. All portal transitions accept standard SwiftUI animations like `.spring()`, `.smooth()`, `.easeInOut()`, etc.

**Key Features:**
- Direct use of SwiftUI `Animation` values
- Completion criteria support for precise control
- Optional corner radius transitions
- Default animation: `.smooth(duration: 0.4)`

---

## Animation Configuration

### Basic Animation Setup

Portal transitions use direct animation parameters:

```swift
// Simple with defaults
.portalTransition(id: "myPortal", isActive: $isActive) {
    MyLayerView()
}

// Custom animation
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
) {
    MyLayerView()
}

// With smooth animation
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .smooth(duration: 0.5, extraBounce: 0.1)
) {
    MyLayerView()
}
```

### Completion Criteria

Use `AnimationCompletionCriteria` for precise control:

```swift
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .smooth(duration: 0.5),
    completionCriteria: .logicallyComplete
) {
    MyLayerView()
}
```

---

## Corner Styling

Portal supports optional corner radius transitions using the `in corners:` parameter:

```swift
// With corner clipping and transitions
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    in: PortalCorners(
        source: 8,        // Starting corner radius
        destination: 20,  // Ending corner radius
        style: .continuous // Apple's continuous corner style
    ),
    animation: .spring(response: 0.4, dampingFraction: 0.8)
) {
    MyLayerView()
}

// Without corner clipping (default)
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
    // No corners parameter - no clipping applied
) {
    MyLayerView()
}
```

**Corner Behavior:**
- **When `corners` is provided**: Views are clipped and corner radius transitions smoothly from source to destination values
- **When `corners` is `nil` (default)**: No clipping is applied, allowing content to extend beyond frame boundaries during scaling transitions

**Corner Styles:**
- `.circular` - Traditional circular arc corners
- `.continuous` - Apple's organic continuous corner curve

---

## Visual Feedback During Transitions

Portal examples demonstrate visual feedback during transitions using a custom `AnimatedLayer` component. This provides the "bounce" effect you see when tapping elements in the examples.

### Current Implementation

Visual feedback for Portal transitions is currently implemented as example code rather than a formal API. The examples include an `AnimatedLayer` component that:

- Monitors Portal's internal state through `@Environment(CrossModel.self)`
- Provides scale animation feedback when transitions are active
- Handles iOS version differences automatically

### Using `AnimatedPortalLayer`

Portal exposes the `AnimatedPortalLayer` protocol so you can author bespoke transition layers that react to the portal lifecycle.

```swift
import PortalTransitions

struct SparkleLayer<Content: View>: AnimatedPortalLayer {
    let portalID: String
    @ViewBuilder var content: () -> Content
    @State private var blur: CGFloat = 0

    func animatedContent(isActive: Bool) -> some View {
        content()
            .blur(radius: blur)
            .onAppear { blur = 0 }
            .onChange(of: isActive) { _, active in
                withAnimation(.smooth(duration: 0.45, extraBounce: 0.3)) {
                    blur = active ? 6 : 0
                }
            }
    }
}

// Usage inside a transition
.portalTransition(id: "card", isActive: $isActive) {
    SparkleLayer(portalID: "card") {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.gradient)
    }
}
```

- `AnimatedPortalLayer` is a `View` protocol; Portal renders it during the transition.
- Use `animatedContent(isActive:)` to react when the portal begins/ends animating.
- Combine with animation and corner parameters for customization.
- The production examples ship with `AnimatedLayer` (`Sources/Portal/Examples/AnimatedLayer.swift`) as a starting point.

### Animation Constants

The examples use these predefined animation values:

```swift
let portalAnimationDuration: TimeInterval = 0.4
let portalAnimationExample: Animation = .smooth(duration: 0.4, extraBounce: 0.25)
let portalAnimationExample: Animation = .smooth(duration: 0.52, extraBounce: 0.55)
```

### Future API

A proper API for visual feedback during Portal transitions is planned for a future release. Until then, the example implementation provides a working pattern you can adapt for your needs.

---

## Animation Examples

### Spring-Based Transitions

```swift
// Bouncy spring
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .spring(response: 0.6, dampingFraction: 0.6)
) {
    MyLayerView()
}

// Smooth spring
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .spring(response: 0.4, dampingFraction: 0.8)
) {
    MyLayerView()
}
```

### Smooth Animations

```swift
// Basic smooth animation
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .smooth(duration: 0.4)
) {
    MyLayerView()
}

// Smooth with bounce
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .smooth(duration: 0.4, extraBounce: 0.2)
) {
    MyLayerView()
}
```

### Custom Timing Curves

```swift
// Ease-in-out
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .easeInOut(duration: 0.5)
) {
    MyLayerView()
}

// Custom timing curve
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    animation: .timingCurve(0.25, 0.1, 0.25, 1, duration: 0.6)
) {
    MyLayerView()
}
```

---

## Advanced Animation Patterns

### Staggered Group Animations

For multi-item transitions, use the `staggerDelay` parameter in group transitions (see [Portal Groups](./Portal-Groups)):

```swift
.portalTransition(
    items: $selectedPhotos,
    groupID: "photoStack",
    animation: .spring(response: 0.4, dampingFraction: 0.8),
    staggerDelay: 0.05  // Each item starts 0.05s after previous
) { photo in
    PhotoLayerView(photo: photo)
}
```

### Corner Morphing

Animate between different corner styles:

```swift
// Card to modal transition
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    in: PortalCorners(
        source: 12,           // Card corner radius
        destination: 0,       // Modal (no corners)
        style: .continuous
    ),
    animation: .smooth(duration: 0.5)
) {
    MyLayerView()
}

// Button to sheet transition
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    in: PortalCorners(
        source: 25,           // Pill button
        destination: 16,      // Sheet corners
        style: .continuous
    ),
    animation: .spring(response: 0.4, dampingFraction: 0.8)
) {
    MyLayerView()
}
```

---

## Reusable Animation Values

Define animation values once and reuse them throughout your app:

```swift
extension Animation {
    static let portalStandard = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let portalQuick = Animation.spring(response: 0.3, dampingFraction: 0.9)
    static let portalSmoothBounce = Animation.smooth(duration: 0.4, extraBounce: 0.2)
}

// Usage
.portalTransition(id: "myPortal", isActive: $isActive, animation: .portalStandard) {
    MyLayerView()
}
```

You can also create custom structures for complete configurations:

```swift
struct PortalAnimationStyle {
    let animation: Animation
    let corners: PortalCorners?

    static let cardExpand = PortalAnimationStyle(
        animation: .smooth(duration: 0.5),
        corners: PortalCorners(source: 12, destination: 0, style: .continuous)
    )
}

// Usage
let style = PortalAnimationStyle.cardExpand
.portalTransition(
    id: "myPortal",
    isActive: $isActive,
    in: style.corners,
    animation: style.animation
) {
    MyLayerView()
}
```

---

Portal uses SwiftUI's native `Animation` type directly, with optional `AnimationCompletionCriteria` for precise control.
