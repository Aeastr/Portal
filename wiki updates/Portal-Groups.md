# Portal Groups - Coordinated Multi-Item Transitions

Portal Groups enable coordinated animations for multiple items transitioning simultaneously. This is perfect for scenarios like selecting multiple photos from a grid and transitioning them together to a detail view with synchronized or staggered timing.

---

## When to Use Portal Groups

Portal Groups are designed for scenarios where you need:

- **Multiple items animating together** as a coordinated unit
- **Synchronized timing** across all transitions
- **Staggered animations** with controlled delays between items
- **Shared group coordination** where one portal manages timing for the entire group

**Common Use Cases:**
- Photo gallery: Multiple photos transitioning to a detail view
- Multi-select interfaces: Selected items animating together
- Batch operations: Group of items moving to a new state
- Coordinated UI elements: Related views transitioning as a unit

---

## How Portal Groups Work

Portal Groups coordinate multiple portal transitions by:

1. **Grouping by ID**: Portals with the same `groupID` are treated as a coordinated group
2. **Coordinator Selection**: The first portal in the group becomes the coordinator
3. **Synchronized Timing**: All portals in the group animate with shared timing
4. **Optional Staggering**: Each item can start with an incremental delay

---

## Basic Setup

> Tip: As with the core API, install `PortalContainer` once at your root so both the gallery and sheet share the same overlay. Examples inline it for clarity only.

### Step 1: Mark Sources with Group ID

Use `.portal(item:, .source, groupID:)` on each source view:

```swift
ForEach(photos) { photo in
    PhotoThumbnailView(photo: photo)
        .portal(item: photo, .source, groupID: "photoStack")
}
```

### Step 2: Mark Destinations with Group ID

Use `.portal(item:, .destination, groupID:)` on each destination view:

```swift
ForEach(selectedPhotos) { photo in
    PhotoDetailView(photo: photo)
        .portal(item: photo, .destination, groupID: "photoStack")
}
```

### Step 3: Apply Multi-Item Transition

Use `.portalTransition(items:groupID:...)` to manage the group:

```swift
.portalTransition(
    items: $selectedPhotos,
    groupID: "photoStack",
    animation: .spring(response: 0.5, dampingFraction: 0.8)
) { photo in
    PhotoLayerView(photo: photo)
}
```

---

## Complete Example

```swift
import SwiftUI
import PortalTransitions

struct MultiPhotoGallery: View {
    @State private var selectedPhotos: [Photo] = []
    @State private var allPhotos: [Photo] = Photo.sampleData

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        // Install once at the top of your hierarchy (shown inline here for clarity).
        PortalContainer {
            NavigationView {
                VStack {
                    // Source: Photo Grid
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(allPhotos) { photo in
                            PhotoThumbnailView(photo: photo)
                                .portal(item: photo, .source, groupID: "photoStack")
                                .onTapGesture {
                                    if selectedPhotos.contains(where: { $0.id == photo.id }) {
                                        selectedPhotos.removeAll { $0.id == photo.id }
                                    } else {
                                        selectedPhotos.append(photo)
                                    }
                                }
                        }
                    }
                    .padding()

                    Spacer()
                }
                .navigationTitle("Select Photos")
            }
            .sheet(isPresented: .constant(!selectedPhotos.isEmpty)) {
                MultiPhotoDetailView(photos: selectedPhotos) {
                    selectedPhotos.removeAll()
                }
            }
            .portalTransition(
                items: $selectedPhotos,
                groupID: "photoStack",
                animation: .spring(response: 0.5, dampingFraction: 0.8)
            ) { photo in
                PhotoLayerView(photo: photo)
            }
        }
    }
}

// Detail View with Destinations
struct MultiPhotoDetailView: View {
    let photos: [Photo]
    let onDismiss: () -> Void

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(photos) { photo in
                        PhotoDetailView(photo: photo)
                            .portal(item: photo, .destination, groupID: "photoStack")
                    }
                }
                .padding()
            }
            .navigationTitle("Selected Photos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { onDismiss() }
                }
            }
        }
    }
}
```

---

## Staggered Animations

Add a stagger delay to create cascading animations where each item starts slightly after the previous one:

```swift
.portalTransition(
    items: $selectedPhotos,
    groupID: "photoStack",
    animation: .spring(response: 0.5, dampingFraction: 0.8),
    staggerDelay: 0.05  // Each item starts 0.05s after the previous
) { photo in
    PhotoLayerView(photo: photo)
}
```

**Stagger Timing:**
- **First item**: Starts at base delay (internal system delay)
- **Second item**: Starts at base delay + 0.05s
- **Third item**: Starts at base delay + 0.10s
- And so on...

**When to Use Stagger:**
- ✅ Visual interest for 3-10 items
- ✅ Emphasizing sequence or order
- ✅ Creating a "cascade" effect
- ❌ Large groups (>10 items) - can feel sluggish
- ❌ When instant feedback is critical

---

## Advanced Configuration

### Custom Animation and Styling Per Group

```swift
.portalTransition(
    items: $selectedPhotos,
    groupID: "photoStack",
    in: PortalCorners(
        source: 12,
        destination: 16,
        style: .continuous
    ),
    animation: .spring(response: 0.4, dampingFraction: 0.8),
    completionCriteria: .removed,
    staggerDelay: 0.04
) { photo in
    PhotoLayerView(photo: photo)
}
```

### Completion Handling

The completion handler is called once when all group animations finish:

```swift
.portalTransition(
    items: $selectedPhotos,
    groupID: "photoStack",
    animation: .spring(response: 0.4, dampingFraction: 0.8),
    completion: { success in
        if success {
            print("All photos finished transitioning")
            // Perform post-transition actions
        }
    }
) { photo in
    PhotoLayerView(photo: photo)
}
```

---

## Important Considerations

### Group ID Consistency

**✅ Correct:**
```swift
// Source
.portal(item: photo, .source, groupID: "photoStack")

// Destination
.portal(item: photo, .destination, groupID: "photoStack")

// Transition
.portalTransition(items: $photos, groupID: "photoStack")
```

**❌ Incorrect:**
```swift
// Mismatched group IDs
.portal(item: photo, .source, groupID: "photos")
.portalTransition(items: $photos, groupID: "photoStack") // Different ID!
```

### Layer View Requirements

Each item should have a **visually identical layer view**:

```swift
// ✅ Good: Consistent layer view for all items
.portalTransition(items: $photos, groupID: "photoStack") { photo in
    RoundedRectangle(cornerRadius: 12)
        .fill(photo.color)
        .overlay(Image(systemName: photo.icon))
}

// ❌ Bad: Different views for different items
.portalTransition(items: $photos, groupID: "photoStack") { photo in
    if photo.isFavorite {
        FavoritePhotoView(photo: photo)  // Inconsistent!
    } else {
        RegularPhotoView(photo: photo)
    }
}
```

### Performance

Portal Groups are optimized for performance, but consider:

- **Recommended**: 2-20 items per group
- **Maximum**: ~50 items before noticeable performance impact
- **Large datasets**: Consider batching or virtualization

---

## Comparison: Single vs. Multi-Item

| Feature | Single Item | Multi-Item (Group) |
|---------|-------------|-------------------|
| **Binding** | `Binding<Item?>` | `Binding<[Item]>` |
| **Group ID** | Optional | Required |
| **Coordination** | Individual | Synchronized |
| **Stagger** | N/A | Supported |
| **Use Case** | Detail view | Multi-select |

---

## Troubleshooting

### Items Not Animating Together

**Problem**: Items animate individually instead of as a group

**Solutions**:
- ✅ Ensure all portals use the **same `groupID`**
- ✅ Verify `groupID` in source, destination, and transition match exactly
- ✅ Check that items array is non-empty when transition triggers

### Stagger Not Working

**Problem**: All items start simultaneously despite `staggerDelay`

**Solutions**:
- ✅ Verify `staggerDelay > 0`
- ✅ Ensure `staggerDelay` is passed to `.portalTransition()`
- ✅ Check animation config doesn't override timing

### Animation Feels Sluggish

**Problem**: Group animation takes too long to complete

**Solutions**:
- ⚡ Reduce `staggerDelay` (try 0.02-0.05s)
- ⚡ Decrease animation duration in config
- ⚡ Limit number of items in group (<10 recommended with stagger)
- ⚡ Use synchronized animation (staggerDelay: 0) for large groups

---

## API Reference

### Portal Modifier with Group

```swift
func portal<Item: Identifiable>(
    item: Item,
    _ role: PortalRole,
    groupID: String
) -> some View
```

### Multi-Item Transition

```swift
func portalTransition<Item: Identifiable, LayerView: View>(
    items: Binding<[Item]>,
    groupID: String,
    in corners: PortalCorners? = nil,
    animation: Animation = .smooth(duration: 0.4),
    completionCriteria: AnimationCompletionCriteria = .removed,
    staggerDelay: TimeInterval = 0.0,
    completion: @escaping (Bool) -> Void = { _ in },
    @ViewBuilder layerView: @escaping (Item) -> LayerView
) -> some View
```

**Parameters**:
- `items`: Binding to array of `Identifiable` items controlling transitions
- `groupID`: Group identifier matching portal sources/destinations
- `in corners`: Optional corner radius configuration for visual styling
- `animation`: Animation to use for the transition (defaults to `.smooth(duration: 0.4)`)
- `completionCriteria`: How to detect animation completion (defaults to `.removed`)
- `staggerDelay`: Delay between each item's animation start (seconds, defaults to 0)
- `completion`: Handler called when all animations complete (defaults to no-op)
- `layerView`: Closure generating layer view for each item

---

➡️ [Back to Usage](./Usage) | [View Examples](./Examples)
