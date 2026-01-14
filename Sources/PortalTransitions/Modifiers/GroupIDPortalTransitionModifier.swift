//
//  GroupIDPortalTransitionModifier.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Multi-ID Portal Transition Modifier

/// A view modifier that manages coordinated portal transitions for multiple portal IDs.
///
/// This modifier enables multiple portal animations to run simultaneously as a coordinated group
/// using string IDs. When the active state changes, all portals with IDs in the array are animated
/// together to their destinations.
///
/// **Key Features:**
/// - Coordinates multiple portal animations as a single group using string IDs
/// - Boolean state control for transitions
/// - Synchronized timing for all portals in the group
/// - Proper cleanup when animations complete
public struct GroupIDPortalTransitionModifier<LayerView: View>: ViewModifier {
    /// Array of portal IDs to animate together.
    public let ids: [AnyHashable]

    /// Group identifier for coordinating the animations.
    public let groupID: String

    /// Namespace for scoping this portal transition.
    /// Transitions only match portals within the same namespace.
    public let namespace: Namespace.ID

    /// Animation to use for the transition.
    public let animation: Animation

    /// Configuration for customizing the layer view during animation.
    /// See ``PortalConfiguration`` for the three levels of control available.
    public let configuration: PortalConfiguration?

    /// Controls fade-out behavior when the portal layer is removed.
    public let transition: PortalRemoveTransition

    /// Completion criteria for detecting when the animation finishes.
    public let completionCriteria: AnimationCompletionCriteria

    /// Boolean binding that controls the portal transition state.
    @Binding public var isActive: Bool

    /// Closure that generates the layer view for each ID in the transition.
    public let layerView: (AnyHashable) -> LayerView

    /// Completion handler called when all transitions finish.
    public let completion: (Bool) -> Void

    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

    public init<ID: Hashable>(
        ids: [ID],
        groupID: String,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void,
        @ViewBuilder layerView: @escaping (AnyHashable) -> LayerView,
        configuration: PortalConfiguration? = nil
    ) {
        self.ids = ids.map { AnyHashable($0) }
        self.groupID = groupID
        self.namespace = namespace
        self._isActive = isActive
        self.animation = animation
        self.transition = transition
        self.completionCriteria = completionCriteria
        self.completion = completion
        self.layerView = layerView
        self.configuration = configuration
    }

    /// Ensures portal info exists for all IDs when the view appears.
    private func onAppear() {
        for id in ids where !portalModel.info.contains(where: { $0.infoID == id && $0.namespace == namespace }) {
            portalModel.info.append(PortalInfo(id: id, namespace: namespace, groupID: groupID))
        }
    }

    /// Handles changes to the active state, triggering appropriate portal transitions.
    private func onChange(oldValue: Bool, newValue: Bool) {
        let groupIndices = portalModel.info.enumerated().compactMap { index, info in
            ids.contains(info.infoID) && info.namespace == namespace ? index : nil
        }

        if newValue {
            // Forward transition: isActive became true
            for (i, idx) in groupIndices.enumerated() {
                let portalID = portalModel.info[idx].infoID
                portalModel.info[idx].initialized = true
                portalModel.info[idx].animation = animation
                portalModel.info[idx].completionCriteria = completionCriteria
                portalModel.info[idx].configuration = configuration
                portalModel.info[idx].fade = transition
                portalModel.info[idx].groupID = groupID
                portalModel.info[idx].isGroupCoordinator = (i == 0)
                portalModel.info[idx].showLayer = true
                portalModel.info[idx].layerView = AnyView(layerView(portalID))

                // Only coordinator gets completion callback
                if i == 0 {
                    portalModel.info[idx].completion = completion
                } else {
                    portalModel.info[idx].completion = { _ in }
                }
            }

            // Start coordinated animation
            DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
                withAnimation(animation, completionCriteria: completionCriteria) {
                    for idx in groupIndices {
                        portalModel.info[idx].animateView = true
                    }
                } completion: {
                    // Show destinations first, then hide layers on next frame to prevent flicker
                    for idx in groupIndices {
                        portalModel.info[idx].hideView = true
                    }

                    DispatchQueue.main.async {
                        for idx in groupIndices {
                            portalModel.info[idx].showLayer = false
                        }

                        Task { @MainActor in
                            if let coordinatorIdx = groupIndices.first(where: { portalModel.info[$0].isGroupCoordinator }) {
                                portalModel.info[coordinatorIdx].completion(true)
                            }
                        }
                    }
                }
            }
        } else {
            // Reverse transition: isActive became false
            for idx in groupIndices {
                portalModel.info[idx].hideView = false
                portalModel.info[idx].showLayer = true
            }

            withAnimation(animation, completionCriteria: completionCriteria) {
                for idx in groupIndices {
                    portalModel.info[idx].animateView = false
                }
            } completion: {
                Task { @MainActor in
                    // Call completion for coordinator before resetting state
                    if let coordinatorIdx = groupIndices.first(where: { portalModel.info[$0].isGroupCoordinator }) {
                        portalModel.info[coordinatorIdx].completion(false)
                    }

                    for idx in groupIndices {
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
    }

    public func body(content: Content) -> some View {
        content
            .onAppear(perform: onAppear)
            .onChange(of: isActive, onChange)
    }
}

public extension View {
    // MARK: - No Configuration (Default)

    /// Applies a portal transition for multiple IDs.
    ///
    /// This is the simplest form - frame and offset are applied automatically.
    func portalTransition<ID: Hashable, LayerView: View>(
        ids: [ID],
        groupID: String,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (AnyHashable) -> LayerView
    ) -> some View {
        self.modifier(
            GroupIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                in: namespace,
                isActive: isActive,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView,
                configuration: nil
            )
        )
    }

    // MARK: - Level 1: Styling Only

    /// Applies a portal transition for multiple IDs with styling-only configuration.
    ///
    /// Modify appearance without affecting positioning.
    /// Frame and offset are applied automatically AFTER your configuration.
    func portalTransition<ID: Hashable, LayerView: View, ConfiguredView: View>(
        ids: [ID],
        groupID: String,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (AnyHashable) -> LayerView,
        @ViewBuilder configuration: @escaping (AnyView, Bool) -> ConfiguredView
    ) -> some View {
        self.modifier(
            GroupIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                in: namespace,
                isActive: isActive,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView,
                configuration: .styling { content, isActive in
                    AnyView(configuration(content, isActive))
                }
            )
        )
    }

    // MARK: - Level 2: Full Control (Interpolated Values)

    /// Applies a portal transition for multiple IDs with full control over layout.
    ///
    /// You have complete control and MUST apply frame and offset yourself.
    func portalTransition<ID: Hashable, LayerView: View, ConfiguredView: View>(
        ids: [ID],
        groupID: String,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (AnyHashable) -> LayerView,
        @ViewBuilder configuration: @escaping (AnyView, Bool, CGSize, CGPoint) -> ConfiguredView
    ) -> some View {
        self.modifier(
            GroupIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                in: namespace,
                isActive: isActive,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView,
                configuration: .full { content, isActive, size, position in
                    AnyView(configuration(content, isActive, size, position))
                }
            )
        )
    }

    // MARK: - Level 3: Raw Source/Destination Values

    /// Applies a portal transition for multiple IDs with raw source and destination values.
    ///
    /// Access both source AND destination sizes/positions for custom interpolation.
    func portalTransition<ID: Hashable, LayerView: View, ConfiguredView: View>(
        ids: [ID],
        groupID: String,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (AnyHashable) -> LayerView,
        @ViewBuilder configuration: @escaping (AnyView, Bool, CGSize, CGSize, CGPoint, CGPoint) -> ConfiguredView
    ) -> some View {
        self.modifier(
            GroupIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                in: namespace,
                isActive: isActive,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView,
                configuration: .raw { content, isActive, sourceSize, destinationSize, sourcePosition, destinationPosition in
                    AnyView(configuration(content, isActive, sourceSize, destinationSize, sourcePosition, destinationPosition))
                }
            )
        )
    }
}
