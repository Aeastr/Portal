# Roadmap

## 5.0 - Module Naming Refactor

The current module structure has naming inconsistencies that should be addressed in the next major version:

### Planned Renames

- `Portal` → `PortalTransitions`
- `PortalFlowingHeader` → `PortalHeader`
- `PortalView` → `PortalMirrorView`
- `PortalPrivate` → `PortalMirrorTransitions`

### Why Not 4.x?

Module renames are inherently breaking changes that require users to update their `import` statements. Unlike type-level changes, modules cannot be deprecated or aliased gradually. This requires a major version bump.

### Timeline

TBD - will be planned after 4.x stabilization period.
