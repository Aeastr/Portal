//
//  PortalDebugOverlaysKey.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Debug Style

/// Visual styles for portal transition debug overlays.
public struct PortalTransitionDebugStyle: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show text label indicators
    public static let label = PortalTransitionDebugStyle(rawValue: 1 << 0)
    /// Show border outlines
    public static let border = PortalTransitionDebugStyle(rawValue: 1 << 1)
    /// Show background highlights
    public static let background = PortalTransitionDebugStyle(rawValue: 1 << 2)

    /// Show all debug styles
    public static let all: PortalTransitionDebugStyle = [.label, .border, .background]
    /// Show no debug styles
    public static let none: PortalTransitionDebugStyle = []
}

// MARK: - Debug Target

/// Targets for portal transition debug overlays.
public struct PortalTransitionDebugTarget: OptionSet, Sendable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show overlays on source views
    public static let source = PortalTransitionDebugTarget(rawValue: 1 << 0)
    /// Show overlays on destination views
    public static let destination = PortalTransitionDebugTarget(rawValue: 1 << 1)
    /// Show overlays on the animated layer
    public static let layer = PortalTransitionDebugTarget(rawValue: 1 << 2)

    /// Show overlays on all targets
    public static let all: PortalTransitionDebugTarget = [.source, .destination, .layer]
}

// MARK: - Settings Storage

/// Storage for debug overlay settings per target.
public struct PortalTransitionDebugSettings: Sendable {
    private var settings: [PortalTransitionDebugTarget: PortalTransitionDebugStyle]

    public init() {
        self.settings = [:]
    }

    /// Gets the debug style for a specific target.
    public func style(for target: PortalTransitionDebugTarget) -> PortalTransitionDebugStyle {
        // Check for exact match first
        if let exact = settings[target] {
            return exact
        }

        // Check if this target is included in a broader setting
        for (key, value) in settings {
            if key.contains(target) {
                return value
            }
        }

        return .none
    }

    /// Sets the debug style for specific targets.
    public mutating func set(_ style: PortalTransitionDebugStyle, for targets: PortalTransitionDebugTarget) {
        if targets == .all {
            settings = [.all: style]
        } else {
            // Expand .all if it exists
            if let allStyle = settings[.all] {
                settings.removeValue(forKey: .all)
                if !targets.contains(.source) { settings[.source] = allStyle }
                if !targets.contains(.destination) { settings[.destination] = allStyle }
                if !targets.contains(.layer) { settings[.layer] = allStyle }
            }
            settings[targets] = style
        }
    }
}

// MARK: - Environment Key

private struct PortalTransitionDebugSettingsKey: EnvironmentKey {
    static let defaultValue = PortalTransitionDebugSettings()
}

public extension EnvironmentValues {
    /// The current portal transition debug overlay settings.
    var portalTransitionDebugSettings: PortalTransitionDebugSettings {
        get { self[PortalTransitionDebugSettingsKey.self] }
        set { self[PortalTransitionDebugSettingsKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Enables or disables all portal transition debug overlays.
    ///
    /// - Parameter enabled: Whether to show debug overlays for all targets.
    ///
    /// **Example:**
    /// ```swift
    /// ContentView()
    ///     .portalTransitionDebugOverlays(true)
    /// ```
    func portalTransitionDebugOverlays(_ enabled: Bool) -> some View {
        portalTransitionDebugOverlays(enabled ? .all : .none, for: .all)
    }

    /// Controls which debug overlay styles are shown for specific targets.
    ///
    /// - Parameters:
    ///   - style: The visual styles to show (label, border, background).
    ///   - targets: Which portal elements to show overlays on (source, destination, layer).
    ///
    /// **Examples:**
    /// ```swift
    /// // Show labels on sources only
    /// ContentView()
    ///     .portalTransitionDebugOverlays([.label], for: .source)
    ///
    /// // Show borders on everything
    /// ContentView()
    ///     .portalTransitionDebugOverlays([.border], for: .all)
    ///
    /// // Show all styles on source and destination
    /// ContentView()
    ///     .portalTransitionDebugOverlays(.all, for: [.source, .destination])
    /// ```
    func portalTransitionDebugOverlays(
        _ style: PortalTransitionDebugStyle,
        for targets: PortalTransitionDebugTarget
    ) -> some View {
        transformEnvironment(\.portalTransitionDebugSettings) { settings in
            settings.set(style, for: targets)
        }
    }
}
