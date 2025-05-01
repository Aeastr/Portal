import SwiftUI

/// A view wrapper that marks its content as a portal source (leaving view).
///
/// Used internally by the `.portalSource(id:)` view modifier to identify the source (origin)
/// of a portal transition animation. You typically do not use this type directly; instead,
/// use the `.portalSource(id:)` modifier on your view.
///
/// - Parameters:
///   - id: A unique string identifier for this portal source. This should match the `id` used for the corresponding portal destination and transition.
///   - content: The view content to be marked as the source.
public struct PortalSource<Content: View>: View {
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
                var result: [String: Anchor<CGRect>] = [:]
                MainActor.assumeIsolated {
                    if let idx = index, portalModel.info[idx].initalized {
                        result = [id: anchor]
                    }
                }
                return result
            }
            .onPreferenceChange(AnchorKey.self) { prefs in
                Task { @MainActor in 
                    if let idx = index, portalModel.info[idx].initalized, portalModel.info[idx].sourceAnchor == nil {
                        portalModel.info[idx].sourceAnchor = prefs[id]
                    }
                }
            }
    }
    
    private var index: Int? {
        portalModel.info.firstIndex { $0.infoID == id }
    }
    
    private var opacity: CGFloat {
        guard let idx = index else { return 1 }
        return portalModel.info[idx].destinationAnchor == nil ? 1 : 0
    }
}

public extension View {
    /// Marks this view as a portal source (leaving view).
    ///
    /// Attach this modifier to the view that should act as the source for a portal transition.
    ///
    /// - Parameter id: A unique string identifier for this portal source. This should match the `id` used for the corresponding portal destination and transition.
    ///
    /// Example usage:
    /// ```swift
    /// Image("cover")
    ///     .portalSource(id: "Book1")
    /// ```
    func portalSource(id: String) -> some View {
        PortalSource(id: id) { self }
    }
}
