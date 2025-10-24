//
//  FlowingHeaderTransition.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A view modifier that creates smooth scroll-based transitions for flowing headers.
///
/// This modifier tracks scroll position and animates header elements between their
/// source position (in the scroll view) and destination position (in the navigation bar).
/// It uses anchor preferences to precisely track element bounds and interpolate between them.
///
/// The transition supports both text titles and custom views, with configurable timing
/// and scroll thresholds.
@available(iOS 18.0, *)
internal struct FlowingHeaderTransition<CustomView: View>: ViewModifier {
    let title: String
    let systemImage: String?
    let image: Image?
    let customView: CustomView?
    let transitionStartOffset: CGFloat
    let transitionRange: CGFloat
    let experimentalAvoidance: Bool
    @State private var titleProgress: Double = 0.0
    @State private var isScrolling = false
    @State private var scrollOffset: CGFloat = 0

    /// Creates a new flowing header transition modifier.
    ///
    /// - Parameters:
    ///   - title: The title string to track for transitions
    ///   - systemImage: Optional system image to animate alongside the title
    ///   - image: Optional image to animate alongside the title
    ///   - customView: Optional custom view to animate alongside the title
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    init(title: String, systemImage: String?, image: Image?, customView: CustomView?, transitionStartOffset: CGFloat = -20, transitionRange: CGFloat = 40, experimentalAvoidance: Bool = false) {
        self.title = title
        self.systemImage = systemImage
        self.image = image
        self.customView = customView
        self.transitionStartOffset = transitionStartOffset
        self.transitionRange = transitionRange
        self.experimentalAvoidance = experimentalAvoidance
    }

    func body(content: Content) -> some View {
        content
            .environment(\.titleProgress, titleProgress)
            .environment(\.systemImageFlowing, systemImage?.isEmpty == false)
            .environment(\.imageFlowing, image != nil)
            .environment(\.customViewFlowing, customView != nil)
            .onScrollPhaseChange { _, newPhase in
                isScrolling = [ScrollPhase.interacting, ScrollPhase.decelerating].contains(newPhase)

                // When scrolling stops, snap to nearest position
                if !isScrolling {
                    let snapTarget = titleProgress > 0.5 ? 1.0 : 0.0
                    withAnimation(.smooth(duration: FlowingHeaderConstants.transitionDuration)) {
                        titleProgress = snapTarget
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue

                // Only update progress while actively scrolling
                if isScrolling {
                    let progress = calculateProgress(for: newValue)
                    withAnimation(.smooth(duration: FlowingHeaderConstants.scrollAnimationDuration)) {
                        titleProgress = progress
                    }
                }
            }
            .overlayPreferenceValue(AnchorKey.self) { anchors in
                GeometryReader { geometry in
                    // Try to find both title anchors
                    let titleSrcKey = AnchorKeyID(kind: "source", id: title, type: "title")
                    let titleDstKey = AnchorKeyID(kind: "destination", id: title, type: "title")
                    let titleSrcAnchor = anchors[titleSrcKey]
                    let titleDstAnchor = anchors[titleDstKey]

                    // Try to find both accessory anchors (any type of accessory content)
                    let accessorySrcKey = AnchorKeyID(kind: "source", id: title, type: "accessory")
                    let accessoryDstKey = AnchorKeyID(kind: "destination", id: title, type: "accessory")
                    let accessorySrcAnchor = anchors[accessorySrcKey]
                    let accessoryDstAnchor = anchors[accessoryDstKey]

                    // Clamp progress t ∈ [0,1]
                    let clamped = min(max(abs(titleProgress), 0), 1)
                    let t = CGFloat(clamped)

                    // Render title if both anchors exist
                    if titleSrcAnchor != nil && titleDstAnchor != nil {
                        renderTitle(
                            geometry: geometry,
                            srcAnchor: titleSrcAnchor!,
                            dstAnchor: titleDstAnchor!,
                            progress: t,
                            accessorySrcAnchor: accessorySrcAnchor
                        )
                    }

                    // Render accessory if both anchors exist
                    if accessorySrcAnchor != nil && accessoryDstAnchor != nil {
                        renderAccessory(
                            geometry: geometry,
                            srcAnchor: accessorySrcAnchor!,
                            dstAnchor: accessoryDstAnchor!,
                            progress: t
                        )
                    }

                    #if DEBUG
                    // Debug message if no anchors found
                    if titleSrcAnchor == nil && titleDstAnchor == nil &&
                       accessorySrcAnchor == nil && accessoryDstAnchor == nil {
                        Text("none found – keys: \(anchors.keys), looking for \(title)")
                            .foregroundStyle(.red)
                            .background(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                    #endif
                }
            }
    }

    /// Calculates transition progress based on scroll offset.
    ///
    /// - Parameter offset: Current scroll offset from scroll geometry
    /// - Returns: Progress value from 0.0 to 1.0
    private func calculateProgress(for offset: CGFloat) -> Double {
        FlowingHeaderCalculations.calculateProgress(
            scrollOffset: offset,
            startOffset: transitionStartOffset,
            range: transitionRange
        )
    }


    /// Renders the title with animation between source and destination positions.
    private func renderTitle(
        geometry: GeometryProxy,
        srcAnchor: Anchor<CGRect>,
        dstAnchor: Anchor<CGRect>,
        progress: CGFloat,
        accessorySrcAnchor: Anchor<CGRect>?
    ) -> some View {
        let srcRect = geometry[srcAnchor]
        let dstRect = geometry[dstAnchor]

        let titleDynamicOffset = experimentalAvoidance
            ? calculateDynamicOffset(
                progress: progress,
                accessoryOffset: (accessorySrcAnchor != nil ? geometry[accessorySrcAnchor!].width / 4 : 0)
            )
            : 0

        let titlePosition = calculateTitlePosition(
            srcRect: srcRect,
            dstRect: dstRect,
            progress: progress,
            offset: titleDynamicOffset
        )

        // Compute scale from 28→17pt
        let sourceFontSize: CGFloat = 28
        let destFontSize: CGFloat = 17
        let finalScale = destFontSize / sourceFontSize
        let currentScale = 1 + (finalScale - 1) * progress

        // Draw title at the source size, scaled & positioned
        return Text(title)
            .font(.system(size: sourceFontSize, weight: .semibold))
            .foregroundStyle(.primary)
            .scaleEffect(currentScale)
            .position(x: titlePosition.x, y: titlePosition.y)
    }

    /// Renders the accessory with animation between source and destination positions.
    private func renderAccessory(
        geometry: GeometryProxy,
        srcAnchor: Anchor<CGRect>,
        dstAnchor: Anchor<CGRect>,
        progress: CGFloat
    ) -> some View {
        let srcRect = geometry[srcAnchor]
        let dstRect = geometry[dstAnchor]

        // Calculate position with optional collision avoidance
        let baseX = srcRect.midX + (dstRect.midX - srcRect.midX) * progress
        let x = experimentalAvoidance
            ? baseX + calculateDynamicOffset(progress: progress, accessoryOffset: -(srcRect.width / 2) / 2)
            : baseX
        let y = srcRect.midY + (dstRect.midY - srcRect.midY) * progress

        // Scale the accessory (from source size to destination size)
        let sourceSize = srcRect.size
        let destSize = dstRect.size

        // Calculate scale factor to go from source size to destination size
        let scale = FlowingHeaderCalculations.calculateScale(
            sourceSize: sourceSize,
            destinationSize: destSize,
            progress: progress
        )

        // Render the appropriate accessory content with transformations
        return Group {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
            } else if let customView = customView {
                customView
            } else if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: sourceSize.width, height: sourceSize.height)
        .scaleEffect(x: scale.x, y: scale.y)
        .position(x: x, y: y)
    }

    /// Calculates dynamic offset during transition using sine curve.
    ///
    /// - Parameters:
    ///   - progress: Current transition progress (0-1)
    ///   - accessoryOffset: Base offset amount from accessory width
    /// - Returns: Smoothly interpolated offset that peaks at mid-transition
    private func calculateDynamicOffset(progress: CGFloat, accessoryOffset: CGFloat) -> CGFloat {
        FlowingHeaderCalculations.calculateDynamicOffset(
            progress: progress,
            baseOffset: accessoryOffset
        )
    }

    /// Calculates title position with collision avoidance offset.
    ///
    /// - Parameters:
    ///   - srcRect: Source rectangle bounds
    ///   - dstRect: Destination rectangle bounds
    ///   - progress: Current transition progress (0-1)
    ///   - offset: Dynamic offset to apply
    /// - Returns: Final position point with offset applied
    private func calculateTitlePosition(
        srcRect: CGRect,
        dstRect: CGRect,
        progress: CGFloat,
        offset: CGFloat
    ) -> CGPoint {
        FlowingHeaderCalculations.calculatePosition(
            sourceRect: srcRect,
            destinationRect: dstRect,
            progress: progress,
            horizontalOffset: offset
        )
    }
}

// MARK: - Public API

@available(iOS 18.0, *)
public extension View {
    /// Adds a flowing header transition that animates based on scroll position.
    ///
    /// This modifier creates a smooth transition effect where header content flows
    /// to the navigation bar as the user scrolls. The transition timing and behavior
    /// can be customized through the provided parameters.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         FlowingHeaderView(icon: "star", title: "Title", subtitle: "Subtitle")
    ///         // Content...
    ///     }
    ///     .flowingHeaderDestination("Title")
    /// }
    /// .flowingHeader("Title")
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches the FlowingHeaderView title
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    ///
    /// - Important: This modifier must be applied outside the NavigationStack,
    ///   while `.flowingHeaderDestination()` should be applied to the scroll content.
    func flowingHeader(
        _ title: String,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: nil,
                image: nil,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange,
                experimentalAvoidance: experimentalAvoidance
            ))
    }

    /// Adds a flowing header transition with a system image that flows to the navigation bar.
    ///
    /// Use this variant when your header includes a system image that should animate
    /// to the navigation bar along with the title.
    ///
    /// ## Usage with Flowing System Image
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         FlowingHeaderView("Profile", systemImage: "person.circle", subtitle: "Settings")
    ///         // Content...
    ///     }
    ///     .flowingHeaderDestination("Profile") {
    ///         Image(systemName: "person.circle").font(.headline)
    ///     }
    /// }
    /// .flowingHeader("Profile", systemImage: "person.circle")
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - systemImage: The SF Symbol that should flow to the navigation bar
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader(
        _ title: String,
        systemImage: String,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: systemImage,
                image: nil,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange,
                experimentalAvoidance: experimentalAvoidance
            ))
    }

    /// Adds a flowing header transition with optional system image.
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - systemImage: Optional SF Symbol that should flow to the navigation bar
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader(
        _ title: String,
        systemImage: String?,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        let actualSystemImage = (systemImage?.isEmpty == false) ? systemImage : nil
        return modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: actualSystemImage,
                image: nil,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange,
                experimentalAvoidance: experimentalAvoidance
            ))
    }

    /// Adds a flowing header transition with optional image.
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - image: Optional Image that should flow to the navigation bar
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader(
        _ title: String,
        image: Image?,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: nil,
                image: image,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange,
                experimentalAvoidance: experimentalAvoidance
            ))
    }

    /// Adds a flowing header transition with a custom view component.
    ///
    /// Use this variant when your header includes a custom view that should also
    /// animate to the navigation bar along with the title.
    ///
    /// ## Usage with Custom View
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         FlowingHeaderView(customView: Avatar(), title: "Profile", subtitle: "Settings")
    ///         // Content...
    ///     }
    ///     .flowingHeaderDestination("Profile") { Avatar() }
    /// }
    /// .flowingHeader("Profile", customView: Avatar())
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches the FlowingHeaderView title
    ///   - customView: The custom view that should animate alongside the title
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader<CustomView: View>(
        _ title: String,
        customView: CustomView,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        modifier(
            FlowingHeaderTransition(
                title: title,
                systemImage: nil,
                image: nil,
                customView: customView,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange,
                experimentalAvoidance: experimentalAvoidance
            ))
    }

    /// Adds a flowing header transition with multiple optional content types.
    ///
    /// This is the most flexible variant that allows you to conditionally specify
    /// different content types for dynamic header switching scenarios.
    ///
    /// ## Usage with Dynamic Content
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         // Dynamic header content...
    ///     }
    ///     .flowingHeaderDestination("Title") { /* conditional destination */ }
    /// }
    /// .flowingHeader("Title",
    ///     systemImage: showIcon ? "star" : nil,
    ///     image: showImage ? Image("hero") : nil,
    ///     customView: showCustom ? AnyView(CustomView()) : nil
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches the FlowingHeaderView title
    ///   - systemImage: Optional system image that flows to navigation bar
    ///   - image: Optional image that flows to navigation bar
    ///   - customView: Optional type-erased custom view that flows to navigation bar
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    ///
    /// - Note: Only the first non-nil content parameter will be used. Priority order is:
    ///   customView > image > systemImage. This overload accepts `AnyView` for the custom view
    ///   parameter to support dynamic content scenarios. While this incurs a small performance cost,
    ///   it's mitigated by using `@ViewBuilder`. Prefer the strongly-typed
    ///   `flowingHeader(_:customView:)` overload when the view type is known at compile time.
    @_disfavoredOverload
    @ViewBuilder
    func flowingHeader(
        _ title: String,
        systemImage: String? = nil,
        image: Image? = nil,
        customView: AnyView? = nil,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        if let customView = customView {
            modifier(
                FlowingHeaderTransition(
                    title: title,
                    systemImage: nil,
                    image: nil,
                    customView: customView,
                    transitionStartOffset: transitionStartOffset,
                    transitionRange: transitionRange,
                    experimentalAvoidance: experimentalAvoidance
                ))
        } else if let image = image {
            modifier(
                FlowingHeaderTransition<EmptyView>(
                    title: title,
                    systemImage: nil,
                    image: image,
                    customView: nil,
                    transitionStartOffset: transitionStartOffset,
                    transitionRange: transitionRange,
                    experimentalAvoidance: experimentalAvoidance
                ))
        } else if let systemImage = systemImage {
            modifier(
                FlowingHeaderTransition<EmptyView>(
                    title: title,
                    systemImage: systemImage,
                    image: nil,
                    customView: nil,
                    transitionStartOffset: transitionStartOffset,
                    transitionRange: transitionRange,
                    experimentalAvoidance: experimentalAvoidance
                ))
        } else {
            modifier(
                FlowingHeaderTransition<EmptyView>(
                    title: title,
                    systemImage: nil,
                    image: nil,
                    customView: nil,
                    transitionStartOffset: transitionStartOffset,
                    transitionRange: transitionRange,
                    experimentalAvoidance: experimentalAvoidance
                ))
        }
    }
}
