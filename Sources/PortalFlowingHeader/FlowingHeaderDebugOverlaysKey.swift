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

// MARK: - Debug Overlays Environment Key

/// Environment key for controlling the visibility of flowing header debug overlays.
///
/// Debug overlays show visual indicators for header sources and destinations
/// with labels. By default, overlays are shown in DEBUG builds but can be disabled
/// using the `.flowingHeaderDebugOverlays(enabled:)` modifier.
@available(iOS 18.0, *)
private struct FlowingHeaderDebugOverlaysKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    /// Controls whether flowing header debug overlays are shown.
    ///
    /// Debug overlays are only visible in DEBUG builds. This environment value
    /// provides an additional control to hide them even in DEBUG builds.
    ///
    /// **Default:** `true` (overlays shown in DEBUG builds)
    ///
    /// **Usage:**
    /// ```swift
    /// ContentView()
    ///     .environment(\.flowingHeaderDebugOverlays, false)
    /// ```
    var flowingHeaderDebugOverlays: Bool {
        get { self[FlowingHeaderDebugOverlaysKey.self] }
        set { self[FlowingHeaderDebugOverlaysKey.self] = newValue }
    }
}

@available(iOS 18.0, *)
public extension View {
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
        environment(\.flowingHeaderDebugOverlays, enabled)
    }
}
