//
//  PortalPrivate.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import PortalTransitions
import UIPortalBridge


// MARK: - Extended Portal Info

/// Extended portal info that includes the source container for view mirroring
@MainActor
public class PortalPrivateInfo {
    /// The source view container holding the UIHostingController
    public var sourceContainer: AnyObject?

    /// Whether the portal is using private implementation
    public var isPrivatePortal: Bool = false
}

// MARK: - Storage for Private Portal Info

@MainActor
private class PortalPrivateStorage {
    static let shared = PortalPrivateStorage()

    // Use dictionary with AnyHashable keys for type-safe storage
    private var storage: [AnyHashable: PortalPrivateInfo] = [:]

    // Cache for frequently accessed items to avoid repeated lookups
    // Uses a dictionary for O(1) lookups with a separate array to track insertion order for LRU eviction
    private var cache: [AnyHashable: PortalPrivateInfo] = [:]
    private var cacheOrder: [AnyHashable] = [] // Tracks insertion order for LRU eviction
    private let cacheLimit = PortalConstants.portalCacheLimit

    func setInfo(_ info: PortalPrivateInfo?, for key: AnyHashable) {
        if let info = info {
            storage[key] = info
            updateCache(key: key, info: info)
        } else {
            storage.removeValue(forKey: key)
            cache.removeValue(forKey: key)
            cacheOrder.removeAll { $0 == key }
        }
    }

    func getInfo(for key: AnyHashable) -> PortalPrivateInfo? {
        // Check cache first
        if let cached = cache[key] {
            return cached
        }

        // Fall back to storage
        if let info = storage[key] {
            updateCache(key: key, info: info)
            return info
        }

        return nil
    }

    func removeInfo(for key: AnyHashable) {
        storage.removeValue(forKey: key)
        cache.removeValue(forKey: key)
        cacheOrder.removeAll { $0 == key }
    }

    private func updateCache(key: AnyHashable, info: PortalPrivateInfo) {
        // Move to end if already exists (LRU behavior)
        cacheOrder.removeAll { $0 == key }
        cacheOrder.append(key)
        cache[key] = info

        // Limit cache size by removing oldest entries (LRU eviction)
        while cache.count > cacheLimit, let oldestKey = cacheOrder.first {
            cacheOrder.removeFirst()
            cache.removeValue(forKey: oldestKey)
        }
    }
}

// MARK: - PortalPrivate View Wrapper

/// A view that manages a single SwiftUI view instance that can be shown in multiple places
public struct PortalPrivate<Content: View>: View {
    private let id: AnyHashable
    private let namespace: Namespace.ID
    private let groupID: String?
    @ViewBuilder private let content: () -> Content
    @State private var sourceContainer: SourceViewContainer<AnyView>?
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalTransitionDebugSettings) private var debugSettings

    public init<ID: Hashable>(id: ID, in namespace: Namespace.ID, groupID: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.id = AnyHashable(id)
        self.namespace = namespace
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
                .opacity(portalModel.info.first { $0.infoID == id }?.destinationAnchor == nil ? 1 : 0)
                .overlay(
                    Group {
                        #if DEBUG
                        let sourceStyle = debugSettings.style(for: .source)
                        if !sourceStyle.isEmpty {
                            PortalDebugOverlay("PortalPrivate", color: .purple, showing: sourceStyle)
                        }
                        #endif
                    }
                )
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    [PortalKey(id, role: .source, in: namespace): anchor]
                }
                .onPreferenceChange(AnchorKey.self) { prefs in
                    Task { @MainActor in
                        guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else {
                            return
                        }

                        // Don't require initialized - we need to set anchor even before transition
                        guard let anchor = prefs[PortalKey(id, role: .source, in: namespace)] else {
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
    /// @Namespace var namespace
    ///
    /// MyComplexView()
    ///     .portalPrivate(id: "myView", in: namespace)
    /// ```
    func portalPrivate<ID: Hashable, Content: View>(
        id: ID,
        in namespace: Namespace.ID,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            PortalPrivate(id: id, in: namespace, content: content)
        )
    }

    /// Simplified portal private for when the view itself should be mirrored
    func portalPrivate<ID: Hashable>(id: ID, groupID: String? = nil, in namespace: Namespace.ID) -> some View {
        PortalPrivate(id: id, in: namespace, groupID: groupID) {
            self
        }
    }

    /// Marks this view as a private portal using an `Identifiable` item's ID
    ///
    /// This creates a single view instance that can be displayed in multiple places
    /// using _UIPortalView, using the item's ID directly.
    ///
    /// Example:
    /// ```swift
    /// @Namespace var namespace
    ///
    /// MyComplexView()
    ///     .portalPrivate(item: book, in: namespace)
    /// ```
    func portalPrivate<Item: Identifiable>(item: Item, groupID: String? = nil, in namespace: Namespace.ID) -> some View {
        PortalPrivate(id: item.id, in: namespace, groupID: groupID) {
            self
        }
    }

    /// Triggers a portal transition for a private portal using the mirrored view
    ///
    /// This modifier triggers the animation for PortalPrivate views.
    /// Unlike regular `.portalTransition`, you don't provide a layer view
    /// since it uses the _UIPortalView mirror of the source.
    ///
    /// Example:
    /// ```swift
    /// @Namespace var namespace
    ///
    /// .portalPrivateTransition(
    ///     id: "myView",
    ///     in: namespace,
    ///     isActive: $showDetail,
    ///     animation: .smooth(duration: 0.5),
    ///     hidesSource: true
    /// )
    /// ```
    func portalPrivateTransition<ID: Hashable>(
        id: ID,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateTransitionModifier(
                id: id,
                in: namespace,
                isActive: isActive,
                animation: animation,
                completionCriteria: completionCriteria,
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
        in namespace: Namespace.ID,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateItemTransitionModifier(
                item: item,
                in: namespace,
                animation: animation,
                completionCriteria: completionCriteria,
                hidesSource: hidesSource,
                matchesAlpha: matchesAlpha,
                matchesTransform: matchesTransform,
                matchesPosition: matchesPosition,
                completion: completion
            )
        )
    }

    func portalPrivateTransition<ID: Hashable>(
        ids: [ID],
        groupID: String,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
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
                in: namespace,
                isActive: isActive,
                animation: animation,
                completionCriteria: completionCriteria,
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
        in namespace: Namespace.ID,
        animation: Animation = .smooth(duration: 0.4),
        completionCriteria: AnimationCompletionCriteria = .removed,
        staggerDelay: TimeInterval = 0.0,
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
                in: namespace,
                animation: animation,
                completionCriteria: completionCriteria,
                staggerDelay: staggerDelay,
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
    let id: AnyHashable
    let namespace: Namespace.ID
    @Binding var isActive: Bool
    let animation: Animation
    let completionCriteria: AnimationCompletionCriteria
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel

    init<ID: Hashable>(
        id: ID,
        in namespace: Namespace.ID,
        isActive: Binding<Bool>,
        animation: Animation,
        completionCriteria: AnimationCompletionCriteria,
        hidesSource: Bool,
        matchesAlpha: Bool,
        matchesTransform: Bool,
        matchesPosition: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        self.id = AnyHashable(id)
        self.namespace = namespace
        self._isActive = isActive
        self.animation = animation
        self.completionCriteria = completionCriteria
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
        self.completion = completion
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isActive) { _, newValue in
                guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else { return }

                // Initialize portal info
                portalModel.info[idx].initialized = true
                portalModel.info[idx].animation = animation
                portalModel.info[idx].completionCriteria = completionCriteria
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
                        withAnimation(animation, completionCriteria: completionCriteria) {
                            portalModel.info[idx].animateView = true
                        } completion: {
                            Task { @MainActor in
                                portalModel.info[idx].hideView = true
                                portalModel.info[idx].completion(true)
                            }
                        }
                    }
                } else {
                    // Reverse transition
                    portalModel.info[idx].hideView = false

                    withAnimation(animation, completionCriteria: completionCriteria) {
                        portalModel.info[idx].animateView = false
                    } completion: {
                        Task { @MainActor in
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
}

/// Transition modifier for private portals with optional item
struct PortalPrivateItemTransitionModifier<Item: Identifiable>: ViewModifier {
    @Binding var item: Item?
    let namespace: Namespace.ID
    let animation: Animation
    let completionCriteria: AnimationCompletionCriteria
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @State private var lastKey: AnyHashable?

    init(
        item: Binding<Item?>,
        in namespace: Namespace.ID,
        animation: Animation,
        completionCriteria: AnimationCompletionCriteria,
        hidesSource: Bool,
        matchesAlpha: Bool,
        matchesTransform: Bool,
        matchesPosition: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        self._item = item
        self.namespace = namespace
        self.animation = animation
        self.completionCriteria = completionCriteria
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
        self.completion = completion
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: item != nil) { _, hasValue in
                if hasValue {
                    guard let item = item else { return }
                    let key = AnyHashable(item.id)
                    lastKey = key

                    // Ensure portal info exists
                    if !portalModel.info.contains(where: { $0.infoID == key }) {
                        portalModel.info.append(PortalInfo(id: item.id))
                    }

                    guard let idx = portalModel.info.firstIndex(where: { $0.infoID == key }) else {
                        return
                    }

                    // Initialize portal info
                    portalModel.info[idx].initialized = true
                    portalModel.info[idx].animation = animation
                    portalModel.info[idx].completionCriteria = completionCriteria
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
                        withAnimation(animation, completionCriteria: completionCriteria) {
                            portalModel.info[idx].animateView = true
                        } completion: {
                            Task { @MainActor in
                                portalModel.info[idx].hideView = true
                                portalModel.info[idx].completion(true)
                            }
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

                    withAnimation(animation, completionCriteria: completionCriteria) {
                        portalModel.info[idx].animateView = false
                    } completion: {
                        Task { @MainActor in
                            portalModel.info[idx].initialized = false
                            portalModel.info[idx].sourceAnchor = nil
                            portalModel.info[idx].destinationAnchor = nil
                            portalModel.info[idx].completion(false)
                        }
                    }

                    lastKey = nil
                }
            }
    }
}

// MARK: - Multi-ID Portal Private Transition Modifier

/// A view modifier that manages coordinated portal transitions for multiple private portal IDs.
struct MultiIDPortalPrivateTransitionModifier: ViewModifier {
    let ids: [AnyHashable]
    let groupID: String
    @Binding var isActive: Bool
    let animation: Animation
    let completionCriteria: AnimationCompletionCriteria
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel

    init<ID: Hashable>(
        ids: [ID],
        groupID: String,
        isActive: Binding<Bool>,
        animation: Animation,
        completionCriteria: AnimationCompletionCriteria,
        hidesSource: Bool,
        matchesAlpha: Bool,
        matchesTransform: Bool,
        matchesPosition: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        self.ids = ids.map { AnyHashable($0) }
        self.groupID = groupID
        self._isActive = isActive
        self.animation = animation
        self.completionCriteria = completionCriteria
        self.hidesSource = hidesSource
        self.matchesAlpha = matchesAlpha
        self.matchesTransform = matchesTransform
        self.matchesPosition = matchesPosition
        self.completion = completion
    }

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
                        if !portalModel.info.contains(where: { $0.infoID == portalID }) {
                            portalModel.info.append(PortalInfo(id: portalID))
                        }

                        portalModel.info[idx].initialized = true
                        portalModel.info[idx].animation = animation
                        portalModel.info[idx].completionCriteria = completionCriteria
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay) {
                        withAnimation(animation, completionCriteria: completionCriteria) {
                            for idx in groupIndices {
                                portalModel.info[idx].animateView = true
                            }
                        } completion: {
                            Task { @MainActor in
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
                    // Reverse transition
                    for idx in groupIndices {
                        portalModel.info[idx].hideView = false
                    }

                    withAnimation(animation, completionCriteria: completionCriteria) {
                        for idx in groupIndices {
                            portalModel.info[idx].animateView = false
                        }
                    } completion: {
                        Task { @MainActor in
                            for idx in groupIndices {
                                portalModel.info[idx].initialized = false
                                portalModel.info[idx].layerView = nil
                                portalModel.info[idx].sourceAnchor = nil
                                portalModel.info[idx].destinationAnchor = nil
                                portalModel.info[idx].groupID = nil
                                let wasCoordinator = portalModel.info[idx].isGroupCoordinator
                                portalModel.info[idx].isGroupCoordinator = false
                                if wasCoordinator {
                                    portalModel.info[idx].completion(false)
                                }
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
    let animation: Animation
    let completionCriteria: AnimationCompletionCriteria
    let staggerDelay: TimeInterval
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @State private var lastKeys: Set<AnyHashable> = []

    private var keys: Set<AnyHashable> {
        Set(items.map { AnyHashable($0.id) })
    }

    /// Ensures portal info exists for all items.
    private func ensurePortalInfo(for items: [Item]) {
        for item in items {
            let key = AnyHashable(item.id)
            if !portalModel.info.contains(where: { $0.infoID == key }) {
                portalModel.info.append(PortalInfo(id: item.id, groupID: groupID))
            }
        }
    }

    /// Configures portal info for all items in the group.
    private func configureGroupPortals(at indices: [Int]) {
        for (i, idx) in indices.enumerated() {
            let portalID = portalModel.info[idx].infoID
            portalModel.info[idx].initialized = true
            portalModel.info[idx].animation = animation
            portalModel.info[idx].completionCriteria = completionCriteria
            portalModel.info[idx].groupID = groupID
            portalModel.info[idx].isGroupCoordinator = (i == 0)

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

            portalModel.info[idx].completion = (i == 0) ? completion : { _ in }
        }
    }

    /// Starts staggered forward animations for the given indices.
    private func startStaggeredAnimation(at indices: [Int]) {
        for (i, idx) in indices.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + PortalConstants.animationDelay + (Double(i) * staggerDelay)) {
                withAnimation(animation, completionCriteria: completionCriteria) {
                    portalModel.info[idx].animateView = true
                } completion: {
                    Task { @MainActor in
                        portalModel.info[idx].hideView = true
                        if portalModel.info[idx].isGroupCoordinator {
                            portalModel.info[idx].completion(true)
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
    private func performReverseTransition(for keys: Set<AnyHashable>) {
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
                    let wasCoordinator = portalModel.info[idx].isGroupCoordinator
                    portalModel.info[idx].isGroupCoordinator = false
                    if wasCoordinator {
                        portalModel.info[idx].completion(false)
                    }
                }
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: !items.isEmpty) { _, hasItems in
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
    }
}


// MARK: - Destination View for Private Portals

/// A destination view that shows a portal of the private source
public struct PortalPrivateDestination: View {
    let id: AnyHashable
    let hidesSource: Bool
    let matchesAlpha: Bool
    let matchesTransform: Bool
    let matchesPosition: Bool
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalTransitionDebugSettings) private var debugSettings

    public init<ID: Hashable>(
        id: ID,
        hidesSource: Bool = false,
        matchesAlpha: Bool = true,
        matchesTransform: Bool = true,
        matchesPosition: Bool = false
    ) {
        self.id = AnyHashable(id)
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
        self.id = AnyHashable(item.id)
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
                        let destStyle = debugSettings.style(for: .destination)
                        if !destStyle.isEmpty {
                            PortalDebugOverlay("PortalPrivate Dest", color: .purple, showing: destStyle)
                        }
                        #endif
                    }
                )
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    [PortalKey(id, role: .destination): anchor]
                }
                .onPreferenceChange(AnchorKey.self) { prefs in
                    Task { @MainActor in
                        // Wait for initialization like base Portal does
                        guard portalModel.info[idx].initialized else { return }
                        guard let anchor = prefs[PortalKey(id, role: .destination)] else {
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
                            let destStyle = debugSettings.style(for: .destination)
                            if !destStyle.isEmpty {
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

/// Complete debug overlay component with border, label, and background
internal struct PortalDebugOverlay: View {
    let text: String
    let color: Color
    let style: PortalTransitionDebugStyle

    init(_ text: String, color: Color, showing style: PortalTransitionDebugStyle) {
        self.text = text
        self.color = color
        self.style = style
    }

    var body: some View {
        Group {
            if style.contains(.background) {
                color.opacity(0.1)
            }

            if style.contains(.border) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 2)
            }

            if style.contains(.label) {
                DebugOverlayIndicator(text, color: color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(5)
            }
        }
    }
}
#endif
