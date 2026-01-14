# PortalTransitions - Transferring Portals

When presenting a detail view that allows paging between items—like a photo carousel or a horizontally scrolling gallery—the dismiss animation should return to whichever item is currently displayed, not the original item that was tapped.

## The Problem

Consider a grid of photos. The user taps photo A, which opens a fullscreen carousel. They swipe to photo B, then dismiss. Without portal transfer, the animation would return to photo A's position in the grid, even though photo B is displayed.

## The Solution

Portal provides `transferActivePortal(from:to:)` on `CrossModel` to handle this scenario. When the user swipes to a new item in the detail view, you transfer the active portal state to the new item. The dismiss animation will then return to the correct grid position with the correct content.

## Usage

### 1. Access the Portal Model

In your detail view, access the `CrossModel` via environment:

```swift
@Environment(CrossModel.self) private var portalModel
```

### 2. Track the Current Item

Use a binding to track which item is currently active for the portal:

```swift
@Binding var portalItem: CarouselItem?
```

### 3. Transfer on Page Change

When the user swipes to a new page, call `transferActivePortal` and update the binding:

```swift
.onChange(of: currentIndex) { oldIndex, newIndex in
    let oldItem = items[oldIndex]
    let newItem = items[newIndex]
    portalModel.transferActivePortal(fromItem: oldItem, toItem: newItem)
    portalItem = newItem
}
```

The modifier automatically updates the layer view content to match the new item.

## API Variants

Portal provides two versions of the transfer method:

### Item-Based (Recommended)

```swift
func transferActivePortal<Item: Identifiable>(fromItem: Item, toItem: Item)
```

Use this when working with `Identifiable` items. It extracts the IDs automatically:

```swift
portalModel.transferActivePortal(fromItem: oldItem, toItem: newItem)
```

### ID-Based

```swift
func transferActivePortal<ID: Hashable>(from fromID: ID, to toID: ID)
```

Use this when working directly with IDs. Works with any `Hashable` type—strings, UUIDs, integers, etc.:

```swift
// With string IDs
portalModel.transferActivePortal(from: "panel1", to: "panel2")

// With item IDs directly
portalModel.transferActivePortal(from: oldItem.id, to: newItem.id)
```

### Why Two Versions?

Ideally, the item-based version would use matching parameter labels:

```swift
// This would be more consistent, but causes a compiler crash
func transferActivePortal<Item: Identifiable>(from fromItem: Item, to toItem: Item)
```

However, this triggers a Swift compiler crash in Xcode 26.1+ under specific conditions:

1. The view has a `@Binding` of an `Identifiable` type (e.g., `@Binding var portalItem: CarouselItem?`)
2. You call the `Identifiable` overload with `from:`/`to:` labels
3. You assign to that binding after the call

The compiler crashes with `"Please submit a bug report"` during compilation—no useful diagnostic.

Using distinct parameter labels (`fromItem:`/`toItem:`) avoids the crash entirely. The original `from:`/`to:` overload is commented out in `CrossModel.swift` and can be re-enabled if Apple fixes the bug.

### 4. Separate Sheet and Portal State

Use separate state for the sheet presentation and the portal animation. This prevents the sheet from dismissing when the portal item changes:

```swift
@State private var selectedItem: CarouselItem?   // Controls sheet presentation
@State private var portalItem: CarouselItem?     // Controls portal animation

.fullScreenCover(item: $selectedItem) { item in
    CarouselDetailView(
        items: items,
        initialItem: item,
        portalItem: $portalItem
    )
}
.portalTransition(item: $portalItem) { item in
    GridItemView(item: item)
}
```

## Complete Example

See `PortalExampleGridCarousel.swift` for a complete working implementation demonstrating:

- A grid of tappable items
- Fullscreen carousel with horizontal paging via `TabView`
- Portal transfer on swipe
- Correct dismiss animation to the current item's grid position
