//
//  ConditionalPortalTransitionModifier.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Drives the Portal floating layer for a given id.
///
/// Use this view modifier to trigger and control a portal transition animation between
/// a source and destination view. The modifier manages the floating overlay layer,
/// animation timing, and transition state for the specified `id`.
///
/// - Parameters:
///   - id: A unique string identifier for the portal transition. This should match the `id` used for the corresponding portal source and destination.
///   - isActive: A binding that triggers the transition when set to `true`.
///   - sourceProgress: The progress value for the source view (default: 0).
///   - destinationProgress: The progress value for the destination view (default: 0).
///   - animation: The animation to use for the transition (default: `.bouncy(duration: 0.4)`).
///   - animationDuration: The duration of the transition animation (default: 0.4).
///   - delay: The delay before starting the animation (default: 0.06).
///   - layer: A closure that returns the floating overlay view to animate.
///   - completion: A closure called when the transition completes, with a `Bool` indicating success.
///
///
/// A view modifier that manages portal transitions based on boolean state changes.
///
/// This modifier provides direct control over portal transitions using a boolean binding.
/// It's ideal for scenarios where you want explicit control over when transitions occur,
/// such as toggle-based animations or programmatic navigation flows.
///
/// **Key Features:**
/// - Direct boolean control over transition state
/// - Automatic portal info initialization on view appearance
/// - Bidirectional animation support
/// - Configurable timing and styling
///
/// **Usage Pattern:**
/// The modifier responds to changes in a boolean binding. When the value becomes `true`,
/// it initiates a forward portal transition. When the value becomes `false`, it initiates
/// a reverse portal transition.
///
/// **Lifecycle Management:**
/// - `onAppear`: Ensures portal info exists in the global model
/// - `onChange`: Handles forward and reverse transitions
/// - Automatic cleanup after reverse transitions
public struct ConditionalPortalTransitionModifier<LayerView: View>: ViewModifier {
    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

    /// Unique identifier for this portal transition.
    ///
    /// This ID must match the IDs used by the corresponding portal source and
    /// destination views for the transition to work correctly.
    public let id: String

    /// Animation for the portal transition.
    public let animation: Animation

    /// Completion criteria for detecting when animation finishes.
    public let completionCriteria: AnimationCompletionCriteria

    /// Corner styling configuration for visual appearance.
    public let corners: PortalCorners?

    /// Boolean binding that controls the portal transition state.
    ///
    /// When this value changes to `true`, a forward portal transition is initiated.
    /// When it changes to `false`, a reverse portal transition with cleanup is performed.
    @Binding public var isActive: Bool

    /// Closure that generates the layer view for the transition animation.
    ///
    /// This closure returns the view that will be animated during the portal
    /// transition. The view should represent the visual content that bridges
    /// the source and destination views.
    public let layerView: () -> LayerView

    /// Completion handler called when the transition finishes.
    ///
    /// Called with `true` when the transition completes successfully, or `false`
    /// when the transition is cancelled or fails.
    public let completion: (Bool) -> Void

    /// Initializes a new conditional portal transition modifier.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the portal transition
    ///   - animation: Animation for the transition
    ///   - completionCriteria: Criteria for detecting animation completion
    ///   - corners: Corner styling configuration (optional)
    ///   - isActive: Binding that controls the transition state
    ///   - layerView: Closure that generates the transition layer view
    ///   - completion: Handler called when the transition completes
    public init(
        id: String,
        isActive: Binding<Bool>,
        in corners: PortalCorners? = nil,
        animation: Animation,
        completionCriteria: AnimationCompletionCriteria,
        completion: @escaping (Bool) -> Void,
        @ViewBuilder layerView: @escaping () -> LayerView
    ) {
        self.id = id
        self._isActive = isActive
        self.corners = corners
        self.animation = animation
        self.completionCriteria = completionCriteria
        self.completion = completion
        self.layerView = layerView

        // Validate animation duration
        Self.validateAnimationDuration(animation, id: id)
    }

    /// Validates animation duration and logs a warning if it's too short for sheet transitions.
    private static func validateAnimationDuration(_ animation: Animation, id: String) {
        // Extract duration from animation if possible
        let mirror = Mirror(reflecting: animation)

        // Try to find duration in the animation's structure
        if let duration = Self.extractDuration(from: mirror) {
            if duration < PortalConstants.minimumSheetAnimationDuration {
                let message = "Portal '\(id)': Animation duration (\(String(format: "%.2f", duration))s) is below recommended minimum (\(String(format: "%.2f", PortalConstants.minimumSheetAnimationDuration))s) for sheet transitions. This may cause visual artifacts."

                // Runtime warning that shows in Xcode console
                #if DEBUG
                assertionFailure(message)
                #endif

                // Also log for non-debug builds
                PortalLogs.logger.log(
                    message,
                    level: .warning,
                    tags: [PortalLogs.Tags.transition],
                    metadata: ["id": id, "duration": "\(duration)", "minimum": "\(PortalConstants.minimumSheetAnimationDuration)"]
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

    /// Convenience init for backward compatibility with config
    @available(*, deprecated, message: "Use init with direct Animation parameters instead of PortalTransitionConfig")
    public init(
        id: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        layerView: @escaping () -> LayerView,
        completion: @escaping (Bool) -> Void
    ) {
        self.id = id
        self.animation = config.animation.value
        self.completionCriteria = config.animation.completionCriteria
        self.corners = config.corners
        self._isActive = isActive
        self.layerView = layerView
        self.completion = completion
    }

    /// Ensures portal info exists in the model when the view appears.
    ///
    /// Creates a new `PortalInfo` entry if one doesn't already exist for this ID.
    /// This ensures that the portal system is ready to handle transitions even
    /// before the first state change occurs.
    private func onAppear() {
        if !portalModel.info.contains(where: { $0.infoID == id }) {
            portalModel.info.append(PortalInfo(id: id))
        }
    }

    /// Handles changes to the active state, triggering appropriate portal transitions.
    ///
    /// This method manages the complete lifecycle of portal transitions based on
    /// boolean state changes. It configures the portal info, manages animation
    /// timing, and handles cleanup operations.
    ///
    /// **Forward Transition (newValue = true):**
    /// 1. Configures portal info with current settings
    /// 2. Sets up layer view and completion handlers
    /// 3. Initiates delayed animation with completion handling
    ///
    /// **Reverse Transition (newValue = false):**
    /// 1. Prepares portal for reverse animation
    /// 2. Initiates reverse animation
    /// 3. Performs complete cleanup on completion
    ///
    /// - Parameters:
    ///   - oldValue: Previous value of the isActive state (unused but required by onChange)
    ///   - newValue: New value of the isActive state
    private func onChange(oldValue: Bool, newValue: Bool) {
        guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else { return }

        @Bindable var portalModel = portalModel

        // Configure portal info for any transition
        portalModel.info[idx].initialized = true
        portalModel.info[idx].animation = animation
        portalModel.info[idx].completionCriteria = completionCriteria
        portalModel.info[idx].corners = corners
        portalModel.info[idx].completion = completion
        portalModel.info[idx].layerView = AnyView(layerView())

        if newValue {
            // Forward transition: isActive became true
            portalModel.info[idx].showLayer = true

            DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
                withAnimation(animation, completionCriteria: completionCriteria) {
                    portalModel.info[idx].animateView = true
                } completion: {
                    // Show destination first, then hide layer on next frame to prevent flicker
                    portalModel.info[idx].hideView = true

                    DispatchQueue.main.async {
                        portalModel.info[idx].showLayer = false

                        Task { @MainActor in
                            portalModel.info[idx].completion(true)
                        }
                    }
                }
            }
        } else {
            // Reverse transition: isActive became false
            portalModel.info[idx].hideView = false
            portalModel.info[idx].showLayer = true

            withAnimation(animation, completionCriteria: completionCriteria) {
                portalModel.info[idx].animateView = false
            } completion: {
                Task { @MainActor in
                    // Complete cleanup after reverse animation
                    portalModel.info[idx].showLayer = false
                    portalModel.info[idx].initialized = false
                    portalModel.info[idx].layerView = nil
                    portalModel.info[idx].sourceAnchor = nil
                    portalModel.info[idx].destinationAnchor = nil
                    portalModel.info[idx].completion(false)
                }
            }
        }
    }

    /// Applies the modifier to the content view.
    ///
    /// Attaches appearance and change handlers to manage the portal transition
    /// lifecycle based on the boolean state changes.
    public func body(content: Content) -> some View {
        content
            .onAppear(perform: onAppear)
            .onChange(of: isActive, onChange)
    }
}

public extension View {
    /// Applies a portal transition controlled by a boolean binding.
    ///
    /// This modifier enables portal transitions based on boolean state changes,
    /// providing direct control over when transitions occur. It's ideal for
    /// toggle-based animations or explicit programmatic control.
    ///
    /// **Usage Pattern:**
    /// ```swift
    /// @State private var showDetail = false
    ///
    /// ContentView()
    ///     .portalTransition(
    ///         id: "detail",
    ///         isActive: $showDetail
    ///     ) {
    ///         DetailLayerView()
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the portal transition
    ///   - config: Configuration for animation and styling (optional, defaults to standard config)
    ///   - isActive: Boolean binding that controls the transition state
    ///   - layerView: Closure that returns the view to animate during transition
    ///   - completion: Optional completion handler (defaults to no-op)
    /// - Returns: A view with the portal transition modifier applied
    @available(*, deprecated, message: "Use the new API with direct parameters instead of config. Will be removed in a future version.")
    func portalTransition<LayerView: View>(
        id: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        @ViewBuilder layerView: @escaping () -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            ConditionalPortalTransitionModifier(
                id: id,
                config: config,
                isActive: isActive,
                layerView: layerView,
                completion: completion))
    }

    /// Applies a portal transition with direct parameter configuration.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the portal transition
    ///   - isActive: Boolean binding that controls the transition state
    ///   - animation: Animation to use for the transition (defaults to smooth animation)
    ///   - completionCriteria: How to detect animation completion (defaults to .removed)
    ///   - layerView: Closure that returns the view to animate during transition
    ///   - completion: Optional completion handler (defaults to no-op)
    /// - Returns: A view with the portal transition modifier applied
    func portalTransition<LayerView: View>(
        id: String,
        isActive: Binding<Bool>,
        in corners: PortalCorners? = nil,
        animation: Animation = PortalConstants.defaultAnimation,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping () -> LayerView
    ) -> some View {
        return self.modifier(
            ConditionalPortalTransitionModifier(
                id: id,
                isActive: isActive,
                in: corners,
                animation: animation,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView))
    }
}
