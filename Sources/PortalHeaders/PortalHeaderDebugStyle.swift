//
//  PortalHeaderDebugStyle.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Debug Style

/// Visual styles for portal header debug overlays.
@available(iOS 18.0, *)
public struct PortalHeaderDebugStyle: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show text label indicators
    public static let label = PortalHeaderDebugStyle(rawValue: 1 << 0)
    /// Show border outlines
    public static let border = PortalHeaderDebugStyle(rawValue: 1 << 1)
    /// Show background highlights
    public static let background = PortalHeaderDebugStyle(rawValue: 1 << 2)

    /// Show all debug styles
    public static let all: PortalHeaderDebugStyle = [.label, .border, .background]
    /// Show no debug styles
    public static let none: PortalHeaderDebugStyle = []
}

// MARK: - Debug Target

/// Targets for portal header debug overlays.
@available(iOS 18.0, *)
public struct PortalHeaderDebugTarget: OptionSet, Sendable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Show overlays on source views (inline header content)
    public static let source = PortalHeaderDebugTarget(rawValue: 1 << 0)
    /// Show overlays on destination views (navigation bar)
    public static let destination = PortalHeaderDebugTarget(rawValue: 1 << 1)
    /// Show overlays on accessory views
    public static let accessory = PortalHeaderDebugTarget(rawValue: 1 << 2)

    /// Show overlays on all targets
    public static let all: PortalHeaderDebugTarget = [.source, .destination, .accessory]
}

// MARK: - Settings Storage

/// Storage for debug overlay settings per target.
@available(iOS 18.0, *)
public struct PortalHeaderDebugSettings: Sendable {
    private var settings: [PortalHeaderDebugTarget: PortalHeaderDebugStyle]

    public init() {
        self.settings = [:]
    }

    /// Gets the debug style for a specific target.
    public func style(for target: PortalHeaderDebugTarget) -> PortalHeaderDebugStyle {
        // Check for exact match first
        if let exact = settings[target] {
            return exact
        }

        // Check if this target is included in a broader setting
        for (key, value) in settings where key.contains(target) {
            return value
        }

        return .none
    }

    /// Sets the debug style for specific targets.
    public mutating func set(_ style: PortalHeaderDebugStyle, for targets: PortalHeaderDebugTarget) {
        if targets == .all {
            settings = [.all: style]
        } else {
            // Expand .all if it exists
            if let allStyle = settings[.all] {
                settings.removeValue(forKey: .all)
                if !targets.contains(.source) { settings[.source] = allStyle }
                if !targets.contains(.destination) { settings[.destination] = allStyle }
                if !targets.contains(.accessory) { settings[.accessory] = allStyle }
            }
            settings[targets] = style
        }
    }
}

// MARK: - Environment Key

@available(iOS 18.0, *)
private struct PortalHeaderDebugSettingsKey: EnvironmentKey {
    static let defaultValue = PortalHeaderDebugSettings()
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    /// The current portal header debug overlay settings.
    var portalHeaderDebugSettings: PortalHeaderDebugSettings {
        get { self[PortalHeaderDebugSettingsKey.self] }
        set { self[PortalHeaderDebugSettingsKey.self] = newValue }
    }
}

// MARK: - View Extension

@available(iOS 18.0, *)
public extension View {
    /// Enables or disables all portal header debug overlays.
    ///
    /// - Parameter enabled: Whether to show debug overlays for all targets.
    ///
    /// **Example:**
    /// ```swift
    /// ContentView()
    ///     .portalHeaderDebugOverlays(true)
    /// ```
    func portalHeaderDebugOverlays(_ enabled: Bool) -> some View {
        portalHeaderDebugOverlays(enabled ? .all : .none, for: .all)
    }

    /// Controls which debug overlay styles are shown for specific targets.
    ///
    /// - Parameters:
    ///   - style: The visual styles to show (label, border, background).
    ///   - targets: Which portal header elements to show overlays on (source, destination, accessory).
    ///
    /// **Examples:**
    /// ```swift
    /// // Show labels on sources only
    /// ContentView()
    ///     .portalHeaderDebugOverlays([.label], for: .source)
    ///
    /// // Show borders on everything
    /// ContentView()
    ///     .portalHeaderDebugOverlays([.border], for: .all)
    ///
    /// // Show all styles on source and destination
    /// ContentView()
    ///     .portalHeaderDebugOverlays(.all, for: [.source, .destination])
    /// ```
    func portalHeaderDebugOverlays(
        _ style: PortalHeaderDebugStyle,
        for targets: PortalHeaderDebugTarget
    ) -> some View {
        transformEnvironment(\.portalHeaderDebugSettings) { settings in
            settings.set(style, for: targets)
        }
    }
}
