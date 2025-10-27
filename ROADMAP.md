# Roadmap

## 5.0 - Module Unification & Naming Refactor

The current module structure splits related functionality across separate targets. Version 5.0 will consolidate and rename modules for better clarity and discoverability.

### Planned Changes

**Transitions Module** (Unified)
- `Portal` + `PortalFlowingHeader` → `PortalTransitions`
  - **Discrete Transitions**: Event-based transitions (sheets, navigation)
  - **Progressive Transitions**: Progress-driven transitions (scroll-based, gesture-driven)
  - Shared utilities: anchor keys, debug overlays, logging, animation tokens

**Mirroring Modules** (Renamed)
- `PortalView` → `PortalMirrorView`
- `PortalPrivate` → `PortalMirrorTransitions`

### Rationale

**Why unify transitions?**
- Both solve the same problem (view transitions) with different input mechanisms
- Single import: `import PortalTransitions`
- Better feature discoverability
- Shared code and consistent API surface

**Why separate modules?**
Module renames are inherently breaking changes that require users to update their `import` statements. Unlike type-level changes, modules cannot be deprecated or aliased gradually. This requires a major version bump.

### Internal Structure

```
PortalTransitions/
  ├── Discrete/          # Event-based (current Portal)
  │   ├── PortalSource.swift
  │   ├── PortalDestination.swift
  │   └── PortalContainer.swift
  ├── Progressive/       # Progress-based (current FlowingHeader)
  │   ├── FlowingHeader/
  │   │   ├── FlowingHeaderView.swift
  │   │   ├── FlowingHeaderDestination.swift
  │   │   └── FlowingHeaderContent.swift
  │   └── [Future: gesture-driven, etc.]
  └── Shared/
      ├── AnchorKey.swift
      ├── DebugOverlays.swift
      ├── Logging.swift
      └── Tokens.swift
```

### Timeline

Active development - targeting 5.0.0 release after refactor completion.
