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
import LogOutLoud

/// Layout style for accessory view positioning in the navigation bar.
@available(iOS 18.0, *)
public enum AccessoryLayout: Sendable {
    /// Accessory positioned horizontally (side by side with title)
    case horizontal
    /// Accessory positioned vertically (stacked on top of title)
    case vertical
}

/// Snapping behavior when scrolling stops in the transition zone.
@available(iOS 18.0, *)
public enum SnappingBehavior: Sendable {
    /// Snap to nearest position (0.0 or 1.0) based on midpoint (0.5)
    case nearest
    /// Snap based on scroll direction: down → 1.0, up → 0.0
    case directional
    /// No snapping - header stays at current progress
    case none
}

/// Scroll direction for tracking user intent.
@available(iOS 18.0, *)
private enum ScrollDirection {
    /// Scrolling downward (increasing offset)
    case down
    /// Scrolling upward (decreasing offset)
    case up

    var isDown: Bool {
        self == .down
    }
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

    /// Snapping behavior when scrolling stops
    public let snappingBehavior: SnappingBehavior

    public init(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<FlowingHeaderDisplayComponent> = [.title],
        layout: AccessoryLayout = .horizontal,
        snappingBehavior: SnappingBehavior = .directional
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.displays = displays
        self.layout = layout
        self.snappingBehavior = snappingBehavior
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
        lhs.layout == rhs.layout &&
        lhs.snappingBehavior == rhs.snappingBehavior
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
    @State private var lastScrollDirection: ScrollDirection = .down
    @State private var hasSnapped = false
    @State private var snappedValue: Double = 0.0
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
                let wasScrolling = isScrolling
                isScrolling = [ScrollPhase.interacting, ScrollPhase.decelerating].contains(newPhase)

                // When scrolling stops, snap based on configured behavior
                // Only snap if we're in the transition zone (progress between 0 and 1)
                if wasScrolling && !isScrolling && titleProgress > 0.0 && titleProgress < 1.0 {
                    let snapTarget: Double?

                    switch config.snappingBehavior {
                    case .directional:
                        // Snap based on scroll direction: down → 1.0, up → 0.0
                        snapTarget = lastScrollDirection.isDown ? 1.0 : 0.0
                        FlowingHeaderLogs.logger.log(
                            "Directional snap triggered",
                            level: .debug,
                            tags: [FlowingHeaderLogs.Tags.snapping],
                            metadata: [
                                "direction": lastScrollDirection.isDown ? "down" : "up",
                                "target": "\(snapTarget!)",
                                "currentProgress": "\(titleProgress)"
                            ]
                        )

                    case .nearest:
                        // Snap to nearest position based on midpoint
                        snapTarget = titleProgress > 0.5 ? 1.0 : 0.0
                        FlowingHeaderLogs.logger.log(
                            "Nearest snap triggered",
                            level: .debug,
                            tags: [FlowingHeaderLogs.Tags.snapping],
                            metadata: [
                                "progress": "\(titleProgress)",
                                "target": "\(snapTarget!)"
                            ]
                        )

                    case .none:
                        // No snapping
                        snapTarget = nil
                        FlowingHeaderLogs.logger.log(
                            "Snap disabled",
                            level: .debug,
                            tags: [FlowingHeaderLogs.Tags.snapping],
                            metadata: ["progress": "\(titleProgress)"]
                        )
                    }

                    if let snapTarget = snapTarget {
                        withAnimation(.smooth(duration: FlowingHeaderTokens.transitionDuration)) {
                            titleProgress = snapTarget
                        }

                        // Remember that we've snapped (for directional behavior persistence)
                        hasSnapped = true
                        snappedValue = snapTarget
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                return geometry.contentOffset.y + geometry.contentInsets.top
            } action: { _, newOffset in
                let currentDirection: ScrollDirection = newOffset > scrollOffset ? .down : .up

                // Track direction during scroll (ignore tiny movements to prevent jitter)
                if abs(newOffset - scrollOffset) > FlowingHeaderTokens.scrollDirectionThreshold {
                    lastScrollDirection = currentDirection
                }

                scrollOffset = newOffset

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
                    scrollOffset: newOffset,
                    startAt: startAt,
                    range: FlowingHeaderTokens.transitionRange
                )

                // Only update progress while actively scrolling
                if isScrolling {
                    // If we've snapped and user continues scrolling in same direction, keep it snapped
                    if hasSnapped {
                        let shouldKeepSnapped = (snappedValue == 1.0 && currentDirection.isDown) || (snappedValue == 0.0 && !currentDirection.isDown)

                        if shouldKeepSnapped {
                            // Keep snapped, don't update progress
                            FlowingHeaderLogs.logger.log(
                                "Maintaining snap position",
                                level: .debug,
                                tags: [FlowingHeaderLogs.Tags.scroll],
                                metadata: ["snappedValue": "\(snappedValue)"]
                            )
                            return
                        } else {
                            // User reversed direction, reset snap state
                            FlowingHeaderLogs.logger.log(
                                "Direction reversed, releasing snap",
                                level: .debug,
                                tags: [FlowingHeaderLogs.Tags.scroll],
                                metadata: [
                                    "previousSnap": "\(snappedValue)",
                                    "newDirection": currentDirection.isDown ? "down" : "up"
                                ]
                            )
                            hasSnapped = false
                        }
                    }

                    FlowingHeaderLogs.logger.log(
                        "Scroll progress update",
                        level: .debug,
                        tags: [FlowingHeaderLogs.Tags.scroll],
                        metadata: [
                            "offset": String(format: "%.1f", newOffset),
                            "progress": String(format: "%.2f", progress),
                            "direction": currentDirection.isDown ? "down" : "up"
                        ]
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
    ///   - snappingBehavior: How to snap when scrolling stops (default: .directional)
    func flowingHeader(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<FlowingHeaderDisplayComponent> = [.title],
        layout: AccessoryLayout = .horizontal,
        snappingBehavior: SnappingBehavior = .directional
    ) -> some View {
        let config = FlowingHeaderContent(
            id: id,
            title: title,
            subtitle: subtitle,
            displays: displays,
            layout: layout,
            snappingBehavior: snappingBehavior
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
    ///   - snappingBehavior: How to snap when scrolling stops (default: .directional)
    ///   - accessory: View builder for custom accessory content
    func flowingHeader<AccessoryContent: View>(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<FlowingHeaderDisplayComponent> = [.title, .accessory],
        layout: AccessoryLayout = .vertical,
        snappingBehavior: SnappingBehavior = .directional,
        @ViewBuilder accessory: () -> AccessoryContent
    ) -> some View {
        let config = FlowingHeaderContent(
            id: id,
            title: title,
            subtitle: subtitle,
            displays: displays,
            layout: layout,
            snappingBehavior: snappingBehavior
        )
        return modifier(FlowingHeaderModifier(config: config, accessoryContent: accessory()))
    }
}
