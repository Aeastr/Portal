# _PortalPrivate

> **WARNING: Private API — Use at Your Own Risk**
>
> This module uses Apple's private `_UIPortalView` API. Apps using private APIs **may be rejected by App Store Review** or break without warning in future iOS updates.
>
> **By using this module, you acknowledge and accept:**
> - Your app may be rejected during App Store review
> - The API may change or break in any iOS update
> - Portal, Aether, and any maintainers assume **no responsibility** for App Store rejections, app crashes, runtime failures, or any other issues arising from private API usage
>
> **Use at your own discretion. You accept full responsibility for any consequences.**

Class names are obfuscated at compile-time to reduce detection likelihood, but this is not a guarantee of App Store approval.

---

`_PortalPrivate` provides the same API as PortalTransitions but uses Apple's private `_UIPortalView` for true view mirroring instead of layer snapshots.

## Differences from PortalTransitions

| | PortalTransitions | _PortalPrivate |
|---|---|---|
| **Implementation** | Layer snapshots | `_UIPortalView` mirroring |
| **State preservation** | Snapshot at transition start | Live view instance |
| **View size** | Can differ between source/dest | Must match at source/dest |
| **API type** | Public SwiftUI APIs | Private UIKit API (obfuscated) |

## Usage

Same API as PortalTransitions - just swap the import:

```swift
import _PortalPrivate

// Source
PortalPrivate(id: "item") {
    MyView()
}

// Destination
PortalPrivateDestination(id: "item")

// Transition modifier
.portalPrivateTransition(item: $selectedItem)
```

## Obfuscation

Class names are obfuscated at compile-time using the [Obfuscate](https://github.com/Aeastr/Obfuscate) macro. The string is converted to a base64-encoded byte array during compilation and decoded at runtime, preventing direct string matching in the binary.
