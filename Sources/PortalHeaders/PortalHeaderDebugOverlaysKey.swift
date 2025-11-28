//
//  PortalHeaderDebugOverlaysKey.swift
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
@available(iOS 18.0, *)
public struct PortalHeaderDebugOverlayComponent: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show the text label indicator
    public static let label = PortalHeaderDebugOverlayComponent(rawValue: 1 << 0)
    /// Show the border outline
    public static let border = PortalHeaderDebugOverlayComponent(rawValue: 1 << 1)

    /// Show all debug overlay components
    public static let all: PortalHeaderDebugOverlayComponent = [.label, .border]
    
    public static let none: PortalHeaderDebugOverlayComponent = []
}

// MARK: - Debug Overlays Environment Key

/// Environment key for controlling which debug overlay components are shown.
@available(iOS 18.0, *)
private struct PortalHeaderDebugOverlaysKey: EnvironmentKey {
    static let defaultValue: PortalHeaderDebugOverlayComponent = .none
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    /// Controls which flowing header debug overlay components are shown.
    ///
    /// Debug overlays are only visible in DEBUG builds. This environment value
    /// provides control over which components to show.x
    ///
    /// **Default:** `.all` (both label and border shown in DEBUG builds)
    ///
    /// **Usage:**
    /// ```swift
    /// ContentView()
    ///     .environment(\.portalHeaderDebugOverlays, [.label])  // Label only
    /// ```
    var portalHeaderDebugOverlays: PortalHeaderDebugOverlayComponent {
        get { self[PortalHeaderDebugOverlaysKey.self] }
        set { self[PortalHeaderDebugOverlaysKey.self] = newValue }
    }
}

@available(iOS 18.0, *)
public extension View {
    /// Controls which flowing header debug overlay components are shown.
    ///
    /// Debug overlays are visual indicators that show header sources and
    /// destinations. They are only visible in DEBUG builds.
    ///
    /// - Parameter showing: The set of debug overlay components to show.
    ///
    /// **Examples:**
    /// ```swift
    /// // Show both label and border (default)
    /// ContentView()
    ///     .portalHeaderDebugOverlays(showing: [.label, .border])
    ///
    /// // Show only labels
    /// ContentView()
    ///     .portalHeaderDebugOverlays(showing: [.label])
    ///
    /// // Hide all overlays
    /// ContentView()
    ///     .portalHeaderDebugOverlays(showing: [])
    /// ```
    func portalHeaderDebugOverlays(showing: PortalHeaderDebugOverlayComponent) -> some View {
        environment(\.portalHeaderDebugOverlays, showing)
    }

    /// Controls whether flowing header debug overlays are shown.
    ///
    /// Debug overlays are visual indicators that show header sources and
    /// destinations with labels. They are only visible in DEBUG builds.
    /// This modifier provides a convenient way to disable them.
    ///
    /// - Parameter enabled: Whether to show debug overlays. Default is `true`.
    ///
    /// **Example:**
    /// ```swift
    /// ContentView()
    ///     .portalHeaderDebugOverlays(enabled: false)
    /// ```
    func portalHeaderDebugOverlays(enabled: Bool) -> some View {
        environment(\.portalHeaderDebugOverlays, enabled ? .all : [])
    }
}
