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

// MARK: - Portal Configuration

/// Configuration levels for customizing portal layer views during animation.
///
/// This enum provides three levels of control over how the layer view is styled
/// and positioned during portal transitions:
///
/// - **Styling**: Modify appearance only; frame/offset applied automatically after
/// - **Full**: Complete control with interpolated size/position; must apply frame/offset yourself
/// - **Raw**: Access to both source and destination values for custom logic
public enum PortalConfiguration: Sendable {
    /// Level 1: Styling only configuration.
    ///
    /// Modify the layer view's appearance (clips, shadows, etc.) without affecting positioning.
    /// Frame and offset are applied automatically AFTER your configuration.
    ///
    /// **Parameters:**
    /// - `content`: The layer view to style
    /// - `isActive`: `true` when animating toward destination, `false` when at/toward source
    ///
    /// **Example:**
    /// ```swift
    /// .styling { content, isActive in
    ///     content
    ///         .clipShape(.rect(cornerRadius: isActive ? 20 : 10))
    ///         .shadow(radius: isActive ? 10 : 2)
    /// }
    /// ```
    case styling(@MainActor (AnyView, Bool) -> AnyView)

    /// Level 2: Full control with interpolated values.
    ///
    /// You have complete control over the layer view including positioning.
    /// You MUST apply frame and offset yourself using the provided values.
    ///
    /// **Parameters:**
    /// - `content`: The layer view to configure
    /// - `isActive`: `true` when animating toward destination, `false` when at/toward source
    /// - `size`: Interpolated size (destination when active, source otherwise)
    /// - `position`: Interpolated position (destination origin when active, source origin otherwise)
    ///
    /// **Example:**
    /// ```swift
    /// .full { content, isActive, size, position in
    ///     content
    ///         .frame(width: size.width, height: size.height)
    ///         .clipShape(.rect(cornerRadius: isActive ? 20 : 10))
    ///         .offset(x: position.x, y: position.y)
    /// }
    /// ```
    case full(@MainActor (AnyView, Bool, CGSize, CGPoint) -> AnyView)

    /// Level 3: Raw source and destination values.
    ///
    /// Access both source AND destination sizes and positions for custom interpolation
    /// or complex animation logic. You MUST apply frame and offset yourself.
    ///
    /// **Parameters:**
    /// - `content`: The layer view to configure
    /// - `isActive`: `true` when animating toward destination, `false` when at/toward source
    /// - `sourceSize`: Size of the source view
    /// - `destinationSize`: Size of the destination view
    /// - `sourcePosition`: Position (origin) of the source view
    /// - `destinationPosition`: Position (origin) of the destination view
    ///
    /// **Example:**
    /// ```swift
    /// .raw { content, isActive, sourceSize, destinationSize, sourcePosition, destinationPosition in
    ///     let size = isActive ? destinationSize : sourceSize
    ///     let position = isActive ? destinationPosition : sourcePosition
    ///     return content
    ///         .frame(width: size.width, height: size.height)
    ///         .offset(x: position.x, y: position.y)
    /// }
    /// ```
    case raw(@MainActor (AnyView, Bool, CGSize, CGSize, CGPoint, CGPoint) -> AnyView)
}

// MARK: - Portal Info

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
    /// This identifier is used to match source and destination views that should
    /// be connected by a portal transition. It should be unique within the scope of
    /// active portal animations.
    ///
    /// The ID is stored as `AnyHashable` to support any `Hashable` type, including
    /// `String`, `UUID`, `Int`, or custom identifier types.
    public let infoID: AnyHashable

    /// The namespace this portal belongs to.
    ///
    /// Portals are scoped by namespace to allow the same ID to be used in different
    /// contexts without collision. Only portals within the same namespace can match.
    ///
    /// - Note: Future consideration: This could be combined with `infoID` into a single
    ///   key type (similar to `PortalKey` but without `role`, since `PortalInfo` represents
    ///   both source and destination of a matched pair).
    public let namespace: Namespace.ID

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

    /// Configuration for customizing the layer view during animation.
    ///
    /// Choose from three levels of control:
    /// - `.styling`: Modify appearance only; frame/offset applied automatically
    /// - `.full`: Complete control with interpolated values; must apply frame/offset
    /// - `.raw`: Access to source AND destination values for custom logic
    ///
    /// When `nil`, frame and offset are applied automatically with no additional styling.
    ///
    /// See ``PortalConfiguration`` for detailed documentation and examples.
    public var configuration: PortalConfiguration?

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

    /// Initializes a new PortalInfo instance with the specified identifier and namespace.
    ///
    /// Creates a new portal data record with default values for all properties
    /// except the required user-defined identifier and namespace.
    ///
    /// - Parameter id: The unique identifier for this portal animation (any `Hashable` type)
    /// - Parameter namespace: The namespace for scoping this portal
    /// - Parameter groupID: Optional group identifier for coordinated animations
    public init<ID: Hashable>(id: ID, namespace: Namespace.ID, groupID: String? = nil) {
        self.infoID = AnyHashable(id)
        self.namespace = namespace
        self.groupID = groupID
    }

    /// Initializes a new PortalInfo instance with a pre-wrapped AnyHashable identifier.
    ///
    /// This overload avoids double-wrapping when the ID is already an AnyHashable.
    ///
    /// - Parameter id: The pre-wrapped identifier for this portal animation
    /// - Parameter namespace: The namespace for scoping this portal
    /// - Parameter groupID: Optional group identifier for coordinated animations
    public init(id: AnyHashable, namespace: Namespace.ID, groupID: String? = nil) {
        self.infoID = id
        self.namespace = namespace
        self.groupID = groupID
    }
}
