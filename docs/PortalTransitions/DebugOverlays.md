# PortalTransitions - Debug Overlays

Debug overlays visualize portal sources, destinations, and animated layers during development, making it easier to verify your portal setup.

## Quick Enable

```swift
ContentView()
    .portalTransitionDebugOverlays(true)
```

## What You'll See

- **Blue overlay** - Portal source views
- **Orange overlay** - Portal destination views
- **Green overlay** - Animated layer (the view that moves during transition)
- **"PortalContainerOverlay" indicator** - Confirms the overlay window is active

## Targeting Specific Elements

Control which portal elements show overlays:

```swift
// Show overlays on sources only
.portalTransitionDebugOverlays(.all, for: .source)

// Show overlays on destinations only
.portalTransitionDebugOverlays(.all, for: .destination)

// Show overlays on the animated layer only
.portalTransitionDebugOverlays(.all, for: .layer)

// Multiple targets
.portalTransitionDebugOverlays(.all, for: [.source, .destination])
```

## Customizing Visual Style

Control what visual elements appear in the overlay:

```swift
// Labels only (text indicators)
.portalTransitionDebugOverlays([.label], for: .all)

// Borders only (outline around views)
.portalTransitionDebugOverlays([.border], for: .all)

// Background highlights only
.portalTransitionDebugOverlays([.background], for: .all)

// Multiple styles
.portalTransitionDebugOverlays([.label, .border], for: .all)

// All styles
.portalTransitionDebugOverlays(.all, for: .all)
```

## Combining Style and Target

Mix and match styles with targets for precise debugging:

```swift
// Show labels on sources, borders on destinations
ContentView()
    .portalTransitionDebugOverlays([.label], for: .source)
    .portalTransitionDebugOverlays([.border], for: .destination)

// Full overlays on layer, minimal on sources
ContentView()
    .portalTransitionDebugOverlays(.all, for: .layer)
    .portalTransitionDebugOverlays([.label], for: .source)
```

## Disabling Overlays

```swift
.portalTransitionDebugOverlays(false)

// Or explicitly
.portalTransitionDebugOverlays(.none, for: .all)
```

## Available Types

### PortalTransitionDebugStyle (what to show)
- `.label` - Text indicator
- `.border` - Outline border
- `.background` - Background highlight
- `.all` - All styles
- `.none` - No styles

### PortalTransitionDebugTarget (where to show)
- `.source` - Source views (starting point)
- `.destination` - Destination views (ending point)
- `.layer` - Animated layer (moving element)
- `.all` - All targets

## Notes

- Debug overlays only appear in DEBUG builds
- They don't affect touch handling or layout
- Useful for verifying source/destination alignment before testing transitions
- The layer overlay helps debug animation positioning issues
