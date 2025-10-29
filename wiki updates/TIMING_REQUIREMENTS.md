# Portal Animation Timing Requirements

## Critical Sheet Timing Issue

When using Portal or PortalPrivate with sheets or other system presentations, the animation duration **MUST** be at least 0.35-0.4 seconds to avoid visual glitches.

### The Problem

iOS sheet presentations have an internal animation duration of approximately 0.35-0.4 seconds. If the portal animation completes before the sheet finishes presenting, you will see:

- **Visual shift/flicker** when the transition layer disappears and destination appears
- The destination view appears while the sheet is still moving
- More noticeable with PortalPrivate due to _UIPortalView instance switching

### Affected Durations

- ❌ **0.1s - 0.3s**: Too fast, causes visible shift
- ✅ **0.35s - 0.4s**: Safe range that matches sheet timing
- ✅ **0.38s**: Current default, calibrated for sheets
- ✅ **0.4s+**: Safe but may feel slow for non-sheet transitions

### Example Configuration

```swift
// BAD - Too fast for sheets
.PortalTransitions(
    item: $selectedItem,
    config: .init(animation: PortalAnimation(.smooth(duration: 0.2))),  // ❌ Will cause shift
    layerView: { ... }
)

// GOOD - Matches sheet timing
.PortalTransitions(
    item: $selectedItem,
    config: .init(animation: PortalAnimation(.smooth(duration: 0.38))),  // ✅ No shift
    layerView: { ... }
)

// GOOD - Using default (0.38s)
.PortalTransitions(
    item: $selectedItem,  // ✅ Default is calibrated for sheets
    layerView: { ... }
)
```

### Why This Happens

1. Portal animation with duration < 0.35s completes
2. Transition layer hides, destination shows (via opacity change)
3. But sheet is still animating for another ~0.05-0.1s
4. Result: Visible movement after the portal "completes"

### Other Presentations

This timing requirement applies to any system presentation with its own animation:
- Sheets
- Fullscreen covers
- Popovers (on iPad)
- Navigation pushes (less noticeable but still affected)

### Non-Presentation Transitions

For transitions that don't involve system presentations (like overlays or custom presentations), shorter durations are fine:
- Custom overlays: Any duration works
- ZStack transitions: Any duration works
- Opacity/scale transitions: Any duration works
