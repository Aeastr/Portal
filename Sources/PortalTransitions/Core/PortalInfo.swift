//
//  PortalInfo.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A data record that encapsulates all information needed for a single portal animation.
///
/// This struct serves as the central data model for tracking the complete state of a portal
/// transition between source and destination views. It contains positioning data, animation
/// configuration, state flags, and callback handlers needed to coordinate smooth transitions.
///
/// Each `PortalInfo` instance represents one unique portal animation identified by its `infoID`.
/// The struct tracks both the geometric information (anchors, progress) and behavioral aspects
/// (duration, visibility, completion handling) of the transition.
public struct PortalInfo: Identifiable {
    /// Unique identifier for SwiftUI's `Identifiable` protocol.
    ///
    /// This UUID is automatically generated and used by SwiftUI for efficient list updates
    /// and view identity tracking. It's separate from `infoID` which is the user-defined
    /// portal identifier.
    public let id = UUID()

    /// User-defined unique identifier for this portal animation.
    ///
    /// This string identifier is used to match source and destination views that should
    /// be connected by a portal transition. It should be unique within the scope of
    /// active portal animations.
    public let infoID: String

    /// Flag indicating whether this portal has been properly initialized.
    ///
    /// Set to `true` when the portal system has completed setup for this animation,
    /// including registering both source and destination views. Only initialized
    /// portals can begin their transition animations.
    public var initialized = false

    /// The intermediate view layer used during the portal transition animation.
    ///
    /// This view is displayed as an overlay during the transition, providing a smooth
    /// visual bridge between the source and destination views. It's typically a snapshot
    /// or representation of the transitioning content.
    public var layerView: AnyView?

    /// Flag indicating whether the portal animation is currently active.
    ///
    /// When `true`, the portal transition is in progress. This affects opacity calculations
    /// and determines whether the intermediate layer view should be displayed.
    public var animateView = false

    /// Flag controlling the visibility of the destination view during animation.
    ///
    /// When `true`, the destination view is hidden (opacity 0), typically during the
    /// initial phase of the animation. When `false`, the destination view is visible,
    /// usually after the transition layer has completed its movement.
    public var hideView = false

    /// Flag controlling the visibility of the transition layer.
    ///
    /// When `true`, the transition layer is visible and animating. When `false`, the layer is hidden.
    /// This is separate from `hideView` to allow independent control of layer and destination visibility,
    /// preventing flicker during handoff by ensuring the destination is visible before the layer disappears.
    public var showLayer = false

    /// Anchor bounds information for the source (origin) view.
    ///
    /// Contains the geometric bounds of the source view in the coordinate space
    /// needed for calculating the starting position of the portal animation.
    /// Set when the source view reports its position through the preference system.
    public var sourceAnchor: Anchor<CGRect>?

    /// Cached source anchor used during transitions even if view is removed from hierarchy.
    ///
    /// This ensures the transition layer can continue animating even if the source view
    /// disappears mid-transition (e.g., during sheet dismissal).
    public var cachedSourceAnchor: Anchor<CGRect>?

    /// Animation for the portal transition.
    ///
    /// The SwiftUI animation that controls how the portal transition behaves,
    /// including timing and easing curves.
    public var animation: Animation = .smooth(duration: 0.4)

    /// Completion criteria for detecting when the animation finishes.
    ///
    /// Determines when the animation is considered complete, such as when
    /// the view is removed or logically complete.
    public var completionCriteria: AnimationCompletionCriteria = .removed

    /// Corner styling configuration for the portal transition elements.
    ///
    /// Defines the corner radius and styling properties applied to the portal
    /// elements during the transition animation. This allows for consistent
    /// visual treatment of rounded corners, ensuring smooth interpolation
    /// between source and destination corner styles.
    ///
    /// The corner configuration affects how the intermediate layer view appears
    /// during the transition, providing visual continuity when transitioning
    /// between views with different corner radius values.
    ///
    /// When `nil`, no corner clipping is applied, allowing content to extend
    /// beyond frame boundaries during scaling transitions.
    public var corners: PortalCorners?

    /// Controls fade-out behavior when the portal layer is removed.
    ///
    /// Determines whether the portal transition layer should fade out smoothly
    /// or disappear instantly when the transition completes. Default is `.fade`.
    public var fade: PortalRemoveTransition = .none

    /// Anchor bounds information for the destination (target) view.
    ///
    /// Contains the geometric bounds of the destination view in the coordinate space
    /// needed for calculating the ending position of the portal animation.
    /// Set when the destination view reports its position through the preference system.
    public var destinationAnchor: Anchor<CGRect>?

    /// Cached destination anchor used during transitions even if view is removed from hierarchy.
    ///
    /// This ensures the transition layer can continue animating even if the destination view
    /// disappears mid-transition (e.g., during sheet dismissal).
    public var cachedDestinationAnchor: Anchor<CGRect>?

    /// Completion callback executed when the portal animation finishes.
    ///
    /// This closure is called with a boolean parameter indicating whether the animation
    /// completed successfully (`true`) or was interrupted/cancelled (`false`).
    /// Default implementation is a no-op that ignores the completion status.
    public var completion: (Bool) -> Void = { _ in }

    /// Optional group identifier for coordinated multi-portal animations.
    ///
    /// When multiple portals share the same `groupID`, they are animated together
    /// as a coordinated group. This enables scenarios like multiple photos transitioning
    /// simultaneously to the same destination.
    ///
    /// When `nil`, the portal operates independently as a single transition.
    public var groupID: String?

    /// Flag indicating whether this portal is the group coordinator.
    ///
    /// In a group of portals, one portal acts as the coordinator and manages
    /// the timing for the entire group. Only the coordinator triggers animations
    /// and completion callbacks for the group.
    public var isGroupCoordinator = false

    /// Initializes a new PortalInfo instance with the specified identifier.
    ///
    /// Creates a new portal data record with default values for all properties
    /// except the required user-defined identifier.
    ///
    /// - Parameter id: The unique string identifier for this portal animation
    /// - Parameter groupID: Optional group identifier for coordinated animations
    public init(id: String, groupID: String? = nil) {
        self.infoID = id
        self.groupID = groupID
    }
}
