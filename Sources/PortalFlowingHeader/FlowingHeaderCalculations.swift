//
//  FlowingHeaderCalculations.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

/// Pure calculation utilities for flowing header animations.
///
/// This struct provides testable, stateless functions for computing animation
/// progress, offsets, and positions used in flowing header transitions.
public struct FlowingHeaderCalculations {
    // MARK: - Progress Calculation

    /// Calculates transition progress based on scroll offset.
    ///
    /// The progress value represents how far along the transition should be,
    /// from 0.0 (not started) to 1.0 (fully transitioned).
    ///
    /// - Parameters:
    ///   - scrollOffset: Current scroll offset (positive when scrolled down)
    ///   - startAt: Scroll offset where transition begins
    ///   - range: Distance over which transition occurs
    /// - Returns: Progress value clamped between 0.0 and 1.0
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Transition starts at -20, completes over 40 points
    /// let progress = FlowingHeaderCalculations.calculateProgress(
    ///     scrollOffset: 0,
    ///     startAt: -20,
    ///     range: 40
    /// )
    /// // Returns: 0.5 (halfway through transition)
    /// ```
    public static func calculateProgress(
        scrollOffset: CGFloat,
        startAt: CGFloat,
        range: CGFloat
    ) -> Double {
        // If we haven't scrolled down enough past the start threshold, return 0
        guard scrollOffset >= startAt else {
            return 0.0
        }

        // Guard against division by zero
        guard range != 0 else {
            return 1.0 // Consider fully transitioned if range is zero
        }

        // Calculate progress over the transition range
        let rawProgress = (scrollOffset - startAt) / range

        // Clamp progress between 0.0 and 1.0
        return Double(max(0.0, min(1.0, rawProgress)))
    }

    // MARK: - Position Interpolation

    /// Calculates interpolated position between source and destination rectangles.
    ///
    /// Linearly interpolates the midpoint of two rectangles based on progress,
    /// with an optional horizontal offset applied.
    ///
    /// - Parameters:
    ///   - sourceRect: Starting rectangle bounds
    ///   - destinationRect: Ending rectangle bounds
    ///   - progress: Transition progress (0-1)
    ///   - horizontalOffset: Additional horizontal offset to apply (default: 0)
    /// - Returns: Interpolated position point
    ///
    /// ## Example
    ///
    /// ```swift
    /// let position = FlowingHeaderCalculations.calculatePosition(
    ///     sourceRect: CGRect(x: 0, y: 0, width: 100, height: 100),
    ///     destinationRect: CGRect(x: 200, y: 400, width: 50, height: 50),
    ///     progress: 0.5
    /// )
    /// // Returns: CGPoint(x: 100, y: 200) - midpoint between centers
    /// ```
    public static func calculatePosition(
        sourceRect: CGRect,
        destinationRect: CGRect,
        progress: CGFloat,
        horizontalOffset: CGFloat = 0
    ) -> CGPoint {
        let baseX = sourceRect.midX + (destinationRect.midX - sourceRect.midX) * progress
        let x = baseX + horizontalOffset
        let y = sourceRect.midY + (destinationRect.midY - sourceRect.midY) * progress
        return CGPoint(x: x, y: y)
    }

    // MARK: - Scale Calculation

    /// Calculates interpolated scale factor between two sizes.
    ///
    /// Computes independent scale factors for width and height to transform
    /// from source size to destination size.
    ///
    /// - Parameters:
    ///   - sourceSize: Starting size
    ///   - destinationSize: Ending size
    ///   - progress: Transition progress (0-1)
    /// - Returns: Scale factors for x and y dimensions
    ///
    /// ## Example
    ///
    /// ```swift
    /// let scale = FlowingHeaderCalculations.calculateScale(
    ///     sourceSize: CGSize(width: 100, height: 100),
    ///     destinationSize: CGSize(width: 50, height: 50),
    ///     progress: 0.5
    /// )
    /// // Returns: (x: 0.75, y: 0.75) - halfway to 0.5 scale
    /// ```
    public static func calculateScale(
        sourceSize: CGSize,
        destinationSize: CGSize,
        progress: CGFloat
    ) -> (x: CGFloat, y: CGFloat) {
        // Guard against division by zero
        // Returns identity scale (1.0, 1.0) for invalid source size to:
        // - Prevent crashes from division by zero
        // - Maintain visual stability (no scaling applied)
        // - Allow graceful degradation when views haven't laid out yet
        guard sourceSize.width > 0 && sourceSize.height > 0 else {
            return (1.0, 1.0)
        }

        let targetWidth = sourceSize.width + (destinationSize.width - sourceSize.width) * progress
        let targetHeight = sourceSize.height + (destinationSize.height - sourceSize.height) * progress

        let scaleX = targetWidth / sourceSize.width
        let scaleY = targetHeight / sourceSize.height

        return (scaleX, scaleY)
    }
}
