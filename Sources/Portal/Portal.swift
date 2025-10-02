import SwiftUI

// MARK: - iOS 17+ Implementation

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
@available(iOS 17.0, *)
public struct Portal<Content: View>: View {
    private let id: String
    private let source: Bool
    @ViewBuilder private let content: Content
    @Environment(CrossModel.self) private var portalModel
    
    /// Initializes a new Portal view.
    ///
    /// - Parameters:
    ///   - id: A unique string identifier for this portal
    ///   - source: Whether this portal acts as a source (true) or destination (false). Defaults to true.
    ///   - content: A view builder closure that returns the content to be wrapped
    public init(id: String, source: Bool = true, @ViewBuilder content: () -> Content) {
        self.id = id
        self.source = source
        self.content = content()
    }
    
    /// Transforms anchor preferences for this portal.
    ///
    /// - Parameter anchor: The anchor bounds to transform
    /// - Returns: A dictionary mapping portal IDs to their anchor bounds
    private func anchorPreferenceTransform(anchor: Anchor<CGRect>) -> [String: Anchor<CGRect>] {
        if let idx = index, portalModel.info[idx].initalized {
            return [key: anchor]
        }
        return [:]
    }
    
    public var body: some View {
        let currentKey = key
        let currentIndex = index
        let isSource = source
        let model = portalModel
        
        return content
            .opacity(opacity)
            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: anchorPreferenceTransform)
            .onPreferenceChange(AnchorKey.self) { prefs in
                Task { @MainActor in
                    if let idx = currentIndex, model.info[idx].initalized {
                        if !isSource {
                            model.info[idx].destinationAnchor = prefs[currentKey]
                        } else if model.info[idx].sourceAnchor == nil {
                            model.info[idx].sourceAnchor = prefs[currentKey]
                        }
                    }
                }
            }
    }
    
    private var key: String { source ? id : "\(id)DEST" }
    
    private var opacity: CGFloat {
        guard let idx = index else { return 1 }
        if source {
            return portalModel.info[idx].destinationAnchor == nil ? 1 : 0
        } else {
            return portalModel.info[idx].initalized ? (portalModel.info[idx].hideView ? 1 : 0) : 1
        }
    }
    
    private var index: Int? {
        portalModel.info.firstIndex { $0.infoID == id }
    }
}

// MARK: - iOS 15+ Fallback Implementation

/// iOS 15 compatible version of Portal using EnvironmentObject.
///
/// This fallback implementation provides the same functionality as the iOS 17 version
/// but uses the traditional EnvironmentObject pattern for compatibility with earlier iOS versions.
///
/// - Warning: This implementation is deprecated and will be removed in a future version.
///   Use the iOS 17+ version when possible.
@available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
public struct PortalLegacy<Content: View>: View {
    private let id: String
    private let source: Bool
    @ViewBuilder private let content: Content
    @EnvironmentObject private var portalModel: CrossModelLegacy
    
    /// Initializes a new PortalLegacy view.
    ///
    /// - Parameters:
    ///   - id: A unique string identifier for this portal
    ///   - source: Whether this portal acts as a source (true) or destination (false). Defaults to true.
    ///   - content: A view builder closure that returns the content to be wrapped
    public init(id: String, source: Bool = true, @ViewBuilder content: () -> Content) {
        self.id = id
        self.source = source
        self.content = content()
    }
    
    /// Transforms anchor preferences for this portal.
    ///
    /// - Parameter anchor: The anchor bounds to transform
    /// - Returns: A dictionary mapping portal IDs to their anchor bounds
    private func anchorPreferenceTransform(anchor: Anchor<CGRect>) -> [String: Anchor<CGRect>] {
        var result: [String: Anchor<CGRect>] = [:]
        if let idx = index, portalModel.info[idx].initalized {
            result = [key: anchor]
        }
        return result
    }
    
    public var body: some View {
        let currentKey = key
        let currentIndex = index
        let isSource = source
        let model = portalModel
        
        return content
            .opacity(opacity)
            .anchorPreference(key: AnchorKey.self, value: .bounds, transform: anchorPreferenceTransform)
            .onPreferenceChange(AnchorKey.self) { prefs in
                Task { @MainActor in
                    if let idx = currentIndex, model.info[idx].initalized {
                        if !isSource {
                            model.info[idx].destinationAnchor = prefs[currentKey]
                        } else if model.info[idx].sourceAnchor == nil {
                            model.info[idx].sourceAnchor = prefs[currentKey]
                        }
                    }
                }
            }
    }
    
    private var key: String { source ? id : "\(id)DEST" }
    
    private var opacity: CGFloat {
        guard let idx = index else { return 1 }
        if source {
            return portalModel.info[idx].destinationAnchor == nil ? 1 : 0
        } else {
            return portalModel.info[idx].initalized ? (portalModel.info[idx].hideView ? 1 : 0) : 1
        }
    }
    
    private var index: Int? {
        portalModel.info.firstIndex { $0.infoID == id }
    }
}

// MARK: - Portal Role Enum

/// Defines the role of a portal in a transition.
@available(iOS 15.0, *)
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
    @available(iOS 15.0, *)
    func portal(id: String, _ role: PortalRole) -> some View {
        let isSource = role == .source
        if #available(iOS 17.0, *) {
            return Portal(id: id, source: isSource) { self }
        } else {
            return PortalLegacy(id: id, source: isSource) { self }
        }
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
    @available(iOS 15.0, *)
    func portal<Item: Identifiable>(item: Item, _ role: PortalRole) -> some View {
        let key = "\(item.id)"
        let isSource = role == .source
        if #available(iOS 17.0, *) {
            return Portal(id: key, source: isSource) { self }
        } else {
            return PortalLegacy(id: key, source: isSource) { self }
        }
    }
    /// Marks this view as a portal source (leaving view).
    ///
    /// Attach this modifier to the view that should act as the source for a portal transition.
    /// The source view is typically the element that the user interacts with to initiate the transition.
    ///
    /// - Parameter id: A unique string identifier for this portal source. This should match the `id`
    ///   used for the corresponding portal destination and transition.
    ///
    /// Example usage:
    /// ```swift
    /// Image("cover")
    ///     .portalSource(id: "Book1")
    /// ```
    ///
    /// - Warning: This method is deprecated. Use `.portal(id:, .source)` instead.
    @available(iOS 15.0, *)
    @available(iOS, deprecated: 15.0, message: "Use .portal(id:, .source) instead")
    func portalSource(id: String) -> some View {
        if #available(iOS 17.0, *) {
            return Portal(id: id, source: true) { self }
        } else {
            return PortalLegacy(id: id, source: true) { self }
        }
    }
    
    /// Marks this view as a portal source using an `Identifiable` item's ID.
    ///
    /// This convenience method automatically extracts the string representation of an `Identifiable`
    /// item's ID to use as the portal identifier. This is particularly useful when working with
    /// data models that conform to `Identifiable`, as it ensures consistent ID usage across
    /// source and destination views without manual string conversion.
    ///
    /// The method converts the item's ID to a string using string interpolation, which works
    /// for most common ID types including `UUID`, `Int`, `String`, and custom types with
    /// proper string representations.
    ///
    /// - Parameter item: An `Identifiable` item whose ID will be used as the portal identifier.
    ///   The string representation of `item.id` will be used as the portal key.
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
    /// Image("cover")
    ///     .portalSource(item: book)  // Uses book.id automatically
    /// ```
    ///
    /// - Warning: This method is deprecated. Use `.portal(item:, .source)` instead.
    @available(iOS 15.0, *)
    @available(iOS, deprecated: 15.0, message: "Use .portal(item:, .source) instead")
    func portalSource<Item: Identifiable>(item: Item) -> some View {
        let key = "\(item.id)"
        if #available(iOS 17.0, *) {
            return Portal(id: key, source: true) { self }
        } else {
            return PortalLegacy(id: key, source: true) { self }
        }
    }
    
    /// Marks this view as a portal destination (arriving view).
    ///
    /// Attach this modifier to the view that should act as the destination for a portal transition.
    /// The destination view is typically the element that appears after the transition completes.
    ///
    /// - Parameter id: A unique string identifier for this portal destination. This should match the `id`
    ///   used for the corresponding portal source and transition.
    ///
    /// Example usage:
    /// ```swift
    /// Image("cover")
    ///     .portalDestination(id: "Book1")
    /// ```
    ///
    /// - Warning: This method is deprecated. Use `.portal(id:, .destination)` instead.
    @available(iOS 15.0, *)
    @available(iOS, deprecated: 15.0, message: "Use .portal(id:, .destination) instead")
    func portalDestination(id: String) -> some View {
        if #available(iOS 17.0, *) {
            return Portal(id: id, source: false) { self }
        } else {
            return PortalLegacy(id: id, source: false) { self }
        }
    }
    
    /// Marks this view as a portal destination using an `Identifiable` item's ID.
    ///
    /// This convenience method automatically extracts the string representation of an `Identifiable`
    /// item's ID to use as the portal identifier. This ensures perfect ID matching between source
    /// and destination views when working with the same data model, eliminating the risk of
    /// ID mismatches that could prevent portal animations from working correctly.
    ///
    /// The method is designed to work seamlessly with the corresponding `portalSource(item:)` method,
    /// ensuring that both source and destination views use identical string representations of the
    /// same item's ID.
    ///
    /// - Parameter item: An `Identifiable` item whose ID will be used as the portal identifier.
    ///   The string representation of `item.id` must match the ID used in the corresponding source view.
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
    /// // In source view
    /// Image("thumbnail")
    ///     .portalSource(item: book)
    ///
    /// // In destination view (same book instance)
    /// Image("fullsize")
    ///     .portalDestination(item: book)  // Automatically matches source ID
    /// ```
    ///
    /// **Important:** Both source and destination views must use the same `Identifiable` item
    /// instance (or items with identical IDs) for the portal animation to work correctly.
    ///
    /// - Warning: This method is deprecated. Use `.portal(item:, .destination)` instead.
    @available(iOS 15.0, *)
    @available(iOS, deprecated: 15.0, message: "Use .portal(item:, .destination) instead")
    func portalDestination<Item: Identifiable>(item: Item) -> some View {
        let key = "\(item.id)"
        if #available(iOS 17.0, *) {
            return Portal(id: key, source: false) { self }
        } else {
            return PortalLegacy(id: key, source: false) { self }
        }
    }
}
