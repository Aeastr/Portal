//
//  AnimatedItemPortalLayer.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A protocol for creating custom animated portal layers that respond to optional `Identifiable` items.
///
/// Conform to this protocol to create reusable animated components that respond to portal transitions
/// driven by optional item bindings. The protocol automatically handles CrossModel observation and
/// provides both the `isActive` state and the current `item` when available.
///
/// This is the item-based counterpart to `AnimatedPortalLayer`, designed for use with
/// `.portal(item:, .source)` and `.portalTransition(item:)` patterns.
///
/// Example:
/// ```swift
/// struct MyItemAnimation<Item: Identifiable, Content: View>: AnimatedItemPortalLayer {
///     @Binding var item: Item?
///     @ViewBuilder let content: (Item) -> Content
///
///     func animatedContent(item: Item?, isActive: Bool) -> some View {
///         if let item {
///             content(item)
///                 .scaleEffect(isActive ? 1.25 : 1.0)
///                 .opacity(isActive ? 1.0 : 0.8)
///         }
///     }
/// }
/// ```
public protocol AnimatedItemPortalLayer: View {
    associatedtype Item: Identifiable
    associatedtype AnimatedContent: View

    /// Binding to the optional item that controls the portal layer.
    ///
    /// The portal ID is derived from the item's `id` property using string interpolation.
    var item: Item? { get }

    /// The namespace for scoping portal lookup.
    ///
    /// This ensures the layer only responds to portal transitions in the matching namespace,
    /// preventing interference when the same item ID exists in multiple namespaces.
    var namespace: Namespace.ID { get }

    /// Implement this method to define your custom animation logic.
    ///
    /// - Parameters:
    ///   - item: The current item (may be `nil` during reverse transitions or when inactive).
    ///   - isActive: Whether the portal transition is currently active.
    /// - Returns: The animated view.
    @ViewBuilder func animatedContent(item: Item?, isActive: Bool) -> AnimatedContent
}

public extension AnimatedItemPortalLayer {
    @ViewBuilder
    var body: some View {
        AnimatedItemPortalLayerHost(layer: self)
    }
}

private struct AnimatedItemPortalLayerHost<Layer: AnimatedItemPortalLayer>: View {
    @Environment(CrossModel.self) private var portalModel
    let layer: Layer

    /// Tracks the last known item to maintain during reverse transitions.
    @State private var lastItem: Layer.Item?

    /// Tracks the last key for detecting when reverse transition completes.
    @State private var lastKey: AnyHashable?

    var body: some View {
        let currentItem = layer.item
        let namespace = layer.namespace
        let key: AnyHashable? = currentItem.map { AnyHashable($0.id) }

        // Check active state using lastKey if current key is nil (reverse transition)
        let lookupKey = key ?? lastKey
        let idx = lookupKey.flatMap { k in portalModel.info.firstIndex { $0.infoID == k && $0.namespace == namespace } }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false

        // Use the current item if available, otherwise fall back to the last known item
        // This ensures the layer content remains visible during reverse transitions
        let displayItem = currentItem ?? lastItem

        layer.animatedContent(item: displayItem, isActive: isActive)
            .onChange(of: currentItem?.id) { _, newID in
                if newID != nil {
                    lastItem = currentItem
                    lastKey = key
                }
            }
            .onChange(of: isActive) { _, newActive in
                // Clear cached item after reverse transition completes to free memory
                if !newActive && currentItem == nil {
                    Task { @MainActor in
                        // Small delay to ensure animation has fully completed
                        try? await Task.sleep(for: .milliseconds(50))
                        lastItem = nil
                        lastKey = nil
                    }
                }
            }
    }
}

// MARK: - Convenience Wrapper

/// A concrete implementation of `AnimatedItemPortalLayer` for simple use cases.
///
/// Use this when you need a quick item-based animated layer without creating a custom type.
///
/// Example:
/// ```swift
/// AnimatedItemLayer(item: $selectedPhoto, in: namespace) { photo, isActive in
///     AsyncImage(url: photo?.imageURL)
///         .scaleEffect(isActive ? 1.1 : 1.0)
///         .animation(.spring, value: isActive)
/// }
/// ```
public struct AnimatedItemLayer<Item: Identifiable, Content: View>: AnimatedItemPortalLayer {
    public let item: Item?
    public let namespace: Namespace.ID
    private let contentBuilder: (Item?, Bool) -> Content

    /// Creates an animated item layer with the specified item, namespace, and content builder.
    ///
    /// - Parameters:
    ///   - item: Binding to the optional item that controls the layer.
    ///   - namespace: The namespace for scoping portal lookup.
    ///   - content: A closure that receives the item and active state, returning the animated content.
    public init(
        item: Binding<Item?>,
        in namespace: Namespace.ID,
        @ViewBuilder content: @escaping (Item?, Bool) -> Content
    ) {
        self.item = item.wrappedValue
        self.namespace = namespace
        self.contentBuilder = content
    }

    /// Creates an animated item layer with a direct item value, namespace, and content builder.
    ///
    /// - Parameters:
    ///   - item: The optional item that controls the layer.
    ///   - namespace: The namespace for scoping portal lookup.
    ///   - content: A closure that receives the item and active state, returning the animated content.
    public init(
        item: Item?,
        in namespace: Namespace.ID,
        @ViewBuilder content: @escaping (Item?, Bool) -> Content
    ) {
        self.item = item
        self.namespace = namespace
        self.contentBuilder = content
    }

    public func animatedContent(item: Item?, isActive: Bool) -> some View {
        contentBuilder(item, isActive)
    }
}

// MARK: - Group/Array Version

/// A protocol for creating custom animated portal layers that respond to arrays of `Identifiable` items.
///
/// Conform to this protocol to create reusable animated components that respond to coordinated
/// multi-item portal transitions. The protocol automatically handles CrossModel observation
/// and provides active states for each item in the group.
///
/// This is designed for use with `.portal(item:, .source, groupID:)` and
/// `.portalTransition(items:, groupID:)` patterns.
///
/// Example:
/// ```swift
/// struct MyGroupAnimation<Item: Identifiable, Content: View>: AnimatedGroupPortalLayer {
///     let items: [Item]
///     let groupID: String
///     @ViewBuilder let content: (Item, Bool) -> Content
///
///     func animatedContent(items: [Item], activeStates: [Item.ID: Bool]) -> some View {
///         ZStack {
///             ForEach(items) { item in
///                 let isActive = activeStates[item.id] ?? false
///                 content(item, isActive)
///                     .scaleEffect(isActive ? 1.1 : 1.0)
///             }
///         }
///     }
/// }
/// ```
public protocol AnimatedGroupPortalLayer: View {
    associatedtype Item: Identifiable
    associatedtype AnimatedContent: View

    /// The array of items that control the portal layers.
    var items: [Item] { get }

    /// The group identifier for coordinated animations.
    var groupID: String { get }

    /// The namespace for scoping portal lookup.
    var namespace: Namespace.ID { get }

    /// Implement this method to define your custom animation logic.
    ///
    /// - Parameters:
    ///   - items: The current array of items.
    ///   - activeStates: A dictionary mapping item IDs to their active state.
    /// - Returns: The animated view.
    @ViewBuilder func animatedContent(items: [Item], activeStates: [Item.ID: Bool]) -> AnimatedContent
}

public extension AnimatedGroupPortalLayer {
    @ViewBuilder
    var body: some View {
        AnimatedGroupPortalLayerHost(layer: self)
    }
}

private struct AnimatedGroupPortalLayerHost<Layer: AnimatedGroupPortalLayer>: View {
    @Environment(CrossModel.self) private var portalModel
    let layer: Layer

    /// Tracks the last known items to maintain during reverse transitions.
    @State private var lastItems: [Layer.Item] = []

    /// Tracks whether any item was active, for cleanup detection.
    @State private var wasActive = false

    /// Builds active states dictionary for a set of items using O(n+m) lookup.
    private func buildActiveStates(for items: [Layer.Item]) -> [Layer.Item.ID: Bool] {
        let namespace = layer.namespace

        // Build lookup dictionary from portal info first: O(m)
        // Only include info entries that match the namespace
        var infoLookup: [AnyHashable: Bool] = [:]
        for info in portalModel.info where info.namespace == namespace {
            infoLookup[info.infoID] = info.animateView
        }

        // Map items to active states: O(n)
        var states: [Layer.Item.ID: Bool] = [:]
        for item in items {
            let key = AnyHashable(item.id)
            states[item.id] = infoLookup[key] ?? false
        }
        return states
    }

    var body: some View {
        let currentItems = layer.items
        let displayItems = currentItems.isEmpty ? lastItems : currentItems

        // Build active states for display items (handles both current and reverse transition cases)
        let activeStates = buildActiveStates(for: displayItems)
        let anyActive = activeStates.values.contains(true)

        layer.animatedContent(items: displayItems, activeStates: activeStates)
            .onChange(of: currentItems.map { $0.id }) { _, newIDs in
                if !newIDs.isEmpty {
                    lastItems = currentItems
                }
            }
            .onChange(of: anyActive) { _, newActive in
                if newActive {
                    wasActive = true
                } else if wasActive && currentItems.isEmpty {
                    // Clear cached items after reverse transition completes to free memory
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(50))
                        lastItems = []
                        wasActive = false
                    }
                }
            }
    }
}

/// A concrete implementation of `AnimatedGroupPortalLayer` for simple use cases.
///
/// Use this when you need a quick group-based animated layer without creating a custom type.
///
/// Example:
/// ```swift
/// AnimatedGroupLayer(items: selectedPhotos, groupID: "photoStack", in: namespace) { items, activeStates in
///     ZStack {
///         ForEach(items) { photo in
///             let isActive = activeStates[photo.id] ?? false
///             PhotoView(photo: photo)
///                 .scaleEffect(isActive ? 1.1 : 1.0)
///         }
///     }
/// }
/// ```
public struct AnimatedGroupLayer<Item: Identifiable, Content: View>: AnimatedGroupPortalLayer {
    public let items: [Item]
    public let groupID: String
    public let namespace: Namespace.ID
    private let contentBuilder: ([Item], [Item.ID: Bool]) -> Content

    /// Creates an animated group layer with the specified items, group ID, namespace, and content builder.
    ///
    /// - Parameters:
    ///   - items: Binding to the array of items that control the layers.
    ///   - groupID: The group identifier for coordinated animations.
    ///   - namespace: The namespace for scoping portal lookup.
    ///   - content: A closure that receives the items and their active states, returning the animated content.
    public init(
        items: Binding<[Item]>,
        groupID: String,
        in namespace: Namespace.ID,
        @ViewBuilder content: @escaping ([Item], [Item.ID: Bool]) -> Content
    ) {
        self.items = items.wrappedValue
        self.groupID = groupID
        self.namespace = namespace
        self.contentBuilder = content
    }

    /// Creates an animated group layer with direct item values, group ID, namespace, and content builder.
    ///
    /// - Parameters:
    ///   - items: The array of items that control the layers.
    ///   - groupID: The group identifier for coordinated animations.
    ///   - namespace: The namespace for scoping portal lookup.
    ///   - content: A closure that receives the items and their active states, returning the animated content.
    public init(
        items: [Item],
        groupID: String,
        in namespace: Namespace.ID,
        @ViewBuilder content: @escaping ([Item], [Item.ID: Bool]) -> Content
    ) {
        self.items = items
        self.groupID = groupID
        self.namespace = namespace
        self.contentBuilder = content
    }

    public func animatedContent(items: [Item], activeStates: [Item.ID: Bool]) -> some View {
        contentBuilder(items, activeStates)
    }
}
