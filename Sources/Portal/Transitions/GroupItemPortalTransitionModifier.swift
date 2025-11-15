//
//  GroupItemPortalTransitionModifier.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Multi-Item Portal Transition Modifier

/// A view modifier that manages coordinated portal transitions for multiple `Identifiable` items.
///
/// This modifier enables multiple portal animations to run simultaneously as a coordinated group.
/// When the items array changes, all items in the array are animated together to their destinations.
/// This is perfect for scenarios like multiple photos transitioning to a detail view simultaneously.
///
/// **Key Features:**
/// - Coordinates multiple portal animations as a single group
/// - Automatic ID generation from `Identifiable` items
/// - Synchronized timing for all portals in the group
/// - Individual layer views for each item
/// - Proper cleanup when animations complete
///
/// **Usage Pattern:**
/// ```swift
/// @State private var selectedPhotos: [Photo] = []
///
/// PhotoGridView()
///     .portalTransition(items: $selectedPhotos, groupID: "photoStack") { photo in
///         PhotoView(photo: photo)
///     }
/// ```
@available(iOS 17, *)
public struct GroupItemPortalTransitionModifier<Item: Identifiable, LayerView: View>: ViewModifier {
    /// Binding to the array of items that controls the portal transitions.
    @Binding public var items: [Item]

    /// Group identifier for coordinating the animations.
    public let groupID: String

    /// Animation to use for the transition.
    public let animation: Animation

    /// Completion criteria for detecting when the animation finishes.
    public let completionCriteria: AnimationCompletionCriteria

    /// Corner styling configuration for visual appearance.
    public let corners: PortalCorners?

    /// Closure that generates the layer view for each item in the transition.
    public let layerView: (Item) -> LayerView

    /// Completion handler called when all transitions finish.
    public let completion: (Bool) -> Void

    /// Stagger delay between each item's animation start (in seconds).
    /// When > 0, each subsequent item will start animating with this additional delay.
    /// For example, with staggerDelay = 0.1: first item starts at base delay,
    /// second item at base + 0.1s, third at base + 0.2s, etc.
    public let staggerDelay: TimeInterval

    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

    /// Environment corners configuration.

    /// Tracks the last set of keys for cleanup during reverse transitions.
    @State private var lastKeys: Set<String> = []

    public init(
        items: Binding<[Item]>,
        groupID: String,
        in corners: PortalCorners? = nil,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void,
        staggerDelay: TimeInterval = 0.0,
        @ViewBuilder layerView: @escaping (Item) -> LayerView
    ) {
        self._items = items
        self.groupID = groupID
        self.corners = corners
        self.animation = animation
        self.completionCriteria = completionCriteria
        self.completion = completion
        self.staggerDelay = staggerDelay
        self.layerView = layerView

        // Validate animation duration
        Self.validateAnimationDuration(animation, groupID: groupID)
    }

    /// Validates animation duration and logs a warning if it's too short for sheet transitions.
    private static func validateAnimationDuration(_ animation: Animation, groupID: String) {
        // Extract duration from animation if possible
        let mirror = Mirror(reflecting: animation)

        // Try to find duration in the animation's structure
        if let duration = Self.extractDuration(from: mirror) {
            if duration < PortalConstants.minimumSheetAnimationDuration {
                let message = "Portal group '\(groupID)': Animation duration (\(String(format: "%.2f", duration))s) is below recommended minimum (\(String(format: "%.2f", PortalConstants.minimumSheetAnimationDuration))s) for sheet transitions. This may cause visual artifacts."

                // Runtime warning that shows in Xcode console
                #if DEBUG
                assertionFailure(message)
                #endif

                // Also log for non-debug builds
                PortalLogs.logger.log(
                    message,
                    level: .warning,
                    tags: [PortalLogs.Tags.transition],
                    metadata: ["groupID": groupID, "duration": "\(duration)", "minimum": "\(PortalConstants.minimumSheetAnimationDuration)"]
                )
            }
        }
    }

    /// Attempts to extract duration from Animation via reflection.
    private static func extractDuration(from mirror: Mirror) -> TimeInterval? {
        // Check direct duration property
        if let duration = mirror.children.first(where: { $0.label == "duration" })?.value as? TimeInterval {
            return duration
        }

        // Recursively check nested children (for wrapped animations)
        for child in mirror.children {
            if let childMirror = child.value as? Any {
                let nestedMirror = Mirror(reflecting: childMirror)
                if let duration = extractDuration(from: nestedMirror) {
                    return duration
                }
            }
        }

        return nil
    }

    /// Convenience init for backward compatibility with config
    public init(
        items: Binding<[Item]>,
        groupID: String,
        config: PortalTransitionConfig,
        layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void,
        staggerDelay: TimeInterval = 0.0
    ) {
        self._items = items
        self.groupID = groupID
        self.animation = config.animation.value
        self.completionCriteria = config.animation.completionCriteria
        self.corners = config.corners
        self.layerView = layerView
        self.completion = completion
        self.staggerDelay = staggerDelay
    }

    /// Generates string keys from the current items' IDs.
    private var keys: Set<String> {
        Set(items.map { "\($0.id)" })
    }

    /// Ensures portal info exists for all items.
    private func ensurePortalInfo(for items: [Item]) {
        for item in items {
            let key = "\(item.id)"
            if !portalModel.info.contains(where: { $0.infoID == key }) {
                portalModel.info.append(PortalInfo(id: key, groupID: groupID))
            }
        }
    }

    /// Configures portal info for all items in the group.
    private func configureGroupPortals(at indices: [Int]) {
        for (i, idx) in indices.enumerated() {
            portalModel.info[idx].initialized = true
            portalModel.info[idx].animation = animation
            portalModel.info[idx].completionCriteria = completionCriteria
            portalModel.info[idx].corners = corners
            portalModel.info[idx].groupID = groupID
            portalModel.info[idx].isGroupCoordinator = (i == 0)

            if let item = items.first(where: { "\($0.id)" == portalModel.info[idx].infoID }) {
                portalModel.info[idx].layerView = AnyView(layerView(item))
            }

            portalModel.info[idx].completion = (i == 0) ? completion : { _ in }
        }
    }

    /// Starts staggered forward animations for the given indices.
    private func startStaggeredAnimation(at indices: [Int]) {
        for (i, idx) in indices.enumerated() {
            let itemDelay = PortalConstants.animationDelay + (TimeInterval(i) * staggerDelay)

            DispatchQueue.main.asyncAfter(deadline: .now() + itemDelay) {
                withAnimation(animation, completionCriteria: completionCriteria) {
                    portalModel.info[idx].animateView = true
                } completion: {
                    Task { @MainActor in
                        portalModel.info[idx].hideView = true

                        if portalModel.info[idx].isGroupCoordinator {
                            let lastItemDelay = TimeInterval(indices.count - 1) * staggerDelay
                            DispatchQueue.main.asyncAfter(deadline: .now() + lastItemDelay) {
                                portalModel.info[idx].completion(true)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Starts simultaneous forward animations for the given indices.
    private func startSimultaneousAnimation(at indices: [Int]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
            withAnimation(animation, completionCriteria: completionCriteria) {
                for idx in indices {
                    portalModel.info[idx].animateView = true
                }
            } completion: {
                Task { @MainActor in
                    for idx in indices {
                        portalModel.info[idx].hideView = true
                        if portalModel.info[idx].isGroupCoordinator {
                            portalModel.info[idx].completion(true)
                        }
                    }
                }
            }
        }
    }

    /// Performs reverse transition cleanup.
    private func performReverseTransition(for keys: Set<String>) {
        let cleanupIndices = portalModel.info.enumerated().compactMap { index, info in
            keys.contains(info.infoID) ? index : nil
        }

        for idx in cleanupIndices {
            portalModel.info[idx].hideView = false
        }

        withAnimation(animation, completionCriteria: completionCriteria) {
            for idx in cleanupIndices {
                portalModel.info[idx].animateView = false
            }
        } completion: {
            Task { @MainActor in
                for idx in cleanupIndices {
                    portalModel.info[idx].initialized = false
                    portalModel.info[idx].layerView = nil
                    portalModel.info[idx].sourceAnchor = nil
                    portalModel.info[idx].destinationAnchor = nil
                    portalModel.info[idx].groupID = nil
                    portalModel.info[idx].isGroupCoordinator = false
                    if portalModel.info[idx].isGroupCoordinator {
                        portalModel.info[idx].completion(false)
                    }
                }
            }
        }
    }

    /// Handles changes to the items array, triggering appropriate portal transitions.
    private func onChange(oldValue: [Item], hasItems: Bool) {
        let currentKeys = keys

        if hasItems && !items.isEmpty {
            lastKeys = currentKeys
            ensurePortalInfo(for: items)

            let groupIndices = portalModel.info.enumerated().compactMap { index, info in
                currentKeys.contains(info.infoID) ? index : nil
            }

            configureGroupPortals(at: groupIndices)

            if staggerDelay > 0 {
                startStaggeredAnimation(at: groupIndices)
            } else {
                startSimultaneousAnimation(at: groupIndices)
            }
        } else {
            performReverseTransition(for: lastKeys)
            lastKeys.removeAll()
        }
    }

    public func body(content: Content) -> some View {
        content.onChange(of: !items.isEmpty) {
            onChange(oldValue: items, hasItems: !items.isEmpty)
        }
    }
}

@available(iOS 17, *)
public extension View {
    /// Applies coordinated portal transitions for multiple `Identifiable` items.
    ///
    /// This modifier enables multiple portal animations to run simultaneously as a coordinated group.
    /// All items in the array are animated together with synchronized timing, perfect for scenarios
    /// like multiple photos transitioning to a detail view simultaneously.
    ///
    /// **Usage Pattern:**
    /// ```swift
    /// @State private var selectedPhotos: [Photo] = []
    ///
    /// PhotoGridView()
    ///     .portalTransition(items: $selectedPhotos, groupID: "photoStack") { photo in
    ///         PhotoView(photo: photo)
    ///     }
    /// ```
    ///
    /// **Group Coordination:**
    /// - All portals with the same `groupID` animate together
    /// - Source views should use `.portal(item:, .source, groupID:)`
    /// - Destination views should use `.portal(item:, .destination, groupID:)`
    /// **Group Coordination:**
    /// - All portals with the same `groupID` animate together
    /// - Source views should use `.portal(item:, .source, groupID:)`
    /// - Destination views should use `.portal(item:, .destination, groupID:)`
    /// - Animation timing can be synchronized or staggered based on `staggerDelay`
    ///
    /// **Staggered Animation:**
    /// When `staggerDelay` > 0, each item starts animating with an increasing delay:
    /// - First item: starts at base delay
    /// - Second item: starts at base delay + staggerDelay
    /// - Third item: starts at base delay + (2 * staggerDelay), etc.
    ///
    /// - Parameters:
    ///   - items: Binding to an array of `Identifiable` items that controls the transitions
    ///   - groupID: Group identifier for coordinating animations. Must match portal source/destination groupIDs.
    ///   - config: Configuration for animation and styling (optional, defaults to standard config)
    ///   - staggerDelay: Delay between each item's animation start in seconds (optional, defaults to 0 for synchronized)
    ///   - layerView: Closure that receives each item and returns the view to animate for that item
    ///   - completion: Optional completion handler called when all animations finish (defaults to no-op)
    /// - Returns: A view with the multi-item portal transition modifier applied
    @available(*, deprecated, message: "Use portalTransition with direct animation and corners parameters instead. Will be removed in a future version.")
    func portalTransition<Item: Identifiable, LayerView: View>(
        items: Binding<[Item]>,
        groupID: String,
        config: PortalTransitionConfig,
        staggerDelay: TimeInterval = 0.0,
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            GroupItemPortalTransitionModifier(
                items: items,
                groupID: groupID,
                config: config,
                layerView: layerView,
                completion: completion,
                staggerDelay: staggerDelay
            )
        )
    }

    /// Applies coordinated portal transitions for multiple items with direct parameters.
    ///
    /// Creates portal transitions for multiple items, with shared animation parameters
    /// and optional stagger effects. All items in the array animate as a coordinated group.
    ///
    /// - Parameters:
    ///   - items: Binding to an array of `Identifiable` items
    ///   - groupID: Group identifier for coordinating animations
    ///   - in corners: Corner radius configuration for visual styling
    ///   - animation: The animation curve to use
    ///   - completionCriteria: How to detect animation completion
    ///   - staggerDelay: Delay between each item's animation start
    ///   - layerView: Closure that generates the view for each item
    ///   - completion: Called when all animations finish
    ///
    /// - Returns: A view with the multi-item portal transition modifier applied
    func portalTransition<Item: Identifiable, LayerView: View>(
        items: Binding<[Item]>,
        groupID: String,
        in corners: PortalCorners? = nil,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        staggerDelay: TimeInterval = 0.0,
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            GroupItemPortalTransitionModifier(
                items: items,
                groupID: groupID,
                in: corners,
                animation: animation,
                completionCriteria: completionCriteria,
                completion: completion,
                staggerDelay: staggerDelay,
                layerView: layerView
            )
        )
    }
}
