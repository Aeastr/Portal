# Roadmap

## 5.0 - Module Restructuring & Naming Refactor

The current module structure will be reorganized for better clarity and discoverability while keeping private APIs separate for binary safety.

### Planned Changes

**Public API Modules**
- `Portal` → `PortalTransitions`
  - Discrete, event-based transitions (sheets, navigation stacks, modals)
  - Standard SwiftUI APIs, no private dependencies

- `PortalFlowingHeader` → `PortalHeaders`
  - Scroll-based header transitions that flow into navigation bars
  - Progressive, continuous transitions driven by scroll position
  - iOS 18+ for advanced scroll tracking

**Private API Module**
- `PortalView` + `PortalPrivate` → `_PortalMirror`
  - Provides `_UIPortalView` primitive and a `PortalTransitions`-style API that uses it
  - **View**: Low-level `_UIPortalView` wrapper for direct UIKit integration
  - **Transitions**: Wrapper around `PortalTransitions` that uses view mirroring for perfect state preservation
  - Same API as `PortalTransitions`, but with single shared view instance (same size at source/destination)
  - ⚠️ Private API - obfuscated for App Store compliance
  - `_` prefix follows Swift convention for private/internal APIs
  - Kept separate to avoid forcing private API into all binaries

### Rationale

**Clearer naming:**
- `PortalTransitions` clearly describes discrete transitions
- `PortalHeaders` describes what it does (header transitions)
- `_PortalMirror` groups all private API functionality with conventional `_` warning prefix

**Binary safety:**
- Public modules (`PortalTransitions`, `PortalHeaders`) have no private API code
- Private API isolated to `_PortalMirror` - users opt-in explicitly
- No risk of accidentally including obfuscated code

**Better discoverability:**
- Clear separation: transitions vs headers vs mirroring
- Each module has a single, focused purpose
- Easier to find what you need

**Why breaking change?**
Module renames require users to update `import` statements. Unlike type-level changes, modules cannot be deprecated or aliased gradually. This requires a major version bump.

### Internal Structure

```
PortalTransitions/
  ├── PortalSource.swift
  ├── PortalDestination.swift
  ├── PortalContainer.swift
  ├── Transitions/
  └── Shared/
      ├── AnchorKey.swift
      ├── DebugOverlays.swift
      └── PortalLogs.swift

PortalHeaders/
  ├── PortalHeaderView.swift
  ├── PortalHeaderDestination.swift
  ├── PortalHeaderContent.swift
  └── Shared/
      ├── AnchorKey.swift
      ├── DebugOverlays.swift
      └── PortalHeaderLogs.swift

_PortalMirror/
  ├── View/
  │   └── PortalView.swift
  └── Transitions/
      └── PortalPrivate.swift
```

### Timeline

Active development - targeting 5.0.0 release after refactor completion.
