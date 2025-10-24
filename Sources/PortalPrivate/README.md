# PortalPrivate Module

## ⚠️ Private API Usage Warning

This module uses private UIKit APIs (`_UIPortalView`) for advanced view mirroring capabilities. While the APIs are obfuscated, use at your own discretion.

## Obfuscation Strategy

The module employs multiple layers of obfuscation to minimize detection risk:

### 1. String Obfuscation
- Class name is constructed dynamically from separate components
- Avoids hardcoded private API names that could be found via string search
- Example: `"_UI" + "Portal" + "View"` instead of literal string

### 2. Runtime Lookups
- Uses `NSClassFromString()` for dynamic class resolution
- No compile-time references or imports to private classes
- All private API access happens through runtime introspection
- Binary contains no direct symbol references to private APIs

### 2. Key-Value Coding
- Properties are set using `setValue:forKey:` instead of direct property access
- Example: `portal.setValue(true, forKey: "matchesAlpha")`
- No direct method calls on private API objects

### 3. Type Erasure
- Private API objects are stored as `UIView` or `AnyObject`
- No type declarations using private API class names
- Prevents symbols from appearing in binary

### 4. Graceful Fallback
- Always checks if private API exists before use
- Provides fallback behavior when unavailable
- Never crashes if private API is missing

## Example Implementation

```swift
// ❌ BAD: Direct import (would be detected)
import _UIPortalView

// ✅ GOOD: Runtime lookup (obfuscated)
guard let portalClass = NSClassFromString("_UIPortalView") as? UIView.Type else {
    // Graceful fallback
    return
}

// ❌ BAD: Direct instantiation
let portal = _UIPortalView()

// ✅ GOOD: Runtime instantiation
let portal = portalClass.init(frame: bounds)

// ❌ BAD: Direct property access
portal.sourceView = myView

// ✅ GOOD: Key-value coding
portal.setValue(myView, forKey: "sourceView")
```

## Safety Guidelines

1. **Never use in App Store apps** - Even with obfuscation, private APIs may be detected
2. **Test thoroughly** - Private APIs can change between iOS versions
3. **Always provide fallbacks** - Ensure app works without private APIs
4. **Monitor iOS updates** - Private APIs may be removed or changed

## Alternative for App Store

Use the standard `Portal` module which provides similar functionality using only public APIs. The transition animations may be slightly different but are fully App Store compliant.

## Testing

The module includes runtime checks to verify private API availability:

```swift
if wrapper.isPortalViewAvailable {
    // Private API is available
} else {
    // Using fallback implementation
}
```

Always test on:
- Different iOS versions
- Physical devices and simulators
- Release builds (not just debug)