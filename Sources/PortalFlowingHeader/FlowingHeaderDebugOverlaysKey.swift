//
//  FlowingHeaderDebugOverlaysKey.swift
//  PortalFlowingHeader
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
public struct FlowingHeaderDebugOverlayComponent: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show the text label indicator
    public static let label = FlowingHeaderDebugOverlayComponent(rawValue: 1 << 0)
    /// Show the border outline
    public static let border = FlowingHeaderDebugOverlayComponent(rawValue: 1 << 1)

    /// Show all debug overlay components
    public static let all: FlowingHeaderDebugOverlayComponent = [.label, .border]
}

// MARK: - Debug Overlays Environment Key

/// Environment key for controlling which debug overlay components are shown.
@available(iOS 18.0, *)
private struct FlowingHeaderDebugOverlaysKey: EnvironmentKey {
    static let defaultValue: FlowingHeaderDebugOverlayComponent = .all
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    /// Controls which flowing header debug overlay components are shown.
    ///
    /// Debug overlays are only visible in DEBUG builds. This environment value
    /// provides control over which components to show.
    ///
    /// **Default:** `.all` (both label and border shown in DEBUG builds)
    ///
    /// **Usage:**
    /// ```swift
    /// ContentView()
    ///     .environment(\.flowingHeaderDebugOverlays, [.label])  // Label only
    /// ```
    var flowingHeaderDebugOverlays: FlowingHeaderDebugOverlayComponent {
        get { self[FlowingHeaderDebugOverlaysKey.self] }
        set { self[FlowingHeaderDebugOverlaysKey.self] = newValue }
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
    ///     .flowingHeaderDebugOverlays(showing: [.label, .border])
    ///
    /// // Show only labels
    /// ContentView()
    ///     .flowingHeaderDebugOverlays(showing: [.label])
    ///
    /// // Hide all overlays
    /// ContentView()
    ///     .flowingHeaderDebugOverlays(showing: [])
    /// ```
    func flowingHeaderDebugOverlays(showing: FlowingHeaderDebugOverlayComponent) -> some View {
        environment(\.flowingHeaderDebugOverlays, showing)
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
    ///     .flowingHeaderDebugOverlays(enabled: false)
    /// ```
    func flowingHeaderDebugOverlays(enabled: Bool) -> some View {
        environment(\.flowingHeaderDebugOverlays, enabled ? .all : [])
    }
}
