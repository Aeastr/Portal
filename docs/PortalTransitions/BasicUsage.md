# PortalTransitions - Basic Usage

PortalTransitions creates seamless hero transitions between views by connecting a source and destination with matching identifiers.

## PortalContainer

Wrap the view hierarchy where you want portal transitions:

```swift
PortalContainer {
    // Your views here
}
```

## Marking Views

Mark the source (origin) and destination (target) views with matching identifiers.

**With Identifiable items:**

```swift
// Source - e.g., thumbnail in a grid
Image(photo.thumbnail)
    .portal(item: photo, .source)

// Destination - e.g., fullscreen detail
Image(photo.fullSize)
    .portal(item: photo, .destination)
```

**With string IDs:**

```swift
Image(photo.thumbnail)
    .portal(id: "hero-image", .source)

Image(photo.fullSize)
    .portal(id: "hero-image", .destination)
```

## Triggering Transitions

Use `.portalTransition()` to animate between source and destination.

**With Identifiable items:**

```swift
.portalTransition(item: $selectedPhoto) { photo in
    // The view to animate
    Image(photo.thumbnail)
}
```

**With string IDs:**

```swift
.portalTransition(id: "hero-image", isPresented: $showDetail) {
    Image(photo.thumbnail)
}
```

## Examples

See the included examples for complete implementations:

- `PortalExampleCardGrid` - Grid with item-based transitions
- `PortalExampleList` - List with item-based transitions
- `PortalExampleStaticID` - Using string IDs
