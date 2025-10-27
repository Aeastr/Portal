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
///   - id: A unique string identifier for this portal. This should match the `id` used for the corresponding portal transition.
///   - source: A boolean flag indicating whether this is a source (true) or destination (false) portal.
///   - content: The view content to be marked as the portal.
public struct Portal<Content: View>: View {
    private let id: String
    private let source: Bool
    private let groupID: String?
    @ViewBuilder private let content: Content
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalDebugOverlays) private var debugOverlaysEnabled

    /// Initializes a new Portal view.
    ///
    /// - Parameters:
    ///   - id: A unique string identifier for this portal
    ///   - source: Whether this portal acts as a source (true) or destination (false). Defaults to true.
    ///   - groupID: Optional group identifier for coordinated animations. When provided, this portal will animate as part of a coordinated group.
    ///   - content: A view builder closure that returns the content to be wrapped
    public init(id: String, source: Bool = true, groupID: String? = nil, @ViewBuilder content: () -> Content) {
        self.id = id
        self.source = source
        self.groupID = groupID
        self.content = content()
    }

    /// Transforms anchor preferences for this portal.
    ///
    /// - Parameter anchor: The anchor bounds to transform
    /// - Returns: A dictionary mapping portal IDs to their anchor bounds
    private func anchorPreferenceTransform(anchor: Anchor<CGRect>) -> [String: Anchor<CGRect>] {
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
                    PortalDebugOverlay(isSource ? "Source" : "Destination", color: isSource ? .blue : .orange, showing: debugOverlaysEnabled)
                    #endif
                }
            )
            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: anchorPreferenceTransform)
            .onPreferenceChange(AnchorKey.self) { prefs in
                Task { @MainActor in
                    guard let idx = currentIndex, model.info[idx].initialized else { return }
                    guard let anchor = prefs[currentKey] else { return }

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
    }

    private var key: String { source ? id : "\(id)DEST" }

    private var opacity: CGFloat {
        guard let idx = index else { return 1 }

        if source {
            let op = portalModel.info[idx].destinationAnchor == nil ? 1 : 0
            #if DEBUG
            PortalLogs.logger.log(
                "SOURCE opacity",
                level: .debug,
                tags: [PortalLogs.Tags.transition],
                metadata: ["id": id, "opacity": "\(op)"]
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
                metadata: ["id": id, "opacity": "\(op)", "hideView": "\(portalModel.info[idx].hideView)"]
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
public enum PortalRole {
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
    ///   - id: A unique string identifier for this portal. This should match the `id` used for the corresponding portal transition.
    ///   - role: The role of this portal (`.source` or `.destination`).
    ///
    /// Example usage:
    /// ```swift
    /// // Source view
    /// Image("cover")
    ///     .portal(id: "Book1", .source)
    ///
    /// // Destination view
    /// Image("cover")
    ///     .portal(id: "Book1", .destination)
    /// ```
    func portal(id: String, _ role: PortalRole) -> some View {
        let isSource = role == .source
        return Portal(id: id, source: isSource) { self }
    }

    /// Marks this view as a portal with the specified role and group.
    ///
    /// This modifier extends the basic portal functionality to support coordinated group animations.
    /// Multiple portals with the same `groupID` will animate together as a coordinated group.
    ///
    /// - Parameters:
    ///   - id: A unique string identifier for this portal. This should match the `id` used for the corresponding portal transition.
    ///   - role: The role of this portal (`.source` or `.destination`).
    ///   - groupID: A group identifier for coordinated animations. Portals with the same groupID animate together.
    ///
    /// Example usage:
    /// ```swift
    /// // Multiple views that should animate together
    /// PhotoView(photo: photo1)
    ///     .portal(id: "photo1", .source, groupID: "photoStack")
    /// PhotoView(photo: photo2)
    ///     .portal(id: "photo2", .source, groupID: "photoStack")
    /// ```
    func portal(id: String, _ role: PortalRole, groupID: String) -> some View {
        let isSource = role == .source
        return Portal(id: id, source: isSource, groupID: groupID) { self }
    }

    /// Marks this view as a portal with the specified role using an `Identifiable` item's ID.
    ///
    /// This unified modifier can mark a view as either a source or destination for a portal transition,
    /// automatically extracting the string representation of an `Identifiable` item's ID.
    ///
    /// - Parameters:
    ///   - item: An `Identifiable` item whose ID will be used as the portal identifier.
    ///   - role: The role of this portal (`.source` or `.destination`).
    ///
    /// Example usage:
    /// ```swift
    /// struct Book: Identifiable {
    ///     let id = UUID()
    ///     let title: String
    /// }
    ///
    /// let book = Book(title: "SwiftUI Guide")
    ///
    /// // Source view
    /// Image("thumbnail")
    ///     .portal(item: book, .source)
    ///
    /// // Destination view
    /// Image("fullsize")
    ///     .portal(item: book, .destination)
    /// ```
    func portal<Item: Identifiable>(item: Item, _ role: PortalRole) -> some View {
        let key = "\(item.id)"
        let isSource = role == .source
        return Portal(id: key, source: isSource) { self }
    }

    /// Marks this view as a portal with the specified role using an `Identifiable` item's ID and group.
    ///
    /// This modifier extends the basic portal functionality to support coordinated group animations.
    /// Multiple portals with the same `groupID` will animate together as a coordinated group.
    ///
    /// - Parameters:
    ///   - item: An `Identifiable` item whose ID will be used as the portal identifier.
    ///   - role: The role of this portal (`.source` or `.destination`).
    ///   - groupID: A group identifier for coordinated animations. Portals with the same groupID animate together.
    ///
    /// Example usage:
    /// ```swift
    /// // Multiple photos that should animate together
    /// ForEach(photos) { photo in
    ///     PhotoView(photo: photo)
    ///         .portal(item: photo, .source, groupID: "photoStack")
    /// }
    ///
    /// // Destination views with the same groupID
    /// ForEach(photos) { photo in
    ///     PhotoView(photo: photo)
    ///         .portal(item: photo, .destination, groupID: "photoStack")
    /// }
    /// ```
    func portal<Item: Identifiable>(item: Item, _ role: PortalRole, groupID: String) -> some View {
        let key = "\(item.id)"
        let isSource = role == .source
        return Portal(id: key, source: isSource, groupID: groupID) { self }
    }}
