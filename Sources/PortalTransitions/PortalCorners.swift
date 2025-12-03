//
//  PortalCorners.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Corner radius configuration for portal transition elements.
///
/// This struct defines the corner styling for both the source and destination
/// elements of a portal transition. It allows for smooth interpolation between
/// different corner radius values during the animation, creating visually
/// cohesive transitions even when source and destination have different styling.
///
/// **Corner Interpolation:**
/// During the transition, the corner radius is smoothly interpolated from the
/// source value to the destination value, ensuring visual continuity throughout
/// the animation.
///
/// **Style Consistency:**
/// The corner style (circular vs. continuous) is applied uniformly to maintain
/// visual consistency with the rest of the application's design language.
public struct PortalCorners {
    /// Corner radius for the source (starting) element, in points.
    ///
    /// This value defines the corner radius of the element at the beginning
    /// of the portal transition. The animation will start with this radius
    /// and interpolate toward the destination radius.
    ///
    /// A value of 0 creates sharp corners (rectangular appearance).
    public let source: CGFloat

    /// Corner radius for the destination (ending) element, in points.
    ///
    /// This value defines the corner radius of the element at the end
    /// of the portal transition. The animation will interpolate from the
    /// source radius to this target radius.
    ///
    /// A value of 0 creates sharp corners (rectangular appearance).
    public let destination: CGFloat

    /// The style of corner rounding to apply.
    ///
    /// Defines the mathematical curve used for creating rounded corners.
    /// This affects the visual appearance of the corners during the entire
    /// transition animation.
    ///
    /// **Available Styles:**
    /// - `.circular`: Traditional circular arc corners (iOS default)
    /// - `.continuous`: Apple's continuous corner curve (more organic appearance)
    public let style: RoundedCornerStyle

    /// Initializes a new portal corner configuration.
    ///
    /// Creates a corner configuration with specified radius values for source
    /// and destination elements, along with the corner style to use throughout
    /// the transition.
    ///
    /// - Parameters:
    ///   - source: Source corner radius in points. Defaults to 0 (sharp corners).
    ///   - destination: Destination corner radius in points. Defaults to 0 (sharp corners).
    ///   - style: Corner rounding style. Defaults to circular corners.
    public init(source: CGFloat = 0, destination: CGFloat = 0, style: RoundedCornerStyle = .circular) {
        self.source = source
        self.destination = destination
        self.style = style
    }
}
