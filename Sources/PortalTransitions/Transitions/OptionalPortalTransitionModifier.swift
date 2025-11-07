//
//  OptionalPortalTransitionModifier.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A view modifier that manages portal transitions based on optional `Identifiable` items.
///
/// This modifier automatically handles portal transitions when an optional item changes between
/// `nil` and a non-`nil` value. It's particularly useful for detail view presentations, modal
/// transitions, or any scenario where the presence of data determines the transition state.
///
/// **Key Features:**
/// - Automatic ID generation from `Identifiable` items
/// - State management for optional values
/// - Lifecycle management with proper cleanup
/// - Configurable animation and styling
///
/// **Usage Pattern:**
/// The modifier monitors changes to an optional item binding. When the item becomes non-nil,
/// it initiates a forward portal transition. When the item becomes nil, it initiates a
/// reverse portal transition with proper cleanup.
///
/// **Example Scenario:**
/// ```swift
/// @State private var selectedPhoto: Photo? = nil
///
/// PhotoGridView()
///     .portalTransition(item: $selectedPhoto) { photo in
///         AsyncImage(url: photo.fullSizeURL)
///             .aspectRatio(contentMode: .fit)
///     }
/// ```
public struct OptionalPortalTransitionModifier<Item: Identifiable, LayerView: View>: ViewModifier {
    /// Binding to the optional item that controls the portal transition.
    ///
    /// When this value changes from `nil` to non-`nil`, a forward portal transition
    /// is initiated. When it changes from non-`nil` to `nil`, a reverse transition
    /// with cleanup is performed.
    @Binding public var item: Item?

    /// Animation to use for the transition.
    public let animation: Animation

    /// Corner styling configuration for visual appearance.
    public let corners: PortalCorners?

    /// Controls fade-out behavior when the portal layer is removed.
    public let transition: PortalRemoveTransition

    /// Completion criteria for detecting when the animation finishes.
    public let completionCriteria: AnimationCompletionCriteria

    /// Closure that generates the layer view for the transition animation.
    ///
    /// This closure receives the unwrapped item and returns the view that will
    /// be animated during the portal transition. The view should represent the
    /// visual content that bridges the source and destination views.
    public let layerView: (Item) -> LayerView

    /// Completion handler called when the transition finishes.
    ///
    /// Called with `true` when the transition completes successfully, or `false`
    /// when the transition is cancelled or fails. This allows for additional
    /// UI updates or state changes after the portal animation.
    public let completion: (Bool) -> Void

    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

    /// Tracks the last generated key to handle cleanup during reverse transitions.
    ///
    /// Since the item becomes `nil` during reverse transitions, we need to remember
    /// the last key to properly clean up the portal state.
    @State private var lastKey: String?

    /// Initializes a new optional portal transition modifier with direct parameters.
    ///
    /// - Parameters:
    ///   - item: Binding to the optional item that controls the transition
    ///   - corners: Corner styling (defaults to environment value)
    ///   - animation: Animation to use for the transition
    ///   - transition: Fade-out behavior for layer removal
    ///   - completionCriteria: How to detect animation completion
    ///   - completion: Handler called when the transition completes
    ///   - layerView: Closure that generates the transition layer view
    public init(
        item: Binding<Item?>,
        in corners: PortalCorners? = nil,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void,
        @ViewBuilder layerView: @escaping (Item) -> LayerView
    ) {
        self._item = item
        self.corners = corners
        self.animation = animation
        self.transition = transition
        self.completionCriteria = completionCriteria
        self.completion = completion
        self.layerView = layerView

        // Validate animation duration
        Self.validateAnimationDuration(animation)
    }

    /// Validates animation duration and logs a warning if it's too short for sheet transitions.
    private static func validateAnimationDuration(_ animation: Animation) {
        // Extract duration from animation if possible
        let mirror = Mirror(reflecting: animation)

        // Try to find duration in the animation's structure
        if let duration = Self.extractDuration(from: mirror) {
            if duration < PortalConstants.minimumSheetAnimationDuration {
                let message = "Portal transition: Animation duration (\(String(format: "%.2f", duration))s) is below recommended minimum (\(String(format: "%.2f", PortalConstants.minimumSheetAnimationDuration))s) for sheet transitions. This may cause visual artifacts."

                // Runtime warning that shows in Xcode console
                #if DEBUG
                assertionFailure(message)
                #endif

                // Also log for non-debug builds
                PortalLogs.logger.log(
                    message,
                    level: .warning,
                    tags: [PortalLogs.Tags.transition],
                    metadata: ["duration": "\(duration)", "minimum": "\(PortalConstants.minimumSheetAnimationDuration)"]
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

    /// Generates a string key from the current item's ID.
    ///
    /// Returns `nil` when the item is `nil`, or a string representation of the
    /// item's ID when the item is present. This key is used to identify the
    /// portal in the global portal model.
    private var key: String? {
        guard let value = item else { return nil }
        return "\(value.id)"
    }

    /// Handles changes to the item's presence, triggering appropriate portal transitions.
    ///
    /// This method is called whenever the item binding changes between `nil` and non-`nil`
    /// values. It manages the complete lifecycle of portal transitions, including
    /// initialization, animation, and cleanup.
    ///
    /// **Forward Transition (hasValue = true):**
    /// 1. Generates portal key from item ID
    /// 2. Creates or retrieves portal info in the model
    /// 3. Configures animation and layer view
    /// 4. Initiates delayed animation with completion handling
    ///
    /// **Reverse Transition (hasValue = false):**
    /// 1. Uses stored lastKey for portal identification
    /// 2. Initiates reverse animation
    /// 3. Performs complete cleanup on completion
    /// 4. Clears the lastKey
    ///
    /// - Parameters:
    ///   - oldValue: Previous value of the hasValue state (unused but required by onChange)
    ///   - hasValue: Current presence state of the item (true if item is non-nil)
    private func onChange(oldValue: Bool, hasValue: Bool) {
        if hasValue {
            // Forward transition: item became non-nil
            guard let key = self.key, let unwrapped = item else { return }

            // Store key for potential cleanup
            lastKey = key

            // Ensure portal info exists in the model
            if !portalModel.info.contains(where: { $0.infoID == key }) {
                portalModel.info.append(PortalInfo(id: key))
                PortalLogs.logger.log(
                    "Registered new portal info",
                    level: .debug,
                    tags: [PortalLogs.Tags.transition],
                    metadata: ["id": key]
                )
            }

            guard let idx = portalModel.info.firstIndex(where: { $0.infoID == key }) else {
                PortalLogs.logger.log(
                    "Portal info lookup failed after registration",
                    level: .error,
                    tags: [PortalLogs.Tags.transition],
                    metadata: ["id": key]
                )
                return
            }

            // Configure portal for forward animation
            portalModel.info[idx].initialized = true
            portalModel.info[idx].animation = animation
            portalModel.info[idx].completionCriteria = completionCriteria
            portalModel.info[idx].corners = corners
            portalModel.info[idx].fade = transition
            portalModel.info[idx].completion = completion
            portalModel.info[idx].layerView = AnyView(layerView(unwrapped))
            portalModel.info[idx].showLayer = true

            PortalLogs.logger.log(
                "Starting forward portal transition",
                level: .notice,
                tags: [PortalLogs.Tags.transition],
                metadata: [
                    "id": key,
                    "delay_ms": Int(PortalConstants.animationDelay * 1_000)
                ]
            )

            // Start animation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
                withAnimation(animation, completionCriteria: completionCriteria) {
                    portalModel.info[idx].animateView = true
                } completion: {
                    PortalLogs.logger.log(
                        "Animation completed, showing destination",
                        level: .debug,
                        tags: [PortalLogs.Tags.transition],
                        metadata: ["id": key, "hideView": "true"]
                    )

                    // Show destination first, then hide layer after ensuring it's rendered
                    portalModel.info[idx].hideView = true

                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        PortalLogs.logger.log(
                            "Hiding transition layer",
                            level: .debug,
                            tags: [PortalLogs.Tags.transition],
                            metadata: ["id": key, "showLayer": "false"]
                        )

                        // Hide layer after destination is visible
                        portalModel.info[idx].showLayer = false

                        Task { @MainActor in
                            // Notify completion after handoff
                            portalModel.info[idx].completion(true)
                        }
                    }
                }
            }
        } else {
            // Reverse transition: item became nil
            guard let key = lastKey,
                  let idx = portalModel.info.firstIndex(where: { $0.infoID == key })
            else { return }

            // Prepare for reverse animation
            portalModel.info[idx].hideView = false
            portalModel.info[idx].showLayer = true

            PortalLogs.logger.log(
                "Reversing portal transition",
                level: .notice,
                tags: [PortalLogs.Tags.transition],
                metadata: ["id": key]
            )

            // Start reverse animation
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

            // Clear stored key
            lastKey = nil

            PortalLogs.logger.log(
                "Completed reverse portal transition cleanup",
                level: .debug,
                tags: [PortalLogs.Tags.transition],
                metadata: ["id": key]
            )
        }
    }

    /// Applies the modifier to the content view.
    ///
    /// Attaches an onChange handler that monitors the presence of the item
    /// and triggers portal transitions accordingly.
    public func body(content: Content) -> some View {
        content.onChange(of: item != nil, onChange)
    }
}

public extension View {
    /// Applies a portal transition controlled by an optional `Identifiable` item.
    ///
    /// This modifier automatically manages portal transitions based on the presence
    /// of an optional item. When the item becomes non-nil, a forward transition is
    /// triggered. When it becomes nil, a reverse transition is triggered.
    ///
    /// **Usage Pattern:**
    /// ```swift
    /// @State private var selectedItem: MyItem? = nil
    ///
    /// ContentView()
    ///     .portalTransition(item: $selectedItem) { item in
    ///         DetailView(item: item)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - item: Binding to an optional `Identifiable` item that controls the transition
    ///   - config: Configuration for animation and styling (optional, defaults to standard config)
    ///   - layerView: Closure that receives the item and returns the view to animate
    ///   - completion: Optional completion handler (defaults to no-op)
    /// - Returns: A view with the portal transition modifier applied
    /// Applies a portal transition with direct parameters controlled by an optional item.
    ///
    /// - Parameters:
    ///   - item: Binding to an optional `Identifiable` item that controls the transition
    ///   - in corners: Corner radius configuration for visual styling
    ///   - animation: Animation to use for the transition (defaults to smooth animation)
    ///   - transition: Fade-out behavior for layer removal (defaults to .fade)
    ///   - completionCriteria: How to detect animation completion (defaults to .removed)
    ///   - completion: Optional completion handler (defaults to no-op)
    ///   - layerView: Closure that receives the item and returns the view to animate
    /// - Returns: A view with the portal transition modifier applied
    func portalTransition<Item: Identifiable, LayerView: View>(
        item: Binding<Item?>,
        in corners: PortalCorners? = nil,
        animation: Animation = PortalConstants.defaultAnimation,
        transition: PortalRemoveTransition = .none,
        completionCriteria: AnimationCompletionCriteria = .removed,
        completion: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder layerView: @escaping (Item) -> LayerView
    ) -> some View {
        return self.modifier(
            OptionalPortalTransitionModifier(
                item: item,
                in: corners,
                animation: animation,
                transition: transition,
                completionCriteria: completionCriteria,
                completion: completion,
                layerView: layerView
            )
        )
    }
}
