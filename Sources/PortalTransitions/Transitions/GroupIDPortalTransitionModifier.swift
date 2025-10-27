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
    public let ids: [String]

    /// Group identifier for coordinating the animations.
    public let groupID: String

    /// Animation to use for the transition.
    public let animation: Animation

    /// Completion criteria for detecting when the animation finishes.
    public let completionCriteria: AnimationCompletionCriteria

    /// Corner styling configuration for visual appearance.
    public let corners: PortalCorners?

    /// Boolean binding that controls the portal transition state.
    @Binding public var isActive: Bool

    /// Closure that generates the layer view for each ID in the transition.
    public let layerView: (String) -> LayerView

    /// Completion handler called when all transitions finish.
    public let completion: (Bool) -> Void

    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

    /// Environment corners configuration.

    public init(
        ids: [String],
        groupID: String,
        isActive: Binding<Bool>,
        in corners: PortalCorners? = nil,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void,
        @ViewBuilder layerView: @escaping (String) -> LayerView
    ) {
        self.ids = ids
        self.groupID = groupID
        self._isActive = isActive
        self.corners = corners
        self.animation = animation
        self.completionCriteria = completionCriteria
        self.completion = completion
        self.layerView = layerView
    }

    /// Convenience init for backward compatibility with config
    public init(
        ids: [String],
        groupID: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        layerView: @escaping (String) -> LayerView,
        completion: @escaping (Bool) -> Void
    ) {
        self.ids = ids
        self.groupID = groupID
        self.animation = config.animation.value
        self.completionCriteria = config.animation.completionCriteria
        self.corners = config.corners
        self._isActive = isActive
        self.layerView = layerView
        self.completion = completion
    }

    /// Ensures portal info exists for all IDs when the view appears.
    private func onAppear() {
        for id in ids where !portalModel.info.contains(where: { $0.infoID == id }) {
            portalModel.info.append(PortalInfo(id: id, groupID: groupID))
        }
    }

    /// Handles changes to the active state, triggering appropriate portal transitions.
    private func onChange(oldValue: Bool, newValue: Bool) {
        let groupIndices = portalModel.info.enumerated().compactMap { index, info in
            ids.contains(info.infoID) ? index : nil
        }

        if newValue {
            // Forward transition: isActive became true
            for (i, idx) in groupIndices.enumerated() {
                let portalID = portalModel.info[idx].infoID
                portalModel.info[idx].initialized = true
                portalModel.info[idx].animation = animation
                portalModel.info[idx].completionCriteria = completionCriteria
                portalModel.info[idx].corners = corners
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
                    for idx in groupIndices {
                        portalModel.info[idx].showLayer = false
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
    }

    public func body(content: Content) -> some View {
        content
            .onAppear(perform: onAppear)
            .onChange(of: isActive, onChange)
    }
}

public extension View {
    /// Applies coordinated portal transitions for multiple portal IDs.
    ///
    /// This modifier enables multiple portal animations to run simultaneously as a coordinated group
    /// using string IDs. All IDs in the array are animated together with synchronized timing.
    ///
    /// **Usage Pattern:**
    /// ```swift
    /// @State private var showPortals = false
    ///
    /// ContentView()
    ///     .portalTransition(
    ///         ids: ["portal1", "portal2", "portal3"],
    ///         groupID: "myGroup",
    ///         isActive: $showPortals
    ///     ) { id in
    ///         OverlayView(id: id)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - ids: Array of portal IDs that should animate together
    ///   - groupID: Group identifier for coordinating animations
    ///   - config: Configuration for animation and styling (optional, defaults to standard config)
    ///   - isActive: Boolean binding that controls the transition state
    ///   - layerView: Closure that receives each ID and returns the view to animate for that ID
    ///   - completion: Optional completion handler (defaults to no-op)
    /// - Returns: A view with the multi-ID portal transition modifier applied
    @available(*, deprecated, message: "Use portalTransition with direct animation and corners parameters instead. Will be removed in a future version.")
    func portalTransition<LayerView: View>(
        ids: [String],
        groupID: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        @ViewBuilder layerView: @escaping (String) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            GroupIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                config: config,
                isActive: isActive,
                layerView: layerView,
                completion: completion))
    }

    /// Applies a portal transition for multiple IDs with direct parameter configuration.
    ///
    /// Creates portal transitions for multiple elements identified by their IDs, with
    /// shared animation parameters. All IDs in the group transition together when
    /// `isActive` changes.
    ///
    /// - Parameters:
    ///   - ids: Array of IDs for the portals to transition
    ///   - groupID: Common group ID for organizing the IDs
    ///   - isActive: Controls whether the transition is active
    ///   - in corners: Corner radius configuration for visual styling
    ///   - animation: The animation curve to use
    ///   - completionCriteria: How to detect animation completion
    ///   - layerView: Closure that generates the view for each ID
    ///   - completion: Called when the transition completes
    ///
    /// - Returns: A modified view with the portal transitions applied
    func portalTransition<LayerView: View>(
        ids: [String],
        groupID: String,
        isActive: Binding<Bool>,
        in corners: PortalCorners? = nil,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        @ViewBuilder layerView: @escaping (String) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            GroupIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                isActive: isActive,
                in: corners,
                animation: animation,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView))
    }
}
