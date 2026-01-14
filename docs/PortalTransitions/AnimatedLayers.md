# PortalTransitions - Animated Layers

Add custom animations to the layer view during portal transitions using the `AnimatedPortalLayer` protocol.

> **Tip:** For simple styling (clips, shadows, corner radii), consider using the `configuration` closure on `.portalTransition()` instead — see [Animation Options](AnimationOptions.md). Use this protocol when you need custom timing logic or reusable animated components.

## What It Does

The layer view (the view that animates between source and destination) can respond to the portal's active state. Use this to add effects like scaling, rotation, or opacity changes during the transition.

## The Protocol

```swift
public protocol AnimatedPortalLayer: View {
    associatedtype Content: View
    associatedtype AnimatedContent: View

    var portalID: String { get }
    @ViewBuilder var content: () -> Content { get }
    @ViewBuilder func animatedContent(isActive: Bool) -> AnimatedContent
}
```

- `portalID` - Must match the portal ID this layer belongs to
- `content` - The base content to animate
- `animatedContent(isActive:)` - Return the content with animations applied based on state

## Basic Example

A simple scale effect during transition:

```swift
struct ScalingLayer<Content: View>: AnimatedPortalLayer {
    let portalID: String
    @ViewBuilder let content: () -> Content

    @State private var scale: CGFloat = 1

    func animatedContent(isActive: Bool) -> some View {
        content()
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                withAnimation(.spring(duration: 0.3)) {
                    scale = newValue ? 1.1 : 1.0
                }
            }
    }
}
```

## Usage

Use your animated layer in both the source view and the `portalTransition` layer:

```swift
// Source view
ScalingLayer(portalID: "hero") {
    ItemContent()
}
.portal(id: "hero", .source)

// Destination view
ScalingLayer(portalID: "hero") {
    ItemContent()
}
.portal(id: "hero", .destination)

// Transition
.portalTransition(id: "hero", isActive: $showDetail) {
    ScalingLayer(portalID: "hero") {
        ItemContent()
    }
}
```

> **Note:** For item-based portals using `Identifiable` items, see [Item-Based Animated Layers](ItemBasedAnimatedLayers.md).

## Bounce Effect Example

A more complex animation with a bounce:

```swift
struct BouncingLayer<Content: View>: AnimatedPortalLayer {
    let portalID: String
    var peakScale: CGFloat = 1.1
    @ViewBuilder let content: () -> Content

    @State private var scale: CGFloat = 1

    func animatedContent(isActive: Bool) -> some View {
        content()
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                // Scale up
                withAnimation(.smooth(duration: 0.35, extraBounce: 0.25)) {
                    scale = newValue ? peakScale : 1.15
                }
                // Then back down
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.smooth(duration: 0.47, extraBounce: 0.55)) {
                        scale = 1
                    }
                }
            }
    }
}
```

## Notes

- The `isActive` state is `true` during forward transition, `false` during reverse
- You can trigger multiple animations in sequence for complex effects
- See `AnimatedLayer.swift` in Examples for a complete implementation
