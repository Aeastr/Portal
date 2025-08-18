import SwiftUI

// MARK: - iOS 17+ Implementation

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
@available(iOS 17.0, *)
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
            }
            
            guard let idx = portalModel.info.firstIndex(where: { $0.infoID == key }) else { return }
            
            // Configure portal for forward animation
            portalModel.info[idx].initalized = true
            portalModel.info[idx].animation = config.animation
            portalModel.info[idx].corners = config.corners
            portalModel.info[idx].completion = completion
            portalModel.info[idx].layerView = AnyView(layerView(unwrapped))
            
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
            // Reset cached rects to capture fresh geometry at the start of reverse
            portalModel.info[idx].sourceRect = nil
            portalModel.info[idx].destinationRect = nil
            
            // Start reverse animation
            config.animation.performAnimation({
                portalModel.info[idx].animateView = false
            }) {
                // Phase 1: show destination immediately to avoid any flicker
                portalModel.info[idx].hideView = true
                
                // Phase 2: on the next tick, remove floating layer and finalize cleanup
                DispatchQueue.main.async {
                    portalModel.info[idx].layerView = nil
                    portalModel.info[idx].initalized = false
                    portalModel.info[idx].sourceAnchor = nil
                    portalModel.info[idx].destinationAnchor = nil
                    portalModel.info[idx].sourceRect = nil
                    portalModel.info[idx].destinationRect = nil
                    portalModel.info[idx].completion(false)
                }
            }
            
            // Clear stored key
            lastKey = nil
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

// MARK: - iOS 15+ Fallback Implementation

/// iOS 15 compatible version of OptionalPortalTransitionModifier using EnvironmentObject.
///
/// This fallback implementation provides the same functionality as the iOS 17 version
/// but uses the traditional EnvironmentObject pattern for compatibility with earlier iOS versions.
///
/// - Warning: This implementation is deprecated and will be removed in a future version.
///   Use the iOS 17+ version when possible.
@available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
public struct OptionalPortalTransitionModifierLegacy<Item: Identifiable, LayerView: View>: ViewModifier {
    
    /// Binding to the optional item that controls the portal transition.
    @Binding public var item: Item?
    
    /// Configuration object containing animation and styling parameters.
    public let config: PortalTransitionConfig
    
    /// Closure that generates the layer view for the transition animation.
    public let layerView: (Item) -> LayerView
    
    /// Completion handler called when the transition finishes.
    public let completion: (Bool) -> Void
    
    /// The shared portal model that manages all portal animations.
    @EnvironmentObject private var portalModel: CrossModelLegacy
    
    /// Tracks the last generated key to handle cleanup during reverse transitions.
    @State private var lastKey: String?
    
    /// Initializes a new optional portal transition modifier.
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
    private var key: String? {
        guard let value = item else { return nil }
        return "\(value.id)"
    }
    
    /// Handles changes to the item's presence, triggering appropriate portal transitions.
    private func onChange(oldValue: Bool, hasValue: Bool) {
        if hasValue {
            // Forward transition: item became non-nil
            guard let key = self.key, let unwrapped = item else { return }
            
            // Store key for potential cleanup
            lastKey = key
            
            // Ensure portal info exists in the model
            if portalModel.info.firstIndex(where: { $0.infoID == key }) == nil {
                portalModel.info.append(PortalInfo(id: key))
            }
            
            guard let idx = portalModel.info.firstIndex(where: { $0.infoID == key }) else { return }
            
            // Configure portal for forward animation
            portalModel.info[idx].initalized = true
            portalModel.info[idx].animation = config.animation
            portalModel.info[idx].corners = config.corners
            portalModel.info[idx].completion = completion
            portalModel.info[idx].layerView = AnyView(layerView(unwrapped))
            
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
            
            // Start reverse animation
            config.animation.performAnimation({
                portalModel.info[idx].animateView = false
            }) {
                // Complete cleanup after reverse animation
                portalModel.info[idx].initalized = false
                portalModel.info[idx].layerView = nil
                portalModel.info[idx].sourceAnchor = nil
                portalModel.info[idx].destinationAnchor = nil
                portalModel.info[idx].sourceRect = nil
                portalModel.info[idx].destinationRect = nil
                portalModel.info[idx].completion(false)
            }
            
            // Clear stored key
            lastKey = nil
        }
    }
    
    /// Applies the modifier to the content view.
    public func body(content: Content) -> some View {
        content.onChange(of: item != nil) { newValue in
            onChange(oldValue: !newValue, hasValue: newValue)
        }
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
///   - animation: The animation to use for the transition (default: `.bouncy(duration: 0.3)`).
///   - animationDuration: The duration of the transition animation (default: 0.3).
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
@available(iOS 17.0, *)
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
        portalInfoArray[idx].initalized = true
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
            // Reset cached rects to capture fresh geometry at the start of reverse
            portalInfoArray[idx].sourceRect = nil
            portalInfoArray[idx].destinationRect = nil
            
            config.animation.performAnimation({
                portalInfoArray[idx].animateView = false
            }) {
                // Phase 1: show destination immediately to avoid any flicker
                portalInfoArray[idx].hideView = true
                
                // Phase 2: on the next tick, remove floating layer and finalize cleanup
                DispatchQueue.main.async {
                    portalInfoArray[idx].layerView = nil
                    portalInfoArray[idx].initalized = false
                    portalInfoArray[idx].sourceAnchor = nil
                    portalInfoArray[idx].destinationAnchor = nil
                    portalInfoArray[idx].completion(false)
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

// MARK: - iOS 15+ Fallback Implementation

/// iOS 15 compatible version of ConditionalPortalTransitionModifier using EnvironmentObject.
///
/// This fallback implementation provides the same functionality as the iOS 17 version
/// but uses the traditional EnvironmentObject pattern for compatibility with earlier iOS versions.
///
/// - Warning: This implementation is deprecated and will be removed in a future version.
///   Use the iOS 17+ version when possible.
@available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
internal struct ConditionalPortalTransitionModifierLegacy<LayerView: View>: ViewModifier {
    
    /// The shared portal model that manages all portal animations.
    @EnvironmentObject private var portalModel: CrossModelLegacy
    
    /// Unique identifier for this portal transition.
    public let id: String
    
    /// Configuration object containing animation and styling parameters.
    public let config: PortalTransitionConfig
    
    /// Boolean binding that controls the portal transition state.
    @Binding public var isActive: Bool
    
    /// Closure that generates the layer view for the transition animation.
    public let layerView: () -> LayerView
    
    /// Completion handler called when the transition finishes.
    public let completion: (Bool) -> Void
    
    /// Initializes a new conditional portal transition modifier.
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
    private func onAppear() {
        if !portalModel.info.contains(where: { $0.infoID == id }) {
            portalModel.info.append(PortalInfo(id: id))
        }
    }
    
    /// Handles changes to the active state, triggering appropriate portal transitions.
    private func onChange(oldValue: Bool, newValue: Bool) {
        guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else { return }
        
        // Configure portal info for any transition
        portalModel.info[idx].initalized = true
        portalModel.info[idx].animation = config.animation
        portalModel.info[idx].corners = config.corners
        portalModel.info[idx].completion = completion
        portalModel.info[idx].layerView = AnyView(layerView())
        
        if newValue {
            // Forward transition: isActive became true
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
            // Reverse transition: isActive became false
            portalModel.info[idx].hideView = false
            
            config.animation.performAnimation({
                portalModel.info[idx].animateView = false
            }) {
                // Phase 1: show destination immediately to avoid any flicker
                portalModel.info[idx].hideView = true
                
                // Phase 2: on the next tick, remove floating layer and finalize cleanup
                DispatchQueue.main.async {
                    portalModel.info[idx].layerView = nil
                    portalModel.info[idx].initalized = false
                    portalModel.info[idx].sourceAnchor = nil
                    portalModel.info[idx].destinationAnchor = nil
                    portalModel.info[idx].sourceRect = nil
                    portalModel.info[idx].destinationRect = nil
                    portalModel.info[idx].completion(false)
                }
            }
        }
    }
    
    /// Applies the modifier to the content view.
    public func body(content: Content) -> some View {
        content
            .onAppear(perform: onAppear)
            .onChange(of: isActive) { newValue in
                onChange(oldValue: !newValue, newValue: newValue)
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
    @available(iOS 15.0, *)
    func portalTransition<LayerView: View>(
        id: String,
        config: PortalTransitionConfig = .init(),
        isActive: Binding<Bool>,
        @ViewBuilder layerView: @escaping () -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(
                ConditionalPortalTransitionModifier(
                    id: id,
                    config: config,
                    isActive: isActive,
                    layerView: layerView,
                    completion: completion))
        } else {
            return self.modifier(
                ConditionalPortalTransitionModifierLegacy(
                    id: id,
                    config: config,
                    isActive: isActive,
                    layerView: layerView,
                    completion: completion))
        }
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
    @available(iOS 15.0, *)
    func portalTransition<Item: Identifiable, LayerView: View>(
        item: Binding<Optional<Item>>,
        config: PortalTransitionConfig = .init(),
        @ViewBuilder layerView: @escaping (Item) -> LayerView,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(
                OptionalPortalTransitionModifier(
                    item: item,
                    config: config,
                    layerView: layerView,
                    completion: completion
                )
            )
        } else {
            return self.modifier(
                OptionalPortalTransitionModifierLegacy(
                    item: item,
                    config: config,
                    layerView: layerView,
                    completion: completion
                )
            )
        }
    }
}
