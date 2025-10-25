//
//  FlowingHeaderContent.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import os.log

/// Layout style for accessory view positioning in the navigation bar.
@available(iOS 18.0, *)
public enum AccessoryLayout: Sendable {
    /// Accessory positioned horizontally (side by side with title)
    case horizontal
    /// Accessory positioned vertically (stacked on top of title)
    case vertical
}

/// Components that can be displayed and transitioned in a flowing header.
@available(iOS 18.0, *)
public enum FlowingHeaderDisplayComponent: Hashable, Sendable {
    /// The title text component
    case title
    /// The accessory view component
    case accessory
}

/// Configuration for a flowing header, provided via environment.
@available(iOS 18.0, *)
public struct FlowingHeaderContent: Sendable {
    /// Unique identifier for this header configuration
    public let id: String

    /// The main title text
    public let title: String

    /// Secondary subtitle text
    public let subtitle: String

    /// Components to display in the navigation bar destination
    public let displays: Set<FlowingHeaderDisplayComponent>

    /// Layout style for navigation bar (horizontal or vertical)
    public let layout: AccessoryLayout

    public init(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<FlowingHeaderDisplayComponent> = [.title],
        layout: AccessoryLayout = .horizontal
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.displays = displays
        self.layout = layout
    }
}

// MARK: - Equatable Conformance

@available(iOS 18.0, *)
extension FlowingHeaderContent: Equatable {
    public static func == (lhs: FlowingHeaderContent, rhs: FlowingHeaderContent) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.displays == rhs.displays &&
        lhs.layout == rhs.layout
    }
}

// MARK: - Environment Keys

@available(iOS 18.0, *)
private struct FlowingHeaderContentKey: EnvironmentKey {
    static let defaultValue: FlowingHeaderContent? = nil
}

/// Environment key for the accessory view.
///
/// - Note: Uses `AnyView` for type erasure to simplify the API. This allows
///   users to provide any accessory view type without threading generics through
///   the entire view hierarchy. The performance impact is minimal since this is
///   a single view rendered in the navigation bar.
@available(iOS 18.0, *)
private struct FlowingHeaderAccessoryViewKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AnyView? = nil
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    /// The current flowing header configuration
    var flowingHeaderContent: FlowingHeaderContent? {
        get { self[FlowingHeaderContentKey.self] }
        set { self[FlowingHeaderContentKey.self] = newValue }
    }

    /// The custom accessory view for flowing headers
    var flowingHeaderAccessoryView: AnyView? {
        get { self[FlowingHeaderAccessoryViewKey.self] }
        set { self[FlowingHeaderAccessoryViewKey.self] = newValue }
    }
}

// MARK: - Modifier

/// A view modifier that configures a flowing header via environment and applies transitions.
@available(iOS 18.0, *)
private struct FlowingHeaderModifier<AccessoryContent: View>: ViewModifier {
    let config: FlowingHeaderContent
    let accessoryContent: AccessoryContent?

    @State private var titleProgress: Double = 0.0
    @State private var isScrolling = false
    @State private var scrollOffset: CGFloat = 0
    @State private var accessoryFlowing = false
    @State private var accessorySourceHeight: CGFloat = 0

    func body(content: Content) -> some View {
        let measuredAccessory = accessoryContent.map { accessory in
            AnyView(
                accessory
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        accessorySourceHeight = newSize.height
                    }
            )
        }

        content
            .environment(\.flowingHeaderContent, config)
            .environment(\.flowingHeaderAccessoryView, measuredAccessory)
            .environment(\.flowingHeaderLayout, config.layout)
            .environment(\.titleProgress, titleProgress)
            .environment(\.accessoryFlowing, accessoryFlowing)
            .onScrollPhaseChange { _, newPhase in
                isScrolling = [ScrollPhase.interacting, ScrollPhase.decelerating].contains(newPhase)

                // When scrolling stops, snap to nearest position
                if !isScrolling {
                    let snapTarget = titleProgress > 0.5 ? 1.0 : 0.0
                    withAnimation(.smooth(duration: FlowingHeaderTokens.transitionDuration)) {
                        titleProgress = snapTarget
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                return geometry.contentOffset.y + geometry.contentInsets.top
            } action: { _, newValue in
                scrollOffset = newValue
                // Only update progress while actively scrolling
                if isScrolling {
                    // If accessory is flowing, start earlier (when it's partially scrolled)
                    // Otherwise use full height or fallback
                    let hasFlowingAccessory = config.displays.contains(.accessory)
                    let startAt: CGFloat

                    if hasFlowingAccessory && accessorySourceHeight > 0 {
                        startAt = accessorySourceHeight / FlowingHeaderTokens.accessoryStartDivisor
                    } else {
                        startAt = accessorySourceHeight > 0 ? accessorySourceHeight : FlowingHeaderTokens.fallbackStartOffset
                    }

                    let progress = FlowingHeaderCalculations.calculateProgress(
                        scrollOffset: newValue,
                        startAt: startAt,
                        range: FlowingHeaderTokens.transitionRange
                    )
                    withAnimation(.smooth(duration: FlowingHeaderTokens.scrollAnimationDuration)) {
                        titleProgress = progress
                    }
                }
            }
            .overlayPreferenceValue(AnchorKey.self) { anchors in
                renderTransition(anchors: anchors)
            }
    }

    @ViewBuilder
    private func renderTransition(anchors: [AnchorKeyID: Anchor<CGRect>]) -> some View {
        GeometryReader { geometry in
            let titleSrcKey = AnchorKeyID(kind: "source", id: config.id, type: "title")
            let titleDstKey = AnchorKeyID(kind: "destination", id: config.id, type: "title")
            let accessorySrcKey = AnchorKeyID(kind: "source", id: config.id, type: "accessory")
            let accessoryDstKey = AnchorKeyID(kind: "destination", id: config.id, type: "accessory")

            // titleProgress is already clamped 0-1 by FlowingHeaderCalculations.calculateProgress
            let progress = CGFloat(titleProgress)
            let hasBothAccessoryAnchors = anchors[accessorySrcKey] != nil && anchors[accessoryDstKey] != nil

            // Update accessoryFlowing based on whether both anchors exist
            // onAppear: Set initial state when view first renders
            // onChange: Update state when anchors change (e.g., during navigation or config changes)
            Color.clear
                .onAppear {
                    accessoryFlowing = hasBothAccessoryAnchors
                }
                .onChange(of: hasBothAccessoryAnchors) { _, newValue in
                    accessoryFlowing = newValue
                }

            if let titleSrc = anchors[titleSrcKey], let titleDst = anchors[titleDstKey] {
                renderTitle(geometry: geometry, srcAnchor: titleSrc, dstAnchor: titleDst, progress: progress)
            }

            if let accessorySrc = anchors[accessorySrcKey], let accessoryDst = anchors[accessoryDstKey] {
                renderAccessory(geometry: geometry, srcAnchor: accessorySrc, dstAnchor: accessoryDst, progress: progress)
            }
        }
    }

    private func renderTitle(geometry: GeometryProxy, srcAnchor: Anchor<CGRect>, dstAnchor: Anchor<CGRect>, progress: CGFloat) -> some View {
        let srcRect = geometry[srcAnchor]
        let dstRect = geometry[dstAnchor]
        let position = FlowingHeaderCalculations.calculatePosition(
            sourceRect: srcRect,
            destinationRect: dstRect,
            progress: progress
        )

        // Calculate scale based on actual rendered sizes to support Dynamic Type
        let sourceFont = Font.title.weight(.semibold)
        let destFont = Font.headline.weight(.semibold)

        // Use ratio of rect heights as proxy for font size ratio
        let scaleRatio = dstRect.height / srcRect.height
        let currentScale = 1 + (scaleRatio - 1) * progress

        return Text(config.title)
            .font(sourceFont)
            .foregroundStyle(.primary)
            .scaleEffect(currentScale)
            .position(x: position.x, y: position.y)
    }

    @ViewBuilder
    private func renderAccessory(geometry: GeometryProxy, srcAnchor: Anchor<CGRect>, dstAnchor: Anchor<CGRect>, progress: CGFloat) -> some View {
        if let accessory = accessoryContent {
            let srcRect = geometry[srcAnchor]
            let dstRect = geometry[dstAnchor]
            let position = FlowingHeaderCalculations.calculatePosition(
                sourceRect: srcRect,
                destinationRect: dstRect,
                progress: progress
            )
            let scale = FlowingHeaderCalculations.calculateScale(
                sourceSize: srcRect.size,
                destinationSize: dstRect.size,
                progress: progress
            )

            accessory
                .frame(width: srcRect.size.width, height: srcRect.size.height)
                .scaleEffect(x: scale.x, y: scale.y)
                .position(x: position.x, y: position.y)
        }
    }
}

@available(iOS 18.0, *)
public extension View {
    /// Configures a flowing header with title and subtitle only.
    ///
    /// Apply this modifier to a NavigationStack to provide configuration for
    /// FlowingHeaderView and flowingHeaderDestination modifiers within.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         FlowingHeaderView()
    ///     }
    ///     .flowingHeaderDestination()
    /// }
    /// .flowingHeader(title: "Profile", subtitle: "Settings")
    /// ```
    ///
    /// - Parameters:
    ///   - id: Optional identifier for multiple headers (default: "default")
    ///   - title: The main title text
    ///   - subtitle: Secondary subtitle text
    ///   - displays: Components to show in nav bar (default: [.title])
    ///   - layout: Layout style for nav bar (default: .horizontal)
    func flowingHeader(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<FlowingHeaderDisplayComponent> = [.title],
        layout: AccessoryLayout = .horizontal
    ) -> some View {
        let config = FlowingHeaderContent(
            id: id,
            title: title,
            subtitle: subtitle,
            displays: displays,
            layout: layout
        )
        return modifier(FlowingHeaderModifier<EmptyView>(config: config, accessoryContent: nil))
    }

    /// Configures a flowing header with title, subtitle, and custom accessory.
    ///
    /// Apply this modifier to a NavigationStack to provide configuration for
    /// FlowingHeaderView and flowingHeaderDestination modifiers within.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         FlowingHeaderView()
    ///     }
    ///     .flowingHeaderDestination(displays: [.title, .accessory])
    /// }
    /// .flowingHeader(
    ///     title: "Profile",
    ///     subtitle: "Settings",
    ///     displays: [.title, .accessory]
    /// ) {
    ///     Image(systemName: "person.circle")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - id: Optional identifier for multiple headers (default: "default")
    ///   - title: The main title text
    ///   - subtitle: Secondary subtitle text
    ///   - displays: Components to show in nav bar (default: [.title, .accessory])
    ///   - layout: Layout style for nav bar (default: .horizontal)
    ///   - accessory: View builder for custom accessory content
    func flowingHeader<AccessoryContent: View>(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<FlowingHeaderDisplayComponent> = [.title, .accessory],
        layout: AccessoryLayout = .vertical,
        @ViewBuilder accessory: () -> AccessoryContent
    ) -> some View {
        let config = FlowingHeaderContent(
            id: id,
            title: title,
            subtitle: subtitle,
            displays: displays,
            layout: layout
        )
        return modifier(FlowingHeaderModifier(config: config, accessoryContent: accessory()))
    }
}
