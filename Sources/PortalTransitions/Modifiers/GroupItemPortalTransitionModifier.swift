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
public struct GroupItemPortalTransitionModifier<Item: Identifiable, LayerView: View>: ViewModifier {
    /// Binding to the array of items that controls the portal transitions.
    @Binding public var items: [Item]

    /// Group identifier for coordinating the animations.
    public let groupID: String

    /// Namespace for scoping this portal transition.
    /// Transitions only match portals within the same namespace.
    public let namespace: Namespace.ID

    /// Animation to use for the transition.
    public let animation: Animation

    /// Configuration closure for customizing the layer view during animation.
    public let configuration: (@Sendable (AnyView, Bool, CGSize, CGPoint) -> AnyView)?

    /// Controls fade-out behavior when the portal layer is removed.
    public let transition: PortalRemoveTransition

    /// Completion criteria for detecting when the animation finishes.
    public let completionCriteria: AnimationCompletionCriteria

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

    /// Tracks the last set of keys for cleanup during reverse transitions.
    @State private var lastKeys: Set<AnyHashable> = []

    public init(
        items: Binding<[Item]>,
        groupID: String,
        in namespace: Namespace.ID,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void,
        staggerDelay: TimeInterval = 0.0,
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        configuration: (@Sendable (AnyView, Bool, CGSize, CGPoint) -> AnyView)? = nil
    ) {
        self._items = items
        self.groupID = groupID
        self.namespace = namespace
        self.animation = animation
        self.transition = transition
        self.completionCriteria = completionCriteria
        self.completion = completion
        self.staggerDelay = staggerDelay
        self.layerView = layerView
        self.configuration = configuration

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
                    metadata: ["groupID": groupID, "duration": String(reflecting: duration), "minimum": String(reflecting: PortalConstants.minimumSheetAnimationDuration)]
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
            let nestedMirror = Mirror(reflecting: child.value)
            if let duration = extractDuration(from: nestedMirror) {
                return duration
            }
        }

        return nil
    }

    /// Generates keys from the current items' IDs.
    private var keys: Set<AnyHashable> {
        Set(items.map { AnyHashable($0.id) })
    }

    /// Ensures portal info exists for all items.
    private func ensurePortalInfo(for items: [Item]) {
        for item in items {
            let key = AnyHashable(item.id)
            if !portalModel.info.contains(where: { $0.infoID == key && $0.namespace == namespace }) {
                portalModel.info.append(PortalInfo(id: key, namespace: namespace, groupID: groupID))
            }
        }
    }

    /// Configures portal info for all items in the group.
    private func configureGroupPortals(at indices: [Int]) {
        for (i, idx) in indices.enumerated() {
            portalModel.info[idx].initialized = true
            portalModel.info[idx].animation = animation
            portalModel.info[idx].completionCriteria = completionCriteria
            portalModel.info[idx].configuration = configuration
            portalModel.info[idx].fade = transition
            portalModel.info[idx].groupID = groupID
            portalModel.info[idx].isGroupCoordinator = (i == 0)
            portalModel.info[idx].showLayer = true

            if let item = items.first(where: { AnyHashable($0.id) == portalModel.info[idx].infoID }) {
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
                    // Show destination first, then hide layer on next frame to prevent flicker
                    portalModel.info[idx].hideView = true

                    DispatchQueue.main.async {
                        portalModel.info[idx].showLayer = false

                        if portalModel.info[idx].isGroupCoordinator {
                            let lastItemDelay = TimeInterval(indices.count - 1) * staggerDelay
                            DispatchQueue.main.asyncAfter(deadline: .now() + lastItemDelay) {
                                Task { @MainActor in
                                    portalModel.info[idx].completion(true)
                                }
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
                // Show destinations first, then hide layers on next frame to prevent flicker
                for idx in indices {
                    portalModel.info[idx].hideView = true
                }

                DispatchQueue.main.async {
                    for idx in indices {
                        portalModel.info[idx].showLayer = false
                    }

                    Task { @MainActor in
                        if let coordinatorIdx = indices.first(where: { portalModel.info[$0].isGroupCoordinator }) {
                            portalModel.info[coordinatorIdx].completion(true)
                        }
                    }
                }
            }
        }
    }

    /// Performs reverse transition cleanup.
    private func performReverseTransition(for keys: Set<AnyHashable>) {
        let cleanupIndices = portalModel.info.enumerated().compactMap { index, info in
            keys.contains(info.infoID) && info.namespace == namespace ? index : nil
        }

        for idx in cleanupIndices {
            portalModel.info[idx].hideView = false
            portalModel.info[idx].showLayer = true
        }

        withAnimation(animation, completionCriteria: completionCriteria) {
            for idx in cleanupIndices {
                portalModel.info[idx].animateView = false
            }
        } completion: {
            Task { @MainActor in
                // Call completion for coordinator before resetting state
                if let coordinatorIdx = cleanupIndices.first(where: { portalModel.info[$0].isGroupCoordinator }) {
                    portalModel.info[coordinatorIdx].completion(false)
                }

                for idx in cleanupIndices {
                    portalModel.info[idx].showLayer = false
                    portalModel.info[idx].initialized = false
                    portalModel.info[idx].layerView = nil
                    portalModel.info[idx].sourceAnchor = nil
                    portalModel.info[idx].destinationAnchor = nil
                    portalModel.info[idx].groupID = nil
                    portalModel.info[idx].isGroupCoordinator = false
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
                currentKeys.contains(info.infoID) && info.namespace == namespace ? index : nil
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

public extension View {
    /// Applies coordinated portal transitions for multiple `Identifiable` items with configuration.
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
    ///     .portalTransition(items: $selectedPhotos, groupID: "photoStack", in: namespace) { photo in
    ///         PhotoView(photo: photo)
    ///     } configuration: { content, isActive, size, position in
    ///         content
    ///             .frame(width: size.width, height: size.height)
    ///             .clipShape(.rect(cornerRadius: isActive ? 20 : 10))
    ///             .offset(x: position.x, y: position.y)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - items: Binding to an array of `Identifiable` items
    ///   - groupID: Group identifier for coordinating animations
    ///   - namespace: The namespace for scoping this portal
    ///   - animation: The animation curve to use
    ///   - transition: Fade-out behavior for layer removal (defaults to .none)
    ///   - completionCriteria: How to detect animation completion
    ///   - staggerDelay: Delay between each item's animation start
    ///   - completion: Called when all animations finish
    ///   - layerView: Closure that generates the view for each item
    ///   - configuration: Optional closure to customize the layer view during animation
    ///
    /// - Returns: A view with the multi-item portal transition modifier applied
    func portalTransition<Item: Identifiable, LayerView: View, ConfiguredView: View>(
        items: Binding<[Item]>,
        groupID: String,
        in namespace: Namespace.ID,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        staggerDelay: TimeInterval = 0.0,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        @ViewBuilder configuration: @escaping (AnyView, Bool, CGSize, CGPoint) -> ConfiguredView
    ) -> some View {
        return self.modifier(
            GroupItemPortalTransitionModifier(
                items: items,
                groupID: groupID,
                in: namespace,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                staggerDelay: staggerDelay,
                layerView: layerView,
                configuration: { view, isActive, size, position in AnyView(configuration(view, isActive, size, position)) }
            )
        )
    }

    /// Applies coordinated portal transitions for multiple `Identifiable` items without configuration.
    ///
    /// This is a convenience overload that doesn't require a configuration closure.
    /// The layer view is used as-is without modification.
    ///
    /// - Parameters:
    ///   - items: Binding to an array of `Identifiable` items
    ///   - groupID: Group identifier for coordinating animations
    ///   - namespace: The namespace for scoping this portal
    ///   - animation: The animation curve to use
    ///   - transition: Fade-out behavior for layer removal (defaults to .none)
    ///   - completionCriteria: How to detect animation completion
    ///   - staggerDelay: Delay between each item's animation start
    ///   - completion: Called when all animations finish
    ///   - layerView: Closure that generates the view for each item
    ///
    /// - Returns: A view with the multi-item portal transition modifier applied
    func portalTransition<Item: Identifiable, LayerView: View>(
        items: Binding<[Item]>,
        groupID: String,
        in namespace: Namespace.ID,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        staggerDelay: TimeInterval = 0.0,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (Item) -> LayerView
    ) -> some View {
        return self.modifier(
            GroupItemPortalTransitionModifier(
                items: items,
                groupID: groupID,
                in: namespace,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                staggerDelay: staggerDelay,
                layerView: layerView,
                configuration: nil
            )
        )
    }
}
