# PortalTransitions - Animation Options

Customize how portal transitions animate with custom animations, layer configuration, and layer removal behavior.

## Custom Animation

Pass any SwiftUI `Animation` to control timing and easing:

```swift
.portalTransition(item: $selectedItem, in: namespace, animation: .spring(duration: 0.5)) { item in
    ItemView(item: item)
}

// Or with more control
.portalTransition(
    item: $selectedItem,
    in: namespace,
    animation: .easeInOut(duration: 0.4)
) { item in
    ItemView(item: item)
}
```

The default animation is `.smooth(duration: 0.3)`.

## Layer Configuration

The `configuration` closure lets you customize the layer view during animation. There are three levels of control:

### Level 1: Styling Only

Modify appearance without affecting positioning. Frame and offset are applied automatically AFTER your configuration.

```swift
.portalTransition(item: $selectedItem, in: namespace) { item in
    ItemView(item: item)
} configuration: { content, isActive in
    content
        .clipShape(.rect(cornerRadius: isActive ? 24 : 12, style: .continuous))
        .shadow(radius: isActive ? 10 : 2)
}
```

### Level 2: Full Control (Interpolated Values)

Complete control over layout. You MUST apply frame and offset yourself. Receives interpolated size/position based on animation state.

```swift
.portalTransition(item: $selectedItem, in: namespace) { item in
    ItemView(item: item)
} configuration: { content, isActive, size, position in
    content
        .frame(width: size.width, height: size.height)
        .clipShape(.rect(cornerRadius: isActive ? 24 : 12, style: .continuous))
        .offset(x: position.x, y: position.y)
}
```

This gives you control over modifier ordering (e.g., clip AFTER frame).

### Level 3: Raw Source/Destination Values

Access both source AND destination values for custom interpolation or complex logic.

```swift
.portalTransition(item: $selectedItem, in: namespace) { item in
    ItemView(item: item)
} configuration: { content, isActive, sourceSize, destinationSize, sourcePosition, destinationPosition in
    let size = isActive ? destinationSize : sourceSize
    let position = isActive ? destinationPosition : sourcePosition
    return content
        .frame(width: size.width, height: size.height)
        .offset(x: position.x, y: position.y)
}
```

**Note:** When no configuration is provided, frame and offset are applied automatically.

## Remove Transition

Control how the layer disappears when the transition completes:

```swift
.portalTransition(
    item: $selectedItem,
    in: namespace,
    transition: .fade  // Layer fades out
) { item in
    ItemView(item: item)
}
```

**Options:**
- `.none` - Layer disappears instantly (default)
- `.fade` - Layer fades out smoothly

## Completion Handler

Get notified when the transition finishes:

```swift
.portalTransition(
    item: $selectedItem,
    in: namespace,
    completion: { finished in
        if finished {
            // Forward transition completed
        } else {
            // Reverse transition completed
        }
    }
) { item in
    ItemView(item: item)
}
```

## Full Example

```swift
// Level 1: Simple styling (most common)
.portalTransition(
    item: $selectedPhoto,
    in: namespace,
    animation: .spring(duration: 0.45, bounce: 0.2),
    transition: .fade
) { photo in
    AsyncImage(url: photo.thumbnailURL)
} configuration: { content, isActive in
    content
        .clipShape(.rect(cornerRadius: isActive ? 0 : 8, style: .continuous))
        .shadow(radius: isActive ? 0 : 10)
}

// Level 2: Full control when modifier ordering matters
.portalTransition(
    item: $selectedPhoto,
    in: namespace,
    animation: .spring(duration: 0.45, bounce: 0.2),
    transition: .fade
) { photo in
    AsyncImage(url: photo.thumbnailURL)
} configuration: { content, isActive, size, position in
    content
        .frame(width: size.width, height: size.height)
        .clipShape(.rect(cornerRadius: isActive ? 0 : 8, style: .continuous))
        .shadow(radius: isActive ? 0 : 10)
        .offset(x: position.x, y: position.y)
}
```
