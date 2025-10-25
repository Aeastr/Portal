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

    // MARK: - Scroll Calculation

    /// The range over which the transition progresses (in points).
    public static let transitionRange: CGFloat = 40

    /// Divisor for accessory height when calculating transition start point.
    ///
    /// When the accessory is flowing, the transition starts at `accessoryHeight / accessoryStartDivisor`.
    public static let accessoryStartDivisor: CGFloat = 3

    /// Fallback start offset when no accessory height is measured.
    public static let fallbackStartOffset: CGFloat = 5

    // MARK: - Visual Effects

    /// Multiplier for accelerating accessory fade/scale effects relative to scroll progress.
    ///
    /// Higher values make the accessory fade and scale more quickly during the transition.
    public static let accessoryFadeMultiplier: CGFloat = 4

    /// Target size for accessory views in the navigation bar (in points).
    public static let navigationBarAccessorySize: CGFloat = 25
}
