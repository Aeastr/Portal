//
//  PortalLogs.swift
//  Portal
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

/// Central logging namespace for the Portal package.
///
/// Use `PortalLogs.logger` for emitting logs related to portal lifecycle events,
/// transitions, and diagnostics. Consumers can customise the logger configuration
/// by calling `PortalLogs.configure(...)` at app launch.
public enum PortalLogs {
    private static let registryKey = "dev.aeastr.portal"
    private static let bootstrap: Void = {
        let instance = Logger.shared(for: registryKey)
        instance.subsystem = registryKey
#if DEBUG
        instance.setAllowedLevels(Set(LogLevel.allCases))
#else
        instance.setAllowedLevels([.notice, .warning, .error, .fault])
#endif
    }()

    /// Shared logger instance dedicated to the Portal package.
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

    /// Commonly used logging tags for Portal internals.
    public enum Tags {
        public static let container = Tag("PortalContainer")
        public static let overlay = Tag("OverlayWindow")
        public static let transition = Tag("PortalTransition")
        public static let diagnostics = Tag("Diagnostics")
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
