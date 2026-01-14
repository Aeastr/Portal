# PortalHeaders - Debug Overlays

Debug overlays help visualize header sources, destinations, and accessories during development.

## Quick Enable

```swift
ContentView()
    .portalHeaderDebugOverlays(true)
```

## What You'll See

- **Blue overlay** - Source views (inline header position)
- **Orange overlay** - Destination views (navigation bar position)

## Targeting Specific Elements

Control which elements show overlays:

```swift
// Show overlays on sources only
.portalHeaderDebugOverlays(.all, for: .source)

// Show overlays on destinations only
.portalHeaderDebugOverlays(.all, for: .destination)

// Show overlays on accessories only
.portalHeaderDebugOverlays(.all, for: .accessory)

// Multiple targets
.portalHeaderDebugOverlays(.all, for: [.source, .destination])
```

## Customizing Visual Style

Control what visual elements appear:

```swift
// Labels only
.portalHeaderDebugOverlays([.label], for: .all)

// Borders only
.portalHeaderDebugOverlays([.border], for: .all)

// Background highlights
.portalHeaderDebugOverlays([.background], for: .all)

// Multiple styles
.portalHeaderDebugOverlays([.label, .border], for: .all)
```

## Disabling Overlays

```swift
.portalHeaderDebugOverlays(false)

// Or explicitly
.portalHeaderDebugOverlays(.none, for: .all)
```

## Available Types

### PortalHeaderDebugStyle (what to show)
- `.label` - Text indicator
- `.border` - Outline border
- `.background` - Background highlight
- `.all` - All styles
- `.none` - No styles

### PortalHeaderDebugTarget (where to show)
- `.source` - Source views (inline header)
- `.destination` - Destination views (nav bar)
- `.accessory` - Accessory views
- `.all` - All targets

## Notes

- Debug overlays only appear in DEBUG builds
- They don't affect touch handling or layout
- Useful for verifying anchor alignment during scroll transitions
