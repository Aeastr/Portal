# PortalHeaders - Snapping Behavior

When scrolling stops while the header is mid-transition, PortalHeaders can snap to a final position for a polished feel.

## Snapping Options

### Directional (Default)

Snaps based on scroll direction - feels most natural:

```swift
.portalHeader(
    title: "Title",
    subtitle: "Subtitle",
    snappingBehavior: .directional
)
```

- Scrolling **down** (into content) → snaps to nav bar (1.0)
- Scrolling **up** (toward top) → snaps to inline header (0.0)

### Nearest

Snaps to whichever position is closer:

```swift
.portalHeader(
    title: "Title",
    subtitle: "Subtitle",
    snappingBehavior: .nearest
)
```

- Progress > 0.5 → snaps to nav bar (1.0)
- Progress < 0.5 → snaps to inline header (0.0)

### None

No snapping - header stays at current position:

```swift
.portalHeader(
    title: "Title",
    subtitle: "Subtitle",
    snappingBehavior: .none
)
```

Useful when you want the header to track scroll position exactly without automatic correction.

## How It Works

Snapping only triggers when:
1. Scrolling stops (finger lifted, momentum ends)
2. Header is mid-transition (progress between 0 and 1)

The snap animation uses a smooth curve for a native feel.
