//
//  FlowingHeaderTokens.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Design tokens and constants for the FlowingHeader animation system.
///
/// This struct provides centralized configuration for timing and animations
/// used throughout the FlowingHeader component.
public struct FlowingHeaderTokens {
    // MARK: - Animation Timing

    /// Default animation duration for flowing header transitions.
    ///
    /// Used for scale, opacity, and position animations as the header flows to the navigation bar.
    public static let transitionDuration: TimeInterval = 0.4

    /// Animation duration for scroll-driven progress updates.
    ///
    /// Shorter duration provides more responsive tracking during active scrolling.
    public static let scrollAnimationDuration: TimeInterval = 0.3
}
