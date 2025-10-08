import SwiftUI

/// A protocol for creating custom animated portal layers.
///
/// Conform to this protocol to create reusable animated components that respond to portal transitions.
/// The protocol automatically handles CrossModel observation and provides the `isActive` state.
///
/// Example:
/// ```swift
/// struct MyCustomAnimation<Content: View>: AnimatedPortalLayer {
///     let portalID: String
///     @ViewBuilder let content: () -> Content
///
///     func animatedContent(isActive: Bool) -> some View {
///         content()
///             .scaleEffect(isActive ? 1.25 : 1.0)
///             .onChange(of: isActive) { newValue in
///                 // Custom animation timing logic
///             }
///     }
/// }
/// ```
@available(iOS 15.0, *)
public protocol AnimatedPortalLayer: View {
    associatedtype Content: View
    associatedtype AnimatedContent: View

    /// The unique identifier for this portal layer.
    var portalID: String { get }

    /// The content to be animated.
    @ViewBuilder var content: () -> Content { get }

    /// Implement this method to define your custom animation logic.
    /// - Parameter isActive: Whether the portal transition is currently active.
    /// - Returns: The animated view.
    @ViewBuilder func animatedContent(isActive: Bool) -> AnimatedContent
}

@available(iOS 15.0, *)
public extension AnimatedPortalLayer {
    @ViewBuilder
    var body: some View {
        if #available(iOS 17.0, *) {
            AnimatedPortalLayerHost(layer: self)
        } else {
            AnimatedPortalLayerHostLegacy(layer: self)
        }
    }
}

// MARK: - iOS 17+ Implementation

@available(iOS 17.0, *)
private struct AnimatedPortalLayerHost<Layer: AnimatedPortalLayer>: View {
    @Environment(CrossModel.self) private var portalModel
    let layer: Layer

    var body: some View {
        let idx = portalModel.info.firstIndex { $0.infoID == layer.portalID }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false

        layer.animatedContent(isActive: isActive)
    }
}

// MARK: - iOS 15+ Legacy Implementation

@available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
private struct AnimatedPortalLayerHostLegacy<Layer: AnimatedPortalLayer>: View {
    @EnvironmentObject private var portalModel: CrossModelLegacy
    let layer: Layer

    var body: some View {
        let idx = portalModel.info.firstIndex { $0.infoID == layer.portalID }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false

        layer.animatedContent(isActive: isActive)
    }
}
