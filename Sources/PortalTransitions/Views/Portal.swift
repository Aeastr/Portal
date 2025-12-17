//
//  Portal.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI


/// A unified view wrapper that marks its content as either a portal source (leaving view) or destination (arriving view).
///
/// This struct consolidates the functionality of both `PortalSource` and `PortalDestination` into a single,
/// more efficient implementation. Used internally by the `.portalSource(id:)` and `.portalDestination(id:)`
/// view modifiers to identify the source or destination of a portal transition animation.
///
/// - Parameters:
///   - id: A unique identifier for this portal. This should match the `id` used for the corresponding portal transition.
///   - source: A boolean flag indicating whether this is a source (true) or destination (false) portal.
///   - content: The view content to be marked as the portal.
public struct Portal<Content: View>: View {
    private let id: AnyHashable
    private let source: Bool
    private let namespace: Namespace.ID
    private let groupID: String?
    @ViewBuilder private let content: Content
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalTransitionDebugSettings) private var debugSettings

    /// Initializes a new Portal view.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this portal (any `Hashable` type)
    ///   - source: Whether this portal acts as a source (true) or destination (false). Defaults to true.
    ///   - groupID: Optional group identifier for coordinated animations. When provided, this portal will animate as part of a coordinated group.
    ///   - content: A view builder closure that returns the content to be wrapped
    public init<ID: Hashable>(id: ID, source: Bool = true, namespace: Namespace.ID, groupID: String? = nil, @ViewBuilder content: () -> Content) {
        self.id = AnyHashable(id)
        self.source = source
        self.namespace = namespace
        self.groupID = groupID
        self.content = content()
    }

    /// Transforms anchor preferences for this portal.
    ///
    /// - Parameter anchor: The anchor bounds to transform
    /// - Returns: A dictionary mapping portal keys to their anchor bounds
    private func anchorPreferenceTransform(anchor: Anchor<CGRect>) -> [PortalKey: Anchor<CGRect>] {
        if let idx = index, portalModel.info[idx].initialized {
            return [key: anchor]
        }
        return [:]
    }

    public var body: some View {
        let currentKey = key
        let currentIndex = index
        let isSource = source
        let model = portalModel
        let currentGroupID = groupID

        return content
            .opacity(opacity)
            .overlay(
                Group {
                    #if DEBUG
                    let target: PortalTransitionDebugTarget = isSource ? .source : .destination
                    PortalDebugOverlay(isSource ? "Source" : "Destination", color: isSource ? .blue : .orange, showing: debugSettings.style(for: target))
                    #endif
                }
            )
            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: anchorPreferenceTransform)
            // Note: This closure must run synchronously (no Task wrapper) to avoid a race
            // condition where anchors aren't stored before the animation starts.
            .onPreferenceChange(AnchorKey.self) { prefs in
                guard let idx = currentIndex, model.info[idx].initialized else {
                    return
                }
                guard let anchor = prefs[currentKey] else {
                    return
                }


                // Set the group ID if provided
                if let groupID = currentGroupID {
                    model.info[idx].groupID = groupID
                }

                // Keep anchors aligned with live layout so animated layer follows scrolling/dragging
                if isSource {
                    model.info[idx].sourceAnchor = anchor
                    // Cache anchor for use during transitions if view is removed
                    if model.info[idx].initialized {
                        model.info[idx].cachedSourceAnchor = anchor
                    }
                } else {
                    model.info[idx].destinationAnchor = anchor
                    // Cache anchor for use during transitions if view is removed
                    if model.info[idx].initialized {
                        model.info[idx].cachedDestinationAnchor = anchor
                    }
                }
            }
    }

    private var key: PortalKey { PortalKey(id, role: source ? .source : .destination, in: namespace) }

    private var opacity: CGFloat {
        guard let idx = index else { return 1 }

        if source {
            let op = portalModel.info[idx].destinationAnchor == nil ? 1 : 0
            #if DEBUG
            PortalLogs.logger.log(
                "SOURCE opacity",
                level: .debug,
                tags: [PortalLogs.Tags.transition],
                metadata: ["id": String(reflecting: id), "opacity": String(reflecting: op)]
            )
            #endif
            return CGFloat(op)
        } else {
            let op = portalModel.info[idx].initialized ? (portalModel.info[idx].hideView ? 1 : 0) : 1
            #if DEBUG
            PortalLogs.logger.log(
                "DEST opacity",
                level: .debug,
                tags: [PortalLogs.Tags.transition],
                metadata: ["id": String(reflecting: id), "opacity": String(reflecting: op), "hideView": String(reflecting: portalModel.info[idx].hideView)]
            )
            #endif
            return CGFloat(op)
        }
    }

    private var index: Int? {
        portalModel.info.firstIndex { $0.infoID == id }
    }
}

// MARK: - Portal Role Enum

/// Defines the role of a portal in a transition.
public enum PortalRole: Sendable {
    /// The portal acts as a source (leaving view) - the starting point of the transition.
    case source
    /// The portal acts as a destination (arriving view) - the ending point of the transition.
    case destination
}

// MARK: - View Extensions

public extension View {
    /// Marks this view as a portal with the specified role.
    ///
    /// This unified modifier can mark a view as either a source or destination for a portal transition.
    /// It provides a cleaner API compared to separate `.portalSource()` and `.portalDestination()` modifiers.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this portal (any `Hashable` type). This should match the `id` used for the corresponding portal transition.
    ///   - groupID: Optional group identifier for coordinated animations. Portals with the same groupID animate together.
    ///   - role: The role of this portal (`.source` or `.destination`).
    ///   - namespace: The namespace for scoping this portal. Portals only match within the same namespace.
    ///
    /// Example usage:
    /// ```swift
    /// @Namespace var namespace
    ///
    /// // Source view
    /// Image("cover")
    ///     .portal(id: "Book1", as: .source, in: namespace)
    ///
    /// // Destination view
    /// Image("cover")
    ///     .portal(id: "Book1", as: .destination, in: namespace)
    ///
    /// // With group ID for coordinated animations
    /// PhotoView(photo: photo1)
    ///     .portal(id: "photo1", groupID: "photoStack", as: .source, in: namespace)
    /// ```
    func portal<ID: Hashable>(id: ID, groupID: String? = nil, as role: PortalRole, in namespace: Namespace.ID) -> some View {
        let isSource = role == .source
        return Portal(id: id, source: isSource, namespace: namespace, groupID: groupID) { self }
    }

    /// Marks this view as a portal with the specified role using an `Identifiable` item's ID.
    ///
    /// This unified modifier can mark a view as either a source or destination for a portal transition,
    /// using the item's ID directly as the portal identifier.
    ///
    /// - Parameters:
    ///   - item: An `Identifiable` item whose ID will be used as the portal identifier.
    ///   - groupID: Optional group identifier for coordinated animations. Portals with the same groupID animate together.
    ///   - role: The role of this portal (`.source` or `.destination`).
    ///   - namespace: The namespace for scoping this portal. Portals only match within the same namespace.
    ///
    /// Example usage:
    /// ```swift
    /// @Namespace var namespace
    ///
    /// struct Book: Identifiable {
    ///     let id = UUID()
    ///     let title: String
    /// }
    ///
    /// let book = Book(title: "SwiftUI Guide")
    ///
    /// // Source view
    /// Image("thumbnail")
    ///     .portal(item: book, as: .source, in: namespace)
    ///
    /// // Destination view
    /// Image("fullsize")
    ///     .portal(item: book, as: .destination, in: namespace)
    ///
    /// // With group ID for coordinated animations
    /// ForEach(photos) { photo in
    ///     PhotoView(photo: photo)
    ///         .portal(item: photo, groupID: "photoStack", as: .source, in: namespace)
    /// }
    /// ```
    func portal<Item: Identifiable>(item: Item, groupID: String? = nil, as role: PortalRole, in namespace: Namespace.ID) -> some View {
        let isSource = role == .source
        return Portal(id: item.id, source: isSource, namespace: namespace, groupID: groupID) { self }
    }
}
