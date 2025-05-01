//
//  PortalLogging.swift
//  Portal
//
//  Created by Aether on 01/05/2025.
//

import LogOutLoud
import Foundation

public enum PortalLogging {
    /// **Publicly accessible shared logger instance specifically for this package.**
    /// Applications consuming this package can access this property to configure log levels.
    public static let logger: Logger = Logger.shared(for: "portal.logging")
}
