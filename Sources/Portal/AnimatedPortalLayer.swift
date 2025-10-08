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

public extension AnimatedPortalLayer {
    @ViewBuilder
    var body: some View {
        AnimatedPortalLayerHost(layer: self)
    }
}

private struct AnimatedPortalLayerHost<Layer: AnimatedPortalLayer>: View {
    @Environment(CrossModel.self) private var portalModel
    let layer: Layer

    var body: some View {
        let idx = portalModel.info.firstIndex { $0.infoID == layer.portalID }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false

        layer.animatedContent(isActive: isActive)
    }
}

