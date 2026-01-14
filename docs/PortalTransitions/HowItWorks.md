# PortalTransitions - How It Works

PortalTransitions animates a view between two positions by rendering it on a transparent overlay window above your app's UI.

## The Concept

1. **Source** - The starting view (e.g., a thumbnail in a grid)
2. **Destination** - The ending view (e.g., a fullscreen image)
3. **Layer** - A copy of the view that animates between source and destination positions

## The Flow

### Opening

1. User triggers the transition (e.g., taps a grid item)
2. Portal captures the source view's position
3. The source view becomes invisible
4. A layer view appears on the overlay window at the source position
5. The destination view appears (invisible initially)
6. Portal captures the destination view's position
7. The layer animates from source position to destination position
8. Once complete, the layer hides and the destination becomes visible

### Closing

1. User dismisses (e.g., closes the sheet)
2. The destination becomes invisible
3. The layer reappears at the destination position
4. The layer animates back to the source position
5. Once complete, the layer hides and the source becomes visible

## The Overlay Window

`PortalContainer` creates a transparent `PassThroughWindow` that sits above your app's UI. This window:

- Is fully transparent and doesn't intercept touches
- Hosts the animated layer view during transitions
- Allows the layer to animate across view hierarchies (e.g., from a view to a sheet)

This is why the layer can smoothly animate even when the source and destination are in different presentation contexts.

## Key Components

| Component | Purpose |
|-----------|---------|
| `PortalContainer` | Sets up the overlay window and provides the shared model |
| `CrossModel` | Shared state tracking all active portal animations |
| `PortalInfo` | State for a single portal (anchors, animation, visibility) |
| `.portal()` | Marks a view as source or destination, reports its position |
| `.portalTransition()` | Orchestrates the animation lifecycle |
| `PortalLayerView` | Renders animated layers on the overlay window |
