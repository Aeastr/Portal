//
//  PortalHeaderLogs.swift
//  PortalPortalHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import LogOutLoud
#if canImport(LogOutLoudConsole)
import LogOutLoudConsole
#endif

/// Central logging namespace for the PortalPortalHeader package.
///
/// Use `PortalHeaderLogs.logger` for emitting logs related to scroll tracking,
/// snapping behavior, and transition diagnostics. Consumers can customize the
/// logger configuration by calling `PortalHeaderLogs.configure(...)` at app launch.
public enum PortalHeaderLogs {
    private static let registryKey = "package.aeastr.portal.portalHeader"
    private static let bootstrap: Void = {
        let instance = Logger.shared(for: registryKey)
        instance.subsystem = registryKey
// #if DEBUG
//        instance.setAllowedLevels(Set(LogLevel.allCases))
// #else
//        instance.setAllowedLevels([.notice, .warning, .error, .fault])
// #endif
        instance.setAllowedLevels([.notice, .warning, .error, .fault])
        // we have disabled some levels by default to avoid spamming the console, they can still be enabled if need be, but this is less likely
    }()

    /// Shared logger instance dedicated to the PortalPortalHeader package.
    public static var logger: Logger {
        _ = bootstrap
        return Logger.shared(for: registryKey)
    }

    /// Allows callers to override the default logger configuration.
    /// - Parameters:
    ///   - subsystem: Optional custom subsystem to apply to the logger.
    ///   - allowedLevels: Optional custom set of allowed log levels.
    public static func configure(subsystem: String? = nil, allowedLevels: Set<LogLevel>? = nil) {
        let instance = logger
        if let subsystem { instance.subsystem = subsystem }
        if let allowedLevels { instance.setAllowedLevels(allowedLevels) }
    }

    /// Commonly used logging tags for PortalHeader internals.
    public enum Tags {
        public static let scroll = Tag("Scroll")
        public static let snapping = Tag("Snapping")
        public static let transition = Tag("Transition")
        public static let anchors = Tag("Anchors")
    }

#if canImport(LogOutLoudConsole)
    /// Enables the optional in-app log console backed by LogOutLoudConsole.
    /// - Parameter maxEntries: Maximum number of log entries to retain.
    /// - Returns: The underlying console store so apps can present `LogConsolePanel`.
    @MainActor
    @discardableResult
    public static func enableConsole(maxEntries: Int = 2_000) -> LogConsoleStore {
        logger.enableConsole(maxEntries: maxEntries)
    }
#endif
}
