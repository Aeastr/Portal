# PortalTransitions - Group Animations

Animate multiple portals simultaneously as a coordinated group. Useful when several elements should transition together to the same destination.

## When to Use

- Multiple thumbnails expanding into a single detail view
- A stack of cards animating to a spread layout
- Related UI elements that should move in sync

## Basic Usage

### With String IDs

```swift
// Mark multiple sources with a shared groupID
Image("photo1")
    .portal(id: "photo1", .source, groupID: "photoStack", in: namespace)

Image("photo2")
    .portal(id: "photo2", .source, groupID: "photoStack", in: namespace)

Image("photo3")
    .portal(id: "photo3", .source, groupID: "photoStack", in: namespace)

// Destinations also share the groupID
ForEach(["photo1", "photo2", "photo3"], id: \.self) { id in
    Image(id)
        .portal(id: id, .destination, groupID: "photoStack", in: namespace)
}

// Trigger group transition
.portalTransition(
    ids: ["photo1", "photo2", "photo3"],
    groupID: "photoStack",
    in: namespace,
    isActive: $showDetail
) { id in
    Image(id)
}
```

### With Identifiable Items

```swift
// Mark sources
ForEach(photos) { photo in
    PhotoThumbnail(photo: photo)
        .portal(item: photo, .source, groupID: "gallery", in: namespace)
}

// Mark destinations
ForEach(photos) { photo in
    PhotoDetail(photo: photo)
        .portal(item: photo, .destination, groupID: "gallery", in: namespace)
}

// Trigger group transition
.portalTransition(
    items: photos,
    groupID: "gallery",
    in: namespace,
    isActive: $showGallery
) { photo in
    PhotoThumbnail(photo: photo)
}
```

## How It Works

1. All portals in the group animate simultaneously
2. One portal acts as the "coordinator" and handles the completion callback
3. Animation timing is synchronized across all portals
4. Cleanup happens for all portals when the group transition completes

## Options

Group transitions support the same options as single transitions:

```swift
// Level 1: Styling only (simplest)
.portalTransition(
    ids: ids,
    groupID: "myGroup",
    in: namespace,
    isActive: $isActive,
    animation: .spring(duration: 0.5),
    transition: .fade,
    completion: { finished in
        print("Group transition finished: \(finished)")
    }
) { id in
    ContentView(id: id)
} configuration: { content, isActive in
    content
        .clipShape(.rect(cornerRadius: isActive ? 16 : 8))
        .shadow(radius: isActive ? 20 : 5)
}

// Level 2: Full control (when modifier ordering matters)
.portalTransition(
    ids: ids,
    groupID: "myGroup",
    in: namespace,
    isActive: $isActive
) { id in
    ContentView(id: id)
} configuration: { content, isActive, size, position in
    content
        .frame(width: size.width, height: size.height)
        .clipShape(.rect(cornerRadius: isActive ? 16 : 8))
        .offset(x: position.x, y: position.y)
}
```

## Notes

- All portals in a group should have matching `groupID` values
- The completion handler fires once for the entire group, not per-portal
- Reverse animations also happen as a coordinated group
