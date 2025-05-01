import SwiftUI

/// A view wrapper that marks its content as a portal destination (arriving view).
///
/// Used internally by the `.portalDestination(id:)` view modifier to identify the destination
/// (target) of a portal transition animation. You typically do not use this type directly;
/// instead, use the `.portalDestination(id:)` modifier on your view.
///
/// - Parameters:
///   - id: A unique string identifier for this portal destination. This should match the `id` used for the corresponding portal source and transition.
///   - content: The view content to be marked as the destination.
public struct PortalDestination<Content: View>: View {
    public let id: String
    @ViewBuilder public let content: Content
    @EnvironmentObject private var portalModel: CrossModel
    
    public init(id: String, @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
    }
    
    public var body: some View {
        content
            .opacity(opacity)
            .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                if let index, portalModel.info[index].initalized{
                    return [destKey: anchor]
                }
                
                return [:]
            }
            .onPreferenceChange(AnchorKey.self) { prefs in
                Task { @MainActor in
                    if let idx = index, portalModel.info[idx].initalized {
                        portalModel.info[idx].destinationAnchor = prefs[destKey]
                    }
                }
            }
    }
    
    private var destKey: String { "\(id)DEST" }
    
    private var index: Int? {
        portalModel.info.firstIndex { $0.infoID == id }
    }
    
    private var opacity: CGFloat {
        guard let idx = index else { return 1 }
        return portalModel.info[idx].initalized ? (portalModel.info[idx].hideView ? 1 : 0) : 1
    }
}

public extension View {
    /// Marks this view as a portal destination (arriving view).
    ///
    /// Attach this modifier to the view that should act as the destination for a portal transition.
    ///
    /// - Parameter id: A unique string identifier for this portal destination. This should match the `id` used for the corresponding portal source and transition.
    ///
    /// Example usage:
    /// ```swift
    /// Image("cover")
    ///     .portalDestination(id: "Book1")
    /// ```
    func portalDestination(id: String) -> some View {
        PortalDestination(id: id) { self }
    }
}
