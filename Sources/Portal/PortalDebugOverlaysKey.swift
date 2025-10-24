//
//  PortalEnvironment.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

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
