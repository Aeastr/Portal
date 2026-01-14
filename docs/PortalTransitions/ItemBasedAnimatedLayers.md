# PortalTransitions - Item-Based Animated Layers

Add custom animations to layer views when using item-based portal transitions (`.portal(item:)` and `.portalTransition(item:)`).

> **Tip:** For simple styling (clips, shadows, corner radii), consider using the `configuration` closure on `.portalTransition()` instead — see [Animation Options](AnimationOptions.md). Use these protocols when you need custom timing logic or reusable animated components.

## What It Does

When using the item-based portal API with `Identifiable` items, the `AnimatedItemPortalLayer` protocol provides access to both the current item and the active state. This allows animations that respond to which item is transitioning, not just whether a transition is active.

## The Protocol

```swift
public protocol AnimatedItemPortalLayer: View {
    associatedtype Item: Identifiable
    associatedtype AnimatedContent: View

    var item: Item? { get }
    @ViewBuilder func animatedContent(item: Item?, isActive: Bool) -> AnimatedContent
}
```

- `item` - The current item (derived from a `Binding<Item?>`)
- `animatedContent(item:isActive:)` - Return animated content based on the item and active state

## Basic Example

A scale effect that uses item data:

```swift
struct ItemScalingLayer<Item: Identifiable, Content: View>: AnimatedItemPortalLayer {
    let item: Item?
    @ViewBuilder let content: (Item) -> Content

    @State private var scale: CGFloat = 1

    func animatedContent(item: Item?, isActive: Bool) -> some View {
        Group {
            if let item {
                content(item)
                    .scaleEffect(scale)
                    .onChange(of: isActive) { _, newValue in
                        withAnimation(.spring(duration: 0.3)) {
                            scale = newValue ? 1.1 : 1.0
                        }
                    }
            }
        }
    }
}
```

## Using AnimatedItemLayer

For simple cases, use the built-in `AnimatedItemLayer` wrapper instead of creating a custom type:

```swift
AnimatedItemLayer(item: $selectedPhoto) { photo, isActive in
    if let photo {
        AsyncImage(url: photo.imageURL)
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.spring, value: isActive)
    }
}
```

## Usage Pattern

Use with item-based portal sources and transitions:

```swift
// In the grid
ForEach(photos) { photo in
    PhotoView(photo: photo)
        .portal(item: photo, .source)
        .onTapGesture { selectedPhoto = photo }
}

// In the transition
.portalTransition(item: $selectedPhoto) { photo in
    AnimatedItemLayer(item: $selectedPhoto) { item, isActive in
        if let item {
            PhotoView(photo: item)
                .scaleEffect(isActive ? 1.05 : 1.0)
        }
    }
}
```

## Group Animations

For coordinated multi-item transitions, use `AnimatedGroupPortalLayer`:

```swift
public protocol AnimatedGroupPortalLayer: View {
    associatedtype Item: Identifiable
    associatedtype AnimatedContent: View

    var items: [Item] { get }
    var groupID: String { get }
    @ViewBuilder func animatedContent(items: [Item], activeStates: [Item.ID: Bool]) -> AnimatedContent
}
```

Or use the convenience wrapper:

```swift
AnimatedGroupLayer(items: $selectedPhotos, groupID: "photoStack") { items, activeStates in
    ZStack {
        ForEach(items) { photo in
            let isActive = activeStates[photo.id] ?? false
            PhotoView(photo: photo)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring, value: isActive)
        }
    }
}
```

## Comparison with AnimatedPortalLayer

| Feature | `AnimatedPortalLayer` | `AnimatedItemPortalLayer` |
|---------|----------------------|--------------------------|
| Portal ID | String `portalID` property | Derived from `item.id` |
| Item Access | None | Full item access |
| Use Case | Static ID portals | Item-based portals |
| API Pattern | `.portal(id:)` | `.portal(item:)` |

## Notes

- The `item` parameter may be `nil` during reverse transitions; the layer host caches the last item to maintain content visibility
- `isActive` is `true` during forward transition, `false` during reverse
- For group animations, `activeStates` provides per-item active state via a dictionary
