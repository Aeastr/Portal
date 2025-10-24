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

    /// Configuration object containing animation and styling parameters.
    ///
    /// Defines how the portal transition behaves, including timing, easing curves,
    /// corner styling, and completion criteria.
    public let config: PortalTransitionConfig

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

    /// Initializes a new optional portal transition modifier.
    ///
    /// - Parameters:
    ///   - item: Binding to the optional item that controls the transition
    ///   - config: Configuration for animation and styling behavior
    ///   - layerView: Closure that generates the transition layer view
    ///   - completion: Handler called when the transition completes
    public init(
        item: Binding<Item?>,
        config: PortalTransitionConfig,
        layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void
    ) {
        self._item = item
        self.config = config
        self.layerView = layerView
        self.completion = completion
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
            if portalModel.info.firstIndex(where: { $0.infoID == key }) == nil {
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
            portalModel.info[idx].animation = config.animation
            portalModel.info[idx].corners = config.corners
            portalModel.info[idx].completion = completion
            portalModel.info[idx].layerView = AnyView(layerView(unwrapped))

            PortalLogs.logger.log(
                "Starting forward portal transition",
                level: .notice,
                tags: [PortalLogs.Tags.transition],
                metadata: [
                    "id": key,
                    "delay_ms": Int(config.animation.delay * 1_000)
                ]
            )

            // Start animation after configured delay
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                config.animation.performAnimation({
                    portalModel.info[idx].animateView = true
                }) {
                    // Hide destination view and notify completion
                    portalModel.info[idx].hideView = true
                    portalModel.info[idx].completion(true)
                }
            }
            
        } else {
            // Reverse transition: item became nil
            guard let key = lastKey,
                  let idx = portalModel.info.firstIndex(where: { $0.infoID == key })
            else { return }

            // Prepare for reverse animation
            portalModel.info[idx].hideView = false

            PortalLogs.logger.log(
                "Reversing portal transition",
                level: .notice,
                tags: [PortalLogs.Tags.transition],
                metadata: ["id": key]
            )

            // Start reverse animation
            config.animation.performAnimation({
                portalModel.info[idx].animateView = false
            }) {
                // Complete cleanup after reverse animation
                portalModel.info[idx].initialized = false
                portalModel.info[idx].layerView = nil
                portalModel.info[idx].sourceAnchor = nil
                portalModel.info[idx].destinationAnchor = nil
                portalModel.info[idx].completion(false)
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
internal struct ConditionalPortalTransitionModifier<LayerView: View>: ViewModifier {

    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

    /// Unique identifier for this portal transition.
    ///
    /// This ID must match the IDs used by the corresponding portal source and
    /// destination views for the transition to work correctly.
    public let id: String

    /// Configuration object containing animation and styling parameters.
    public let config: PortalTransitionConfig

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
    ///   - config: Configuration for animation and styling behavior
    ///   - isActive: Binding that controls the transition state
    ///   - layerView: Closure that generates the transition layer view
    ///   - completion: Handler called when the transition completes
    public init(
        id: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        layerView: @escaping () -> LayerView,
        completion: @escaping (Bool) -> Void
    ) {
        self.id = id
        self.config = config
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
        
        var portalInfoArray: [PortalInfo] {
            get { portalModel.info }
            set { portalModel.info = newValue }
        }
        
        // Configure portal info for any transition
        portalInfoArray[idx].initialized = true
        portalInfoArray[idx].animation = config.animation
        portalInfoArray[idx].corners = config.corners
        portalInfoArray[idx].completion = completion
        portalInfoArray[idx].layerView = AnyView(layerView())

        if newValue {
            // Forward transition: isActive became true
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                config.animation.performAnimation({
                    portalInfoArray[idx].animateView = true
                }) {
                    // Hide destination view and notify completion
                    portalInfoArray[idx].hideView = true
                    portalInfoArray[idx].completion(true)
                }
            }
            
        } else {
            // Reverse transition: isActive became false
            portalInfoArray[idx].hideView = false
            
            config.animation.performAnimation({
                portalInfoArray[idx].animateView = false
            }) {
                // Complete cleanup after reverse animation
                portalInfoArray[idx].initialized = false
                portalInfoArray[idx].layerView = nil
                portalInfoArray[idx].sourceAnchor = nil
                portalInfoArray[idx].destinationAnchor = nil
                portalInfoArray[idx].completion(false)
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
public struct MultiIDPortalTransitionModifier<LayerView: View>: ViewModifier {

    /// Array of portal IDs to animate together.
    public let ids: [String]

    /// Group identifier for coordinating the animations.
    public let groupID: String

    /// Configuration object containing animation and styling parameters.
    public let config: PortalTransitionConfig

    /// Boolean binding that controls the portal transition state.
    @Binding public var isActive: Bool

    /// Closure that generates the layer view for each ID in the transition.
    public let layerView: (String) -> LayerView

    /// Completion handler called when all transitions finish.
    public let completion: (Bool) -> Void

    /// The shared portal model that manages all portal animations.
    @Environment(CrossModel.self) private var portalModel

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
        self.config = config
        self._isActive = isActive
        self.layerView = layerView
        self.completion = completion
    }

    /// Ensures portal info exists for all IDs when the view appears.
    private func onAppear() {
        for id in ids {
            if !portalModel.info.contains(where: { $0.infoID == id }) {
                portalModel.info.append(PortalInfo(id: id, groupID: groupID))
            }
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
                portalModel.info[idx].animation = config.animation
                portalModel.info[idx].corners = config.corners
                portalModel.info[idx].groupID = groupID
                portalModel.info[idx].isGroupCoordinator = (i == 0)
                portalModel.info[idx].layerView = AnyView(layerView(portalID))

                // Only coordinator gets completion callback
                if i == 0 {
                    portalModel.info[idx].completion = completion
                } else {
                    portalModel.info[idx].completion = { _ in }
                }
            }

            // Start coordinated animation
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                config.animation.performAnimation({
                    for idx in groupIndices {
                        portalModel.info[idx].animateView = true
                    }
                }) {
                    for idx in groupIndices {
                        portalModel.info[idx].hideView = true
                        if portalModel.info[idx].isGroupCoordinator {
                            portalModel.info[idx].completion(true)
                        }
                    }
                }
            }

        } else {
            // Reverse transition: isActive became false
            for idx in groupIndices {
                portalModel.info[idx].hideView = false
            }

            config.animation.performAnimation({
                for idx in groupIndices {
                    portalModel.info[idx].animateView = false
                }
            }) {
                for idx in groupIndices {
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

    public func body(content: Content) -> some View {
        content
            .onAppear(perform: onAppear)
            .onChange(of: isActive, onChange)
    }
}

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
public struct MultiItemPortalTransitionModifier<Item: Identifiable, LayerView: View>: ViewModifier {
    
    /// Binding to the array of items that controls the portal transitions.
    @Binding public var items: [Item]
    
    /// Group identifier for coordinating the animations.
    public let groupID: String
    
    /// Configuration object containing animation and styling parameters.
    public let config: PortalTransitionConfig
    
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
    @State private var lastKeys: Set<String> = []
    
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
        self.config = config
        self.layerView = layerView
        self.completion = completion
        self.staggerDelay = staggerDelay
    }
    
    /// Generates string keys from the current items' IDs.
    private var keys: Set<String> {
        Set(items.map { "\($0.id)" })
    }
    
    /// Handles changes to the items array, triggering appropriate portal transitions.
    private func onChange(oldValue: [Item], hasItems: Bool) {
        let currentKeys = keys
        
        if hasItems && !items.isEmpty {
            // Forward transition: items were added
            lastKeys = currentKeys
            
            // Ensure portal info exists for all items
            for item in items {
                let key = "\(item.id)"
                if portalModel.info.firstIndex(where: { $0.infoID == key }) == nil {
                    portalModel.info.append(PortalInfo(id: key, groupID: groupID))
                }
            }
            
            // Configure all portals in the group
            let groupIndices = portalModel.info.enumerated().compactMap { index, info in
                currentKeys.contains(info.infoID) ? index : nil
            }
            
            // Set up group coordination - first item becomes coordinator
            for (i, idx) in groupIndices.enumerated() {
                portalModel.info[idx].initialized = true
                portalModel.info[idx].animation = config.animation
                portalModel.info[idx].corners = config.corners
                portalModel.info[idx].groupID = groupID
                portalModel.info[idx].isGroupCoordinator = (i == 0)
                
                // Find the corresponding item for this portal
                if let item = items.first(where: { "\($0.id)" == portalModel.info[idx].infoID }) {
                    portalModel.info[idx].layerView = AnyView(layerView(item))
                }
                
                // Only coordinator gets completion callback
                if i == 0 {
                    portalModel.info[idx].completion = completion
                } else {
                    portalModel.info[idx].completion = { _ in }
                }
            }
            
            // Start staggered animations
            if staggerDelay > 0 {
                // Staggered animation: start each item with increasing delay
                for (i, idx) in groupIndices.enumerated() {
                    let itemDelay = config.animation.delay + (TimeInterval(i) * staggerDelay)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + itemDelay) {
                        config.animation.performAnimation({
                            portalModel.info[idx].animateView = true
                        }) {
                            // Hide destination view for this item
                            portalModel.info[idx].hideView = true
                            
                            // Only coordinator calls completion, and only after the last item
                            if portalModel.info[idx].isGroupCoordinator {
                                // Wait for the last item to finish before calling completion
                                let lastItemDelay = TimeInterval(groupIndices.count - 1) * staggerDelay
                                DispatchQueue.main.asyncAfter(deadline: .now() + lastItemDelay) {
                                    portalModel.info[idx].completion(true)
                                }
                            }
                        }
                    }
                }
            } else {
                // Coordinated animation: all items start together
                DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                    config.animation.performAnimation({
                        for idx in groupIndices {
                            portalModel.info[idx].animateView = true
                        }
                    }) {
                        // Hide destination views and notify completion (only coordinator calls completion)
                        for idx in groupIndices {
                            portalModel.info[idx].hideView = true
                            if portalModel.info[idx].isGroupCoordinator {
                                portalModel.info[idx].completion(true)
                            }
                        }
                    }
                }
            }
            
        } else {
            // Reverse transition: items were cleared
            let cleanupKeys = lastKeys
            let cleanupIndices = portalModel.info.enumerated().compactMap { index, info in
                cleanupKeys.contains(info.infoID) ? index : nil
            }
            
            // Prepare for reverse animation
            for idx in cleanupIndices {
                portalModel.info[idx].hideView = false
            }
            
            // Start coordinated reverse animation
            config.animation.performAnimation({
                for idx in cleanupIndices {
                    portalModel.info[idx].animateView = false
                }
            }) {
                // Complete cleanup after reverse animation
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
            
            lastKeys.removeAll()
        }
    }
    
    public func body(content: Content) -> some View {
        content.onChange(of: !items.isEmpty) {
            onChange(oldValue: items, hasItems: !items.isEmpty)
        }
    }
}

// MARK: - View Extensions

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
    @available(*, deprecated, message: "Use the new API with direct parameters instead of config")
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
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        @ViewBuilder layerView: @escaping () -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            ConditionalPortalTransitionModifierDirect(
                id: id,
                animation: animation,
                completionCriteria: completionCriteria,
                isActive: isActive,
                layerView: layerView,
                completion: completion))
    }

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
    func portalTransition<LayerView: View>(
        ids: [String],
        groupID: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        @ViewBuilder layerView: @escaping (String) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            MultiIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                config: config,
                isActive: isActive,
                layerView: layerView,
                completion: completion))
    }
    
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
    @available(*, deprecated, message: "Use the new API with direct parameters instead of config")
    func portalTransition<Item: Identifiable, LayerView: View>(
        item: Binding<Optional<Item>>,
        config: PortalTransitionConfig,
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            OptionalPortalTransitionModifier(
                item: item,
                config: config,
                layerView: layerView,
                completion: completion
            )
        )
    }

    /// Applies a portal transition with direct parameters controlled by an optional item.
    ///
    /// - Parameters:
    ///   - item: Binding to an optional `Identifiable` item that controls the transition
    ///   - animation: Animation to use for the transition (defaults to smooth animation)
    ///   - completionCriteria: How to detect animation completion (defaults to .removed)
    ///   - layerView: Closure that receives the item and returns the view to animate
    ///   - completion: Optional completion handler (defaults to no-op)
    /// - Returns: A view with the portal transition modifier applied
    func portalTransition<Item: Identifiable, LayerView: View>(
        item: Binding<Optional<Item>>,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            OptionalPortalTransitionModifierDirect(
                item: item,
                animation: animation,
                completionCriteria: completionCriteria,
                layerView: layerView,
                completion: completion
            )
        )
    }
    
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
    func portalTransition<Item: Identifiable, LayerView: View>(
        items: Binding<[Item]>,
        groupID: String,
        config: PortalTransitionConfig,
        staggerDelay: TimeInterval = 0.0,
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        return self.modifier(
            MultiItemPortalTransitionModifier(
                items: items,
                groupID: groupID,
                config: config,
                layerView: layerView,
                completion: completion,
                staggerDelay: staggerDelay
            )
        )
    }
}
