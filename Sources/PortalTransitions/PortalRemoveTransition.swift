//
//  PortalRemoveTransition.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Controls fade-out behavior when the portal layer is removed.
///
/// This enum determines whether the portal transition layer should fade out smoothly
/// with an opacity animation or disappear instantly when the transition completes.
///
/// **Usage:**
/// ```swift
/// .portalTransition(
///     id: "detail",
///     isActive: $showDetail,
///     fade: .fade
/// ) {
///     DetailLayerView()
/// }
/// ```
public enum PortalRemoveTransition {
    /// Layer disappears instantly without fade animation.
    case none

    /// Layer fades out smoothly when removed (default behavior).
    case fade
}
