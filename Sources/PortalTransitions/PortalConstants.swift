//
//  PortalConstants.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Design tokens and constants for the Portal animation system.
///
/// This struct provides centralized configuration for timing, animations, and other
/// constants used throughout the Portal framework. These values are carefully tuned
/// for optimal visual performance and consistency.
public struct PortalConstants {
    // MARK: - Timing

    /// Standard delay before portal animations begin.
    ///
    /// This small delay allows for:
    /// - View hierarchy updates to complete
    /// - Layout calculations to settle
    /// - Smooth visual transitions without flicker
    public static let animationDelay: TimeInterval = 0.05

    /// Default animation duration for portal transitions.
    ///
    /// This duration is calibrated to match iOS system animations like sheet presentations.
    /// Using shorter durations (0.1-0.3s) with sheets can cause visual artifacts.
    public static let defaultAnimationDuration: TimeInterval = 0.38

    /// Minimum duration for sheet-compatible animations.
    ///
    /// Portal transitions used with sheets should not be shorter than this
    /// to avoid visual shifts when the portal completes before the sheet.
    public static let minimumSheetAnimationDuration: TimeInterval = 0.35

    // MARK: - Cache Configuration

    /// Maximum number of portal info entries to keep in memory cache.
    ///
    /// This limit prevents unbounded memory growth while keeping frequently
    /// accessed portals performant.
    public static let portalCacheLimit: Int = 10

    // MARK: - Debug

    /// Default debug overlay stroke width
    public static let debugOverlayStrokeWidth: CGFloat = 2

    /// Default debug overlay corner radius
    public static let debugOverlayCornerRadius: CGFloat = 4

    /// Default debug overlay padding
    public static let debugOverlayPadding: CGFloat = 5
}
