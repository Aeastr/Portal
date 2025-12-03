//
//  PortalHeaderContent.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Chronicle

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
public enum PortalHeaderDisplayComponent: Hashable, Sendable {
    /// The title text component
    case title
    /// The accessory view component
    case accessory
}

/// Configuration for a flowing header, provided via environment.
@available(iOS 18.0, *)
public struct PortalHeaderContent: Sendable {
    /// Unique identifier for this header configuration
    public let id: String

    /// The main title text
    public let title: String

    /// Secondary subtitle text
    public let subtitle: String

    /// Components to display in the navigation bar destination
    public let displays: Set<PortalHeaderDisplayComponent>

    /// Layout style for navigation bar (horizontal or vertical)
    public let layout: AccessoryLayout

    /// Snapping behavior when scrolling stops
    public let snappingBehavior: SnappingBehavior

    public init(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<PortalHeaderDisplayComponent> = [.title],
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
extension PortalHeaderContent: Equatable {
    public static func == (lhs: PortalHeaderContent, rhs: PortalHeaderContent) -> Bool {
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
private struct PortalHeaderContentKey: EnvironmentKey {
    static let defaultValue: PortalHeaderContent? = nil
}

/// Environment key for the accessory view.
///
/// - Note: Uses `AnyView` for type erasure to simplify the API. This allows
///   users to provide any accessory view type without threading generics through
///   the entire view hierarchy. The performance impact is minimal since this is
///   a single view rendered in the navigation bar.
@available(iOS 18.0, *)
private struct PortalHeaderAccessoryViewKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AnyView? = nil
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    /// The current flowing header configuration
    var portalHeaderContent: PortalHeaderContent? {
        get { self[PortalHeaderContentKey.self] }
        set { self[PortalHeaderContentKey.self] = newValue }
    }

    /// The custom accessory view for flowing headers
    var portalHeaderAccessoryView: AnyView? {
        get { self[PortalHeaderAccessoryViewKey.self] }
        set { self[PortalHeaderAccessoryViewKey.self] = newValue }
    }
}

// MARK: - Modifier

/// A view modifier that configures a flowing header via environment and applies transitions.
@available(iOS 18.0, *)
private struct PortalHeaderModifier<AccessoryContent: View>: ViewModifier {
    let config: PortalHeaderContent
    let accessoryContent: AccessoryContent?

    // Cache the type-erased accessory view to avoid recreating AnyView on every body call
    private let accessoryAnyView: AnyView?

    init(config: PortalHeaderContent, accessoryContent: AccessoryContent?) {
        self.config = config
        self.accessoryContent = accessoryContent
        self.accessoryAnyView = accessoryContent.map { AnyView($0) }
    }

    @State private var titleProgress: Double = 0.0
    @State private var isScrolling = false
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollDirection: ScrollDirection = .down
    @State private var hasSnapped = false
    @State private var snappedValue: Double = 0.0
    @State private var accessoryFlowing = false
    @State private var accessorySourceHeight: CGFloat = 0

    // Cache last known source sizes for when source scrolls off-screen
    @State private var lastKnownTitleSourceSize: CGSize = .zero
    @State private var lastKnownAccessorySourceSize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .environment(\.portalHeaderContent, config)
            .environment(\.portalHeaderAccessoryView, accessoryAnyView)
            .environment(\.portalHeaderLayout, config.layout)
            .environment(\.titleProgress, titleProgress)
            .environment(\.accessoryFlowing, accessoryFlowing)
            .onPreferenceChange(AccessorySourceHeightKey.self) { height in
                accessorySourceHeight = height
            }
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
                        PortalHeaderLogs.logger.log(
                            "Directional snap triggered",
                            level: .debug,
                            tags: [PortalHeaderLogs.Tags.snapping],
                            metadata: [
                                "direction": lastScrollDirection.isDown ? "down" : "up",
                                "target": "\(snapTarget!)",
                                "currentProgress": "\(titleProgress)"
                            ]
                        )

                    case .nearest:
                        // Snap to nearest position based on midpoint
                        snapTarget = titleProgress > 0.5 ? 1.0 : 0.0
                        PortalHeaderLogs.logger.log(
                            "Nearest snap triggered",
                            level: .debug,
                            tags: [PortalHeaderLogs.Tags.snapping],
                            metadata: [
                                "progress": "\(titleProgress)",
                                "target": "\(snapTarget!)"
                            ]
                        )

                    case .none:
                        // No snapping
                        snapTarget = nil
                        PortalHeaderLogs.logger.log(
                            "Snap disabled",
                            level: .debug,
                            tags: [PortalHeaderLogs.Tags.snapping],
                            metadata: ["progress": "\(titleProgress)"]
                        )
                    }

                    if let snapTarget = snapTarget {
                        withAnimation(.smooth(duration: PortalHeaderTokens.transitionDuration)) {
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
                if abs(newOffset - scrollOffset) > PortalHeaderTokens.scrollDirectionThreshold {
                    lastScrollDirection = currentDirection
                }

                scrollOffset = newOffset

                // If accessory is flowing, start earlier (when it's partially scrolled)
                // Otherwise use full height or fallback
                let hasFlowingAccessory = config.displays.contains(.accessory)
                let startAt: CGFloat

                if hasFlowingAccessory && accessorySourceHeight > 0 {
                    startAt = accessorySourceHeight / PortalHeaderTokens.accessoryStartDivisor
                } else {
                    startAt = accessorySourceHeight > 0 ? accessorySourceHeight : PortalHeaderTokens.fallbackStartOffset
                }

                let progress = PortalHeaderCalculations.calculateProgress(
                    scrollOffset: newOffset,
                    startAt: startAt,
                    range: PortalHeaderTokens.transitionRange
                )

                // Only update progress while actively scrolling
                if isScrolling {
                    // If we've snapped and user continues scrolling in same direction, keep it snapped
                    if hasSnapped {
                        let shouldKeepSnapped = (snappedValue == 1.0 && currentDirection.isDown) || (snappedValue == 0.0 && !currentDirection.isDown)

                        if shouldKeepSnapped {
                            // Keep snapped, don't update progress
                            PortalHeaderLogs.logger.log(
                                "Maintaining snap position",
                                level: .debug,
                                tags: [PortalHeaderLogs.Tags.scroll],
                                metadata: ["snappedValue": "\(snappedValue)"]
                            )
                            return
                        } else {
                            // User reversed direction, reset snap state
                            PortalHeaderLogs.logger.log(
                                "Direction reversed, releasing snap",
                                level: .debug,
                                tags: [PortalHeaderLogs.Tags.scroll],
                                metadata: [
                                    "previousSnap": "\(snappedValue)",
                                    "newDirection": currentDirection.isDown ? "down" : "up"
                                ]
                            )
                            hasSnapped = false
                        }
                    }

                    PortalHeaderLogs.logger.log(
                        "Scroll progress update",
                        level: .debug,
                        tags: [PortalHeaderLogs.Tags.scroll],
                        metadata: [
                            "offset": String(format: "%.1f", newOffset),
                            "progress": String(format: "%.2f", progress),
                            "direction": currentDirection.isDown ? "down" : "up"
                        ]
                    )

                    withAnimation(.smooth(duration: PortalHeaderTokens.scrollAnimationDuration)) {
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

            // titleProgress is already clamped 0-1 by PortalHeaderCalculations.calculateProgress
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

            // Title transition: render at interpolated position, or at destination if source scrolled off
            if let titleDst = anchors[titleDstKey] {
                if let titleSrc = anchors[titleSrcKey] {
                    renderTitle(geometry: geometry, srcAnchor: titleSrc, dstAnchor: titleDst, progress: progress)
                } else {
                    // Source off-screen, render at destination
                    renderTitleAtDestination(geometry: geometry, dstAnchor: titleDst)
                }
            }

            // Accessory transition: render at interpolated position, or at destination if source scrolled off
            if let accessoryDst = anchors[accessoryDstKey] {
                if let accessorySrc = anchors[accessorySrcKey] {
                    renderAccessory(geometry: geometry, srcAnchor: accessorySrc, dstAnchor: accessoryDst, progress: progress)
                } else {
                    // Source off-screen, render at destination
                    renderAccessoryAtDestination(geometry: geometry, dstAnchor: accessoryDst)
                }
            }
        }
    }

    private func renderTitle(geometry: GeometryProxy, srcAnchor: Anchor<CGRect>, dstAnchor: Anchor<CGRect>, progress: CGFloat) -> some View {
        let srcRect = geometry[srcAnchor]
        let dstRect = geometry[dstAnchor]
        let position = PortalHeaderCalculations.calculatePosition(
            sourceRect: srcRect,
            destinationRect: dstRect,
            progress: progress
        )

        // Use ratio of rect heights as proxy for font size ratio
        let scaleRatio = dstRect.height / srcRect.height
        let currentScale = 1 + (scaleRatio - 1) * progress

        return Text(config.title)
            .font(.title.weight(.semibold))
            .foregroundStyle(.primary)
            .scaleEffect(currentScale)
            .position(x: position.x, y: position.y)
            .onChange(of: srcRect.size) { _, newSize in
                if newSize != .zero {
                    lastKnownTitleSourceSize = newSize
                }
            }
            .onAppear {
                if srcRect.size != .zero {
                    lastKnownTitleSourceSize = srcRect.size
                }
            }
    }

    private func renderTitleAtDestination(geometry: GeometryProxy, dstAnchor: Anchor<CGRect>) -> some View {
        let dstRect = geometry[dstAnchor]

        // Use cached source size to calculate final scale
        let sourceSize = lastKnownTitleSourceSize != .zero ? lastKnownTitleSourceSize : dstRect.size
        let scaleRatio = sourceSize.height > 0 ? dstRect.height / sourceSize.height : 1.0

        return Text(config.title)
            .font(.title.weight(.semibold))
            .foregroundStyle(.primary)
            .scaleEffect(scaleRatio)
            .position(x: dstRect.midX, y: dstRect.midY)
    }

    @ViewBuilder
    private func renderAccessory(geometry: GeometryProxy, srcAnchor: Anchor<CGRect>, dstAnchor: Anchor<CGRect>, progress: CGFloat) -> some View {
        if let accessory = accessoryContent {
            let srcRect = geometry[srcAnchor]
            let dstRect = geometry[dstAnchor]
            let position = PortalHeaderCalculations.calculatePosition(
                sourceRect: srcRect,
                destinationRect: dstRect,
                progress: progress
            )
            let scale = PortalHeaderCalculations.calculateScale(
                sourceSize: srcRect.size,
                destinationSize: dstRect.size,
                progress: progress
            )

            // Calculate fade - accessory fades out as it moves toward destination.
            // This fade is applied here in the overlay rather than in PortalHeaderView
            // to avoid causing PortalHeaderView to re-render on every scroll frame.
            let fadeValue = PortalHeaderCalculations.calculateAccessoryFade(
                progress: Double(progress),
                fadeMultiplier: PortalHeaderTokens.accessoryFadeMultiplier
            )

            // Cache source size only when it meaningfully changes (avoid per-frame updates)
            let shouldUpdateCache = srcRect.size != .zero && srcRect.size != lastKnownAccessorySourceSize

            accessory
                .frame(width: srcRect.size.width, height: srcRect.size.height)
                .scaleEffect(x: scale.x, y: scale.y)
                .opacity(fadeValue)
                .position(x: position.x, y: position.y)
                .onAppear {
                    if srcRect.size != .zero {
                        lastKnownAccessorySourceSize = srcRect.size
                    }
                }
                .task(id: shouldUpdateCache) {
                    if shouldUpdateCache {
                        lastKnownAccessorySourceSize = srcRect.size
                    }
                }
        }
    }

    @ViewBuilder
    private func renderAccessoryAtDestination(geometry: GeometryProxy, dstAnchor: Anchor<CGRect>) -> some View {
        if let accessory = accessoryContent {
            let dstRect = geometry[dstAnchor]

            // Use cached source size to maintain proper frame and calculate final scale
            let sourceSize = lastKnownAccessorySourceSize != .zero ? lastKnownAccessorySourceSize : dstRect.size
            let scale = PortalHeaderCalculations.calculateScale(
                sourceSize: sourceSize,
                destinationSize: dstRect.size,
                progress: 1.0  // Fully transitioned
            )

            accessory
                .frame(width: sourceSize.width, height: sourceSize.height)
                .scaleEffect(x: scale.x, y: scale.y)
                .position(x: dstRect.midX, y: dstRect.midY)
        }
    }
}

@available(iOS 18.0, *)
public extension View {
    /// Configures a flowing header with title and subtitle only.
    ///
    /// Apply this modifier to a NavigationStack to provide configuration for
    /// PortalHeaderView and portalHeaderDestination modifiers within.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         PortalHeaderView()
    ///     }
    ///     .portalHeaderDestination()
    /// }
    /// .portalHeader(title: "Profile", subtitle: "Settings")
    /// ```
    ///
    /// - Parameters:
    ///   - id: Optional identifier for multiple headers (default: "default")
    ///   - title: The main title text
    ///   - subtitle: Secondary subtitle text
    ///   - displays: Components to show in nav bar (default: [.title])
    ///   - layout: Layout style for nav bar (default: .horizontal)
    ///   - snappingBehavior: How to snap when scrolling stops (default: .directional)
    func portalHeader(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<PortalHeaderDisplayComponent> = [.title],
        layout: AccessoryLayout = .horizontal,
        snappingBehavior: SnappingBehavior = .directional
    ) -> some View {
        let config = PortalHeaderContent(
            id: id,
            title: title,
            subtitle: subtitle,
            displays: displays,
            layout: layout,
            snappingBehavior: snappingBehavior
        )
        return modifier(PortalHeaderModifier<EmptyView>(config: config, accessoryContent: nil))
    }

    /// Configures a flowing header with title, subtitle, and custom accessory.
    ///
    /// Apply this modifier to a NavigationStack to provide configuration for
    /// PortalHeaderView and portalHeaderDestination modifiers within.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         PortalHeaderView()
    ///     }
    ///     .portalHeaderDestination(displays: [.title, .accessory])
    /// }
    /// .portalHeader(
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
    func portalHeader<AccessoryContent: View>(
        id: String = "default",
        title: String,
        subtitle: String,
        displays: Set<PortalHeaderDisplayComponent> = [.title, .accessory],
        layout: AccessoryLayout = .vertical,
        snappingBehavior: SnappingBehavior = .directional,
        @ViewBuilder accessory: () -> AccessoryContent
    ) -> some View {
        let config = PortalHeaderContent(
            id: id,
            title: title,
            subtitle: subtitle,
            displays: displays,
            layout: layout,
            snappingBehavior: snappingBehavior
        )
        return modifier(PortalHeaderModifier(config: config, accessoryContent: accessory()))
    }
}
