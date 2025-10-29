# Debugging Portal

Portal includes comprehensive visual debugging tools to help you troubleshoot and verify the portal system is working correctly.

---

## Debug Visual Indicators

Portal automatically displays color-coded visual indicators in **DEBUG builds only** to show the state of all portal components:

### 1. Container Overlay Badge (Pink 🩷)

- **Label**: "PortalContainerOverlay"
- **Location**: Bottom-right corner
- **Meaning**: Portal overlay window is installed and ready

### 2. Source View Indicators (Blue 🟦)

- **Border**: Blue outline around the view
- **Badge**: "Source" label at bottom-left
- **Meaning**: This view is the portal starting point

### 3. Destination View Indicators (Orange 🟧)

- **Border**: Orange outline around the view
- **Badge**: "Destination" label at bottom-left
- **Meaning**: This view is the portal ending point

### 4. Portal Layer Indicators (Green 🟩)

- **Badge**: "Portal Layer" label at top-left
- **Meaning**: The layer is currently animating between source and destination

### When They Appear

All debug indicators are visible:
- ✅ In Xcode Previews
- ✅ In Debug builds running on device/simulator
- ✅ Automatically when respective components are active

### When They're Hidden

Debug indicators are automatically removed:
- ❌ In Release builds (completely compiled out)
- ❌ In production/TestFlight/App Store builds
- ❌ No performance impact when disabled

### Configuration

**No configuration needed!** All indicators are controlled by the `#if DEBUG` compiler flag:

- **Enable**: Build in Debug configuration (default in Xcode)
- **Disable**: Build in Release configuration

**To temporarily disable specific indicators**, comment out the debug code in:
- `PortalContainer.swift` - Container overlay badge
- `Portal.swift` - Source/destination borders and badges
- `PortalLayerView.swift` - Portal layer badge

---

## What the Indicators Tell You

### ✅ All Indicators Visible
- Portal system fully operational
- Source and destination views registered
- Overlay window installed
- Transitions should work

### ⚠️ Missing Indicators
- **No pink badge**: Overlay window not installed or scene inactive
- **No blue border**: Source view not registered with `.portal()`
- **No orange border**: Destination view not registered
- **No green badge**: No active transition animating

---

## Troubleshooting Common Issues

### Hot-Reload in Previews

**Problem**: Indicator disappears when hot-reloading SwiftUI Previews

**Expected Behavior**:
- Indicator should persist after hot-reload
- Brief flicker is normal as window recreates

**If indicator doesn't reappear**:
- Check Xcode console for error messages
- Verify `PortalContainer` is still in view hierarchy
- Try full preview restart (⌘+Option+P)

### Too Many Indicators

**Problem**: Multiple pink "PortalContainerOverlay" badges or excessive borders

**Cause**:
- Multiple `PortalContainer` instances in view hierarchy
- Many portal sources/destinations on screen

**Solution**:
- Use only one `PortalContainer` per window/scene
- Audit for accidental nested PortalContainer wrappers (or lingering `.portalContainer()` usage)
- This is expected if you have many portals (like in a grid)

### Indicators Block UI

**Problem**: Debug overlays cover important UI elements

**Solution**:
- Build in Release mode for final UI testing (indicators auto-hidden)
- Or temporarily comment out debug code in source files

---

## Console Logging

Portal provides structured logging through [`PortalLogs`](https://github.com/Aeastr/Portal#logging--diagnostics), powered by [LogOutLoud](https://github.com/Aeastr/LogOutLoud).

```swift
PortalLogs.logger.log(
    "Overlay installed",
    level: .info,
    tags: [PortalLogs.Tags.overlay]
)
```

- Logs surface lifecycle events from `PortalContainer`, overlay management, and transition state changes.
- In DEBUG builds all levels are enabled; Release builds default to notices and above.
- Call `PortalLogs.configure(allowedLevels:)` during app launch to tighten or expand filtering.
- Want an on-device console? Add the `LogOutLoudConsole` product and apply `.logConsole(enabled: true, logger: PortalLogs.logger)` (or call `PortalLogs.enableConsole()` manually) to power `LogConsolePanel()` or a custom viewer.

---

## Performance Impact

The debug indicator has **zero performance impact** on production builds:

- Compiled out with `#if DEBUG`
- No runtime checks
- No overhead in Release builds
- Safe to leave in codebase

---

## Common Debug Scenarios

### Verifying Overlay Installation

**Test**: Open any example with Portal
**Expected**: Pink badge appears immediately
**Action**: If missing, check `PortalContainer` is in view hierarchy

### Testing Hot-Reload

**Test**: Make small code change in Preview
**Expected**: Badge flickers briefly, then reappears
**Action**: If badge doesn't return, see "Hot-Reload in Previews" above

### Confirming Cleanup

**Test**: Dismiss sheet/navigation containing `PortalContainer`
**Expected**: Badge disappears when view dismissed
**Action**: If badge persists, check for leaked overlay window

---

➡️ [Back to Usage](./Usage) | [How Portal Works](./How-Portal-Works)
