import SwiftUI

// MARK: - Direct Parameter Modifiers (New API)

/// Portal transition modifier that uses direct parameters instead of config object
internal struct ConditionalPortalTransitionModifierDirect<LayerView: View>: ViewModifier {
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    public let id: String
    public let animation: PortalAnimation
    @Binding public var isActive: Bool
    public let layerView: () -> LayerView
    public let completion: (Bool) -> Void

    func body(content: Content) -> some View {
        let config = PortalTransitionConfig(animation: animation, corners: environmentCorners)

        return content.modifier(
            ConditionalPortalTransitionModifier(
                id: id,
                config: config,
                isActive: $isActive,
                layerView: layerView,
                completion: completion
            )
        )
    }
}

/// Optional item portal transition modifier with direct parameters
internal struct OptionalPortalTransitionModifierDirect<Item: Identifiable, LayerView: View>: ViewModifier {
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    @Binding public var item: Optional<Item>
    public let animation: PortalAnimation
    public let layerView: (Item) -> LayerView
    public let completion: (Bool) -> Void

    func body(content: Content) -> some View {
        let config = PortalTransitionConfig(animation: animation, corners: environmentCorners)

        return content.modifier(
            OptionalPortalTransitionModifier(
                item: $item,
                config: config,
                layerView: layerView,
                completion: completion
            )
        )
    }
}

/// Multi-ID portal transition modifier with direct parameters
internal struct MultiIDPortalTransitionModifierDirect<LayerView: View>: ViewModifier {
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    public let ids: [String]
    public let groupID: String
    public let animation: PortalAnimation
    public let corners: PortalCorners?
    @Binding public var isActive: Bool
    public let layerView: (String) -> LayerView
    public let completion: (Bool) -> Void

    func body(content: Content) -> some View {
        let effectiveCorners = corners ?? environmentCorners
        let config = PortalTransitionConfig(animation: animation, corners: effectiveCorners)

        return content.modifier(
            MultiIDPortalTransitionModifier(
                ids: ids,
                groupID: groupID,
                config: config,
                isActive: $isActive,
                layerView: layerView,
                completion: completion
            )
        )
    }
}

/// Multi-item portal transition modifier with direct parameters
internal struct MultiItemPortalTransitionModifierDirect<Item: Identifiable, LayerView: View>: ViewModifier {
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalCorners) private var environmentCorners

    @Binding public var items: [Item]
    public let groupID: String
    public let animation: PortalAnimation
    public let corners: PortalCorners?
    public let staggerDelay: TimeInterval
    public let layerView: (Item) -> LayerView
    public let completion: (Bool) -> Void

    func body(content: Content) -> some View {
        let effectiveCorners = corners ?? environmentCorners
        let config = PortalTransitionConfig(animation: animation, corners: effectiveCorners)

        return content.modifier(
            MultiItemPortalTransitionModifier(
                items: $items,
                groupID: groupID,
                config: config,
                layerView: layerView,
                completion: completion,
                staggerDelay: staggerDelay
            )
        )
    }
}