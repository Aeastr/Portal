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

// MARK: - Debug Overlay Component

/// Components that can be shown in debug overlays.
public struct PortalDebugOverlayComponent: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show the text label indicator
    public static let label = PortalDebugOverlayComponent(rawValue: 1 << 0)
    /// Show the border outline
    public static let border = PortalDebugOverlayComponent(rawValue: 1 << 1)

    /// Show all debug overlay components
    public static let all: PortalDebugOverlayComponent = [.label, .border]
    
    public static let none: PortalDebugOverlayComponent = []
}

// MARK: - Debug Overlays Environment Key

/// Environment key for controlling which debug overlay components are shown.
private struct PortalDebugOverlaysKey: EnvironmentKey {
    static let defaultValue: PortalDebugOverlayComponent = .none
}

public extension EnvironmentValues {
    /// Controls which portal debug overlay components are shown.
    ///
    /// Debug overlays are only visible in DEBUG builds. This environment value
    /// provides control over which components to show.
    ///
    /// **Default:** `.all` (both label and border shown in DEBUG builds)
    ///
    /// **Usage:**
    /// ```swift
    /// ContentView()
    ///     .environment(\.portalDebugOverlays, [.label])  // Label only
    /// ```
    var portalDebugOverlays: PortalDebugOverlayComponent {
        get { self[PortalDebugOverlaysKey.self] }
        set { self[PortalDebugOverlaysKey.self] = newValue }
    }
}

public extension View {
    /// Controls which portal debug overlay components are shown.
    ///
    /// Debug overlays are visual indicators that show portal sources and
    /// destinations. They are only visible in DEBUG builds.
    ///
    /// - Parameter showing: The set of debug overlay components to show.
    ///
    /// **Examples:**
    /// ```swift
    /// // Show both label and border (default)
    /// ContentView()
    ///     .portalDebugOverlays(showing: [.label, .border])
    ///
    /// // Show only labels
    /// ContentView()
    ///     .portalDebugOverlays(showing: [.label])
    ///
    /// // Hide all overlays
    /// ContentView()
    ///     .portalDebugOverlays(showing: [])
    /// ```
    func portalDebugOverlays(showing: PortalDebugOverlayComponent) -> some View {
        environment(\.portalDebugOverlays, showing)
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
        environment(\.portalDebugOverlays, enabled ? .all : .none)
    }
}
