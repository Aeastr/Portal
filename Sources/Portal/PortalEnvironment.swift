import SwiftUI

// MARK: - Portal Corners Environment Key

/// Environment key for default portal corner radius configuration.
///
/// This allows setting default corner radii for all portal transitions
/// in a view hierarchy, which can be overridden by specific transitions.
private struct PortalCornersKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: PortalCorners? = nil
}

// MARK: - Debug Overlays Environment Key

/// Environment key for controlling the visibility of debug overlays.
///
/// Debug overlays show visual indicators for portal sources (blue) and destinations (orange)
/// with labels. By default, overlays are shown in DEBUG builds but can be disabled
/// using the `.portalDebugOverlays(enabled:)` modifier.
private struct PortalDebugOverlaysKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

public extension EnvironmentValues {
    /// Default corner radius configuration for portal transitions.
    ///
    /// This provides a default corner configuration that will be used
    /// by all portal transitions in the view hierarchy unless overridden
    /// by specific transition parameters.
    ///
    /// **Default:** `nil` (no corner radius applied)
    ///
    /// **Usage:**
    /// ```swift
    /// ContentView()
    ///     .environment(\.portalCorners, PortalCorners(source: 8, destination: 16))
    /// ```
    var portalCorners: PortalCorners? {
        get { self[PortalCornersKey.self] }
        set { self[PortalCornersKey.self] = newValue }
    }

    /// Controls whether portal debug overlays are shown.
    ///
    /// Debug overlays are only visible in DEBUG builds. This environment value
    /// provides an additional control to hide them even in DEBUG builds.
    ///
    /// **Default:** `true` (overlays shown in DEBUG builds)
    ///
    /// **Usage:**
    /// ```swift
    /// ContentView()
    ///     .environment(\.portalDebugOverlays, false)
    /// ```
    var portalDebugOverlays: Bool {
        get { self[PortalDebugOverlaysKey.self] }
        set { self[PortalDebugOverlaysKey.self] = newValue }
    }
}

public extension View {
    /// Sets the default corner radius configuration for portal transitions.
    ///
    /// This modifier allows you to set a default corner configuration that will
    /// be used by all portal transitions in child views unless overridden.
    ///
    /// - Parameter corners: The default corner configuration to use.
    ///
    /// **Example:**
    /// ```swift
    /// ContentView()
    ///     .portalCorners(source: 8, destination: 16, style: .continuous)
    /// ```
    func portalCorners(source: CGFloat, destination: CGFloat, style: RoundedCornerStyle = .circular) -> some View {
        environment(\.portalCorners, PortalCorners(source: source, destination: destination, style: style))
    }

    /// Sets the default corner radius configuration for portal transitions.
    ///
    /// - Parameter corners: The corner configuration to use.
    ///
    /// **Example:**
    /// ```swift
    /// let corners = PortalCorners(source: 8, destination: 16)
    /// ContentView()
    ///     .portalCorners(corners)
    /// ```
    func portalCorners(_ corners: PortalCorners?) -> some View {
        environment(\.portalCorners, corners)
    }

    /// Controls whether portal debug overlays are shown.
    ///
    /// Debug overlays are visual indicators that show portal sources (blue) and
    /// destinations (orange) with labels. They are only visible in DEBUG builds.
    /// This modifier provides a convenient way to disable them.
    ///
    /// - Parameter enabled: Whether to show debug overlays. Default is `true`.
    ///
    /// **Example:**
    /// ```swift
    /// ContentView()
    ///     .portalDebugOverlays(enabled: false)
    /// ```
    func portalDebugOverlays(enabled: Bool) -> some View {
        environment(\.portalDebugOverlays, enabled)
    }
}
