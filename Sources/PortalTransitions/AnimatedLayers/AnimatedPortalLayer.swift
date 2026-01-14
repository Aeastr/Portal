//
//  AnimatedPortalLayer.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A protocol for creating custom animated portal layers.
///
/// Conform to this protocol to create reusable animated components that respond to portal transitions.
/// The protocol automatically handles CrossModel observation and provides the `isActive` state.
///
/// > Tip: For styling the transition layer (clips, shadows, corner radii), consider using
/// > the `configuration` closure on `.portalTransition()` instead — it's simpler and doesn't require
/// > creating a separate type. Use this protocol when you need:
/// > - Custom timing logic with `onChange(of: isActive)`
/// > - Reusable animated components across multiple portals
///
/// Example:
/// ```swift
/// struct MyCustomAnimation<Content: View>: AnimatedPortalLayer {
///     let portalID: AnyHashable
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
    /// Can be any `Hashable` type wrapped in `AnyHashable`.
    var portalID: AnyHashable { get }

    /// The namespace for scoping portal lookup.
    var namespace: Namespace.ID { get }

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
        let idx = portalModel.info.firstIndex { $0.infoID == layer.portalID && $0.namespace == layer.namespace }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false

        layer.animatedContent(isActive: isActive)
    }
}
