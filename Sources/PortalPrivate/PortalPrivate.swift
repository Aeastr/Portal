//
//  PortalPrivate.swift
//  Portal
//
//  Portal transitions using _UIPortalView for true view instance sharing
//

import SwiftUI
import Portal
import PortalView

// MARK: - Extended Portal Info

/// Extended portal info that includes the source container for view mirroring
@MainActor
public class PortalPrivateInfo {
    /// The source view container holding the UIHostingController
    public var sourceContainer: AnyObject? = nil

    /// Whether the portal is using private implementation
    public var isPrivatePortal: Bool = false
}

// MARK: - Storage for Private Portal Info

@MainActor
private class PortalPrivateStorage {
    static let shared = PortalPrivateStorage()

    // Use NSMapTable with strong keys and weak values for automatic cleanup
    private let storage = NSMapTable<NSString, PortalPrivateInfo>(
        keyOptions: .strongMemory,
        valueOptions: .weakMemory
    )

    // Cache for frequently accessed items to avoid repeated lookups
    private var cache: [String: PortalPrivateInfo] = [:]
    private let cacheLimit = 10 // Keep only the most recent items

    func setInfo(_ info: PortalPrivateInfo?, for key: String) {
        if let info = info {
            storage.setObject(info, forKey: key as NSString)
            updateCache(key: key, info: info)
        } else {
            storage.removeObject(forKey: key as NSString)
            cache.removeValue(forKey: key)
        }
    }

    func getInfo(for key: String) -> PortalPrivateInfo? {
        // Check cache first
        if let cached = cache[key] {
            return cached
        }

        // Fall back to storage
        if let info = storage.object(forKey: key as NSString) {
            updateCache(key: key, info: info)
            return info
        }

        return nil
    }

    func removeInfo(for key: String) {
        storage.removeObject(forKey: key as NSString)
        cache.removeValue(forKey: key)
    }

    private func updateCache(key: String, info: PortalPrivateInfo) {
        cache[key] = info

        // Limit cache size by removing oldest entries
        if cache.count > cacheLimit {
            // Simple FIFO eviction - remove first inserted item
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
    }

}

// MARK: - PortalPrivate View Wrapper

/// A view that manages a single SwiftUI view instance that can be shown in multiple places
public struct PortalPrivate<Content: View>: View {
    private let id: String
    private let groupID: String?
    @ViewBuilder private let content: () -> Content
    @State private var sourceContainer: SourceViewContainer<AnyView>?
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalDebugOverlays) private var debugOverlaysEnabled

    public init(id: String, groupID: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.id = id
        self.groupID = groupID
        self.content = content
    }

    public var body: some View {
        ZStack {
            // Create and store the source container on appear
            Color.clear
                .frame(width: 0, height: 0)
                
                .onAppear {
                    if sourceContainer == nil {
                        // Create type-erased container that can be shared
                        let container = SourceViewContainer(content: AnyView(content().environment(portalModel)))
                        sourceContainer = container

                        // Store in private storage
                        let info = PortalPrivateInfo()
                        info.sourceContainer = container
                        info.isPrivatePortal = true
                        PortalPrivateStorage.shared.setInfo(info, for: id)

                        // Ensure portal info exists in model
                        if !portalModel.info.contains(where: { $0.infoID == id }) {
                            portalModel.info.append(PortalInfo(id: id, groupID: groupID))
                        } else if let idx = portalModel.info.firstIndex(where: { $0.infoID == id }), let groupID = groupID {
                            // Update groupID if provided
                            portalModel.info[idx].groupID = groupID
                        }
                    }
                }
                .onDisappear {
                    // Clean up
                    PortalPrivateStorage.shared.removeInfo(for: id)
                }

            // The actual source view (hidden when destination anchor exists)
            if let container = sourceContainer {
                SourceViewRepresentable(
                    container: container,
                    content: AnyView(content().environment(portalModel))
                )
                .opacity(portalModel.info.first(where: { $0.infoID == id })?.destinationAnchor == nil ? 1 : 0)
                .overlay(
                    Group {
                        #if DEBUG
                        if debugOverlaysEnabled {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.purple, lineWidth: 2)
                                .overlay(
                                    DebugOverlayIndicator("PortalPrivate", color: .purple)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                        .padding(5)
                                )
                        }
                        #endif
                    }
                )
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    [id: anchor]
                }
                .onPreferenceChange(AnchorKey.self) { prefs in
                    Task { @MainActor in
                        guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else {
                            return
                        }

                        // Don't require initialized - we need to set anchor even before transition
                        guard let anchor = prefs[id] else {
                            return
                        }

                        // Update source anchor for positioning
                        portalModel.info[idx].sourceAnchor = anchor
                    }
                }
            }
        }
    }
}

// MARK: - View Extensions

public extension View {
    /// Marks this view as a private portal that uses view mirroring
    ///
    /// Unlike regular portals, this creates a single view instance that can be
    /// displayed in multiple places using _UIPortalView.
    ///
    /// Example:
    /// ```swift
    /// MyComplexView()
    ///     .portalPrivate(id: "myView")
    /// ```
    func portalPrivate<Content: View>(
        id: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            PortalPrivate(id: id, content: content)
        )
    }

    /// Simplified portal private for when the view itself should be mirrored
    func portalPrivate(id: String) -> some View {
        PortalPrivate(id: id) {
            self
        }
    }

    /// Marks this view as a private portal with a groupID for coordinated animations
    ///
    /// Example:
    /// ```swift
    /// MyComplexView()
    ///     .portalPrivate(id: "myView", groupID: "viewGroup")
    /// ```
    func portalPrivate(id: String, groupID: String) -> some View {
        PortalPrivate(id: id, groupID: groupID) {
            self
        }
    }

    /// Marks this view as a private portal using an `Identifiable` item's ID
    ///
    /// This creates a single view instance that can be displayed in multiple places
    /// using _UIPortalView, automatically extracting the string representation of
    /// an `Identifiable` item's ID.
    ///
    /// Example:
    /// ```swift
    /// MyComplexView()
    ///     .portalPrivate(item: book)
    /// ```
    func portalPrivate<Item: Identifiable>(item: Item) -> some View {
        let key: String
        if let uuid = item.id as? UUID {
            key = uuid.uuidString
        } else {
            key = "\(item.id)"
        }
        return PortalPrivate(id: key) {
            self
        }
    }

    /// Marks this view as a private portal using an `Identifiable` item's ID and group
    ///
    /// This creates a single view instance that can be displayed in multiple places
    /// using _UIPortalView, with support for coordinated group animations.
    ///
    /// Example:
    /// ```swift
    /// PhotoView(photo: photo)
    ///     .portalPrivate(item: photo, groupID: "photoStack")
    /// ```
    func portalPrivate<Item: Identifiable>(item: Item, groupID: String) -> some View {
        let key: String
        if let uuid = item.id as? UUID {
            key = uuid.uuidString
        } else {
            key = "\(item.id)"
        }
        return PortalPrivate(id: key, groupID: groupID) {
            self
        }
    }

    /// Triggers a portal transition for a private portal using the mirrored view (deprecated)
    ///
    /// This modifier triggers the animation for PortalPrivate views.
    /// Unlike regular `.portalTransition`, you don't provide a layer view
    /// since it uses the _UIPortalView mirror of the source.
    ///
    /// - Deprecated: Use the new API with animation as a direct parameter
    @available(*, deprecated, message: "Use the new API with animation as a direct parameter instead of config")
    func portalPrivateTransition(
        id: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateTransitionModifier(
                id: id,
                config: config,
                isActive: isActive,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    /// Triggers a portal transition for a private portal using the mirrored view
    ///
    /// This modifier triggers the animation for PortalPrivate views.
    /// Unlike regular `.portalTransition`, you don't provide a layer view
    /// since it uses the _UIPortalView mirror of the source.
    ///
    /// Example:
    /// ```swift
    /// .portalPrivateTransition(
    ///     id: "myView",
    ///     isActive: $showDetail,
    ///     animation: .smooth(duration: 0.5),
    ///     hidesSource: true
    /// )
    /// ```
    func portalPrivateTransition(
        id: String,
        isActive: Binding<Bool>,
        animation: PortalAnimation = .init(),
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateTransitionModifierDirect(
                id: id,
                animation: animation,
                isActive: isActive,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    /// Triggers a portal transition for a private portal with an optional item (deprecated)
    @available(*, deprecated, message: "Use the new API with animation as a direct parameter instead of config")
    func portalPrivateTransition<Item: Identifiable>(
        item: Binding<Item?>,
        config: PortalTransitionConfig,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateItemTransitionModifier(
                item: item,
                config: config,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    /// Triggers a portal transition for a private portal with an optional item
    func portalPrivateTransition<Item: Identifiable>(
        item: Binding<Item?>,
        animation: PortalAnimation = .init(),
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateItemTransitionModifierDirect(
                item: item,
                animation: animation,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    /// Triggers coordinated portal transitions for multiple private portal IDs.
    ///
    /// This modifier enables multiple portal animations to run simultaneously as a coordinated group
    /// using string IDs. All IDs in the array are animated together with synchronized timing.
    ///
    /// Example:
    /// ```swift
    /// .portalPrivateTransition(
    ///     ids: ["portal1", "portal2", "portal3"],
    ///     groupID: "myGroup",
    ///     isActive: $showPortals
    /// )
    /// ```
    @available(*, deprecated, message: "Use the new API with animation as a direct parameter instead of config")
    func portalPrivateTransition(
        ids: [String],
        groupID: String,
        config: PortalTransitionConfig,
        isActive: Binding<Bool>,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            MultiIDPortalPrivateTransitionModifier(
                ids: ids,
                groupID: groupID,
                config: config,
                isActive: isActive,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    func portalPrivateTransition(
        ids: [String],
        groupID: String,
        isActive: Binding<Bool>,
        animation: PortalAnimation = .init(),
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            MultiIDPortalPrivateTransitionModifierDirect(
                ids: ids,
                groupID: groupID,
                animation: animation,
                isActive: isActive,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    /// Triggers coordinated portal transitions for multiple private portal items.
    ///
    /// This modifier enables multiple portal animations to run simultaneously as a coordinated group.
    /// All items in the array are animated together with synchronized timing.
    ///
    /// Example:
    /// ```swift
    /// .portalPrivateTransition(
    ///     items: $selectedPhotos,
    ///     groupID: "photoStack"
    /// )
    /// ```
    @available(*, deprecated, message: "Use the new API with animation as a direct parameter instead of config")
    func portalPrivateTransition<Item: Identifiable>(
        items: Binding<[Item]>,
        groupID: String,
        config: PortalTransitionConfig,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            MultiItemPortalPrivateTransitionModifier(
                items: items,
                groupID: groupID,
                config: config,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    func portalPrivateTransition<Item: Identifiable>(
        items: Binding<[Item]>,
        groupID: String,
        animation: PortalAnimation = .init(),
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            MultiItemPortalPrivateTransitionModifierDirect(
                items: items,
                groupID: groupID,
                animation: animation,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

}

// MARK: - Transition Modifiers

/// Transition modifier for private portals with boolean state
struct PortalPrivateTransitionModifier: ViewModifier {
    let id: String
    let config: PortalTransitionConfig
    @Binding var isActive: Bool
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel

    func body(content: Content) -> some View {
        content
            .onChange(of: isActive) { _, newValue in
                guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else { return }

                // Initialize portal info
                portalModel.info[idx].initialized = true
                portalModel.info[idx].animation = config.animation
                portalModel.info[idx].corners = config.corners
                portalModel.info[idx].completion = completion

                // Set the layer view to use the PortalView of the stored container
                if let privateInfo = PortalPrivateStorage.shared.getInfo(for: id),
                   let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView> {
                    portalModel.info[idx].layerView = AnyView(
                        PortalView(
                            source: container,
                            hidesSource: hidesSource,
                            matchesAlpha: matchesAlpha,
                            matchesTransform: matchesTransform,
                            matchesPosition: matchesPosition
                        )
                    )
                }

                if newValue {
                    // Forward transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                        config.animation.performAnimation({
                            portalModel.info[idx].animateView = true
                        }) {
                            portalModel.info[idx].hideView = true
                            portalModel.info[idx].completion(true)
                        }
                    }
                } else {
                    // Reverse transition
                    portalModel.info[idx].hideView = false

                    config.animation.performAnimation({
                        portalModel.info[idx].animateView = false
                    }) {
                        portalModel.info[idx].initialized = false
                        portalModel.info[idx].layerView = nil
                        portalModel.info[idx].sourceAnchor = nil
                        portalModel.info[idx].destinationAnchor = nil
                        portalModel.info[idx].completion(false)
                    }
                }
            }
    }
}

/// Transition modifier for private portals with optional item
struct PortalPrivateItemTransitionModifier<Item: Identifiable>: ViewModifier {
    @Binding var item: Item?
    let config: PortalTransitionConfig
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @State private var lastKey: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: item != nil) { _, hasValue in
                if hasValue {
                    guard let item = item else { return }
                    // Use the same ID format as the source and destination
                    let key: String
                    if let uuid = item.id as? UUID {
                        key = uuid.uuidString
                    } else {
                        key = "\(item.id)"
                    }
                    lastKey = key

                    // Ensure portal info exists
                    if portalModel.info.firstIndex(where: { $0.infoID == key }) == nil {
                        portalModel.info.append(PortalInfo(id: key))
                    }

                    guard let idx = portalModel.info.firstIndex(where: { $0.infoID == key }) else {
                        return
                    }

                    // Initialize portal info
                    portalModel.info[idx].initialized = true
                    portalModel.info[idx].animation = config.animation
                    portalModel.info[idx].corners = config.corners
                    portalModel.info[idx].completion = completion

                    // Set the layer view to use the PortalView of the stored container
                    if let privateInfo = PortalPrivateStorage.shared.getInfo(for: key),
                       let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView> {
                        // Create a portal view that will be animated
                        portalModel.info[idx].layerView = AnyView(
                            PortalView(
                                source: container,
                                hidesSource: hidesSource,
                                matchesAlpha: matchesAlpha,
                                matchesTransform: matchesTransform,
                                matchesPosition: matchesPosition
                            )
                        )
                    }

                    // Forward transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                        config.animation.performAnimation({
                            portalModel.info[idx].animateView = true
                        }) {
                            portalModel.info[idx].hideView = true
                            portalModel.info[idx].completion(true)
                        }
                    }

                } else {
                    // Reverse transition
                    guard let key = lastKey,
                          let idx = portalModel.info.firstIndex(where: { $0.infoID == key })
                    else {
                        return
                    }

                    portalModel.info[idx].hideView = false

                    config.animation.performAnimation({
                        portalModel.info[idx].animateView = false
                    }) {
                        portalModel.info[idx].initialized = false
                        portalModel.info[idx].sourceAnchor = nil
                        portalModel.info[idx].destinationAnchor = nil
                        portalModel.info[idx].completion(false)
                    }

                    lastKey = nil
                }
            }
    }
}

// MARK: - Multi-ID Portal Private Transition Modifier

/// A view modifier that manages coordinated portal transitions for multiple private portal IDs.
struct MultiIDPortalPrivateTransitionModifier: ViewModifier {
    let ids: [String]
    let groupID: String
    let config: PortalTransitionConfig
    @Binding var isActive: Bool
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel

    func body(content: Content) -> some View {
        content
            .onChange(of: isActive) { _, newValue in
                let groupIndices = portalModel.info.enumerated().compactMap { index, info in
                    ids.contains(info.infoID) ? index : nil
                }

                if newValue {
                    // Forward transition
                    for (i, idx) in groupIndices.enumerated() {
                        let portalID = portalModel.info[idx].infoID

                        // Ensure portal info exists
                        if portalModel.info.firstIndex(where: { $0.infoID == portalID }) == nil {
                            portalModel.info.append(PortalInfo(id: portalID))
                        }

                        portalModel.info[idx].initialized = true
                        portalModel.info[idx].animation = config.animation
                        portalModel.info[idx].corners = config.corners
                        portalModel.info[idx].groupID = groupID
                        portalModel.info[idx].isGroupCoordinator = (i == 0)

                        // Set the layer view to use the PortalView of the stored container
                        if let privateInfo = PortalPrivateStorage.shared.getInfo(for: portalID),
                           let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView> {
                            portalModel.info[idx].layerView = AnyView(
                                PortalView(
                                    source: container,
                                    hidesSource: hidesSource,
                                    matchesAlpha: matchesAlpha,
                                    matchesTransform: matchesTransform,
                                    matchesPosition: matchesPosition
                                )
                            )
                        }

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
                    // Reverse transition
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
    }
}

// MARK: - Multi-Item Portal Private Transition Modifier

/// A view modifier that manages coordinated portal transitions for multiple private portal items.
struct MultiItemPortalPrivateTransitionModifier<Item: Identifiable>: ViewModifier {
    @Binding var items: [Item]
    let groupID: String
    let config: PortalTransitionConfig
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @State private var lastKeys: Set<String> = []

    private var keys: Set<String> {
        Set(items.map {
            if let uuid = $0.id as? UUID {
                return uuid.uuidString
            } else {
                return "\($0.id)"
            }
        })
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: !items.isEmpty) { _, hasItems in
                let currentKeys = keys

                if hasItems && !items.isEmpty {
                    // Forward transition
                    lastKeys = currentKeys

                    // Ensure portal info exists for all items
                    for item in items {
                        let key: String
                        if let uuid = item.id as? UUID {
                            key = uuid.uuidString
                        } else {
                            key = "\(item.id)"
                        }

                        if portalModel.info.firstIndex(where: { $0.infoID == key }) == nil {
                            portalModel.info.append(PortalInfo(id: key, groupID: groupID))
                        }
                    }

                    // Configure all portals in the group
                    let groupIndices = portalModel.info.enumerated().compactMap { index, info in
                        currentKeys.contains(info.infoID) ? index : nil
                    }

                    // Set up group coordination
                    for (i, idx) in groupIndices.enumerated() {
                        let portalID = portalModel.info[idx].infoID
                        portalModel.info[idx].initialized = true
                        portalModel.info[idx].animation = config.animation
                        portalModel.info[idx].corners = config.corners
                        portalModel.info[idx].groupID = groupID
                        portalModel.info[idx].isGroupCoordinator = (i == 0)

                        // Set the layer view to use the PortalView of the stored container
                        if let privateInfo = PortalPrivateStorage.shared.getInfo(for: portalID),
                           let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView> {
                            portalModel.info[idx].layerView = AnyView(
                                PortalView(
                                    source: container,
                                    hidesSource: hidesSource,
                                    matchesAlpha: matchesAlpha,
                                    matchesTransform: matchesTransform,
                                    matchesPosition: matchesPosition
                                )
                            )
                        }

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
                    // Reverse transition
                    let cleanupKeys = lastKeys
                    let cleanupIndices = portalModel.info.enumerated().compactMap { index, info in
                        cleanupKeys.contains(info.infoID) ? index : nil
                    }

                    for idx in cleanupIndices {
                        portalModel.info[idx].hideView = false
                    }

                    config.animation.performAnimation({
                        for idx in cleanupIndices {
                            portalModel.info[idx].animateView = false
                        }
                    }) {
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
    }
}


// MARK: - Destination View for Private Portals

/// A destination view that shows a portal of the private source
public struct PortalPrivateDestination: View {
    let id: String
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalDebugOverlays) private var debugOverlaysEnabled

    public init(
        id: String,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {
        self.id = id
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
    }

    /// Creates a destination for a private portal using an Identifiable item's ID
    public init<Item: Identifiable>(
        item: Item,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {
        let key: String
        if let uuid = item.id as? UUID {
            key = uuid.uuidString
        } else {
            key = "\(item.id)"
        }
        self.id = key
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
    }

    public var body: some View {
        Group {
            if let privateInfo = PortalPrivateStorage.shared.getInfo(for: id),
               let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView>,
               let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) {

                let info = portalModel.info[idx]
                // Destination should be visible after animation completes (opposite of hideView)
                let opacity = info.hideView ? 1 : 0

                // Show portal of the source with custom settings
                PortalView(
                    source: container,
                    hidesSource: hidesSource,
                    matchesAlpha: matchesAlpha,
                    matchesTransform: matchesTransform,
                    matchesPosition: matchesPosition
                )
                .opacity(Double(opacity))
                .overlay(
                    Group {
                        #if DEBUG
                        if debugOverlaysEnabled {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                                .overlay(
                                    DebugOverlayIndicator("PortalPrivate Dest", color: .purple)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                        .padding(5)
                                )
                        }
                        #endif
                    }
                )
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    ["\(id)DEST": anchor]
                }
                .onPreferenceChange(AnchorKey.self) { prefs in
                    Task { @MainActor in
                        // Wait for initialization like base Portal does
                        guard portalModel.info[idx].initialized else { return }
                        guard let anchor = prefs["\(id)DEST"] else {
                            return
                        }

                        // Update destination anchor for positioning
                        portalModel.info[idx].destinationAnchor = anchor
                    }
                }
            } else {
                // Placeholder when source not available
                Color.clear
                    .overlay(
                        Group {
                            #if DEBUG
                            if debugOverlaysEnabled {
                                Text("Awaiting PortalPrivate: \(id)")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                            #endif
                        }
                    )
            }
        }
    }
}

// MARK: - Debug Overlay (Reuse from Portal)

#if DEBUG
/// Debug indicator view to visualize portal elements
internal struct DebugOverlayIndicator: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = .pink) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 3)
            .padding(6)
            .background(color.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
            .foregroundStyle(.white)
            .allowsHitTesting(false)
    }
}
#endif


// MARK: - Direct Parameter Modifiers (New API)

/// Portal private transition modifier with direct parameters
struct PortalPrivateTransitionModifierDirect: ViewModifier {
    let id: String
    let animation: PortalAnimation
    @Binding var isActive: Bool
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    func body(content: Content) -> some View {
        let config = PortalTransitionConfig(animation: animation, corners: environmentCorners)

        return content.modifier(
            PortalPrivateTransitionModifier(
                id: id,
                config: config,
                isActive: $isActive,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }
}

/// Portal private item transition modifier with direct parameters
struct PortalPrivateItemTransitionModifierDirect<Item: Identifiable>: ViewModifier {
    @Binding var item: Item?
    let animation: PortalAnimation
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    func body(content: Content) -> some View {
        let config = PortalTransitionConfig(animation: animation, corners: environmentCorners)
        
        return content.modifier(
            PortalPrivateItemTransitionModifier(
                item: $item,
                config: config,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }
}

/// Multi-ID portal private transition modifier with direct parameters  
struct MultiIDPortalPrivateTransitionModifierDirect: ViewModifier {
    let ids: [String]
    let groupID: String
    let animation: PortalAnimation
    @Binding var isActive: Bool
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    func body(content: Content) -> some View {
        let config = PortalTransitionConfig(animation: animation, corners: environmentCorners)
        
        return content.modifier(
            MultiIDPortalPrivateTransitionModifier(
                ids: ids,
                groupID: groupID,
                config: config,
                isActive: $isActive,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }
}

/// Multi-item portal private transition modifier with direct parameters
struct MultiItemPortalPrivateTransitionModifierDirect<Item: Identifiable>: ViewModifier {
    @Binding var items: [Item]
    let groupID: String
    let animation: PortalAnimation
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    func body(content: Content) -> some View {
        let config = PortalTransitionConfig(animation: animation, corners: environmentCorners)
        
        return content.modifier(
            MultiItemPortalPrivateTransitionModifier(
                items: $items,
                groupID: groupID,
                config: config,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }
}
