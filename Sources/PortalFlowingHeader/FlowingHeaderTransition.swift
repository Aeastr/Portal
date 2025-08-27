//
//  FlowingHeaderTransition.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
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
    init(title: String, systemImage: String?, image: Image?, customView: CustomView?, transitionStartOffset: CGFloat = -20, transitionRange: CGFloat = 40) {
        self.title = title
        self.systemImage = systemImage
        self.image = image
        self.customView = customView
        self.transitionStartOffset = transitionStartOffset
        self.transitionRange = transitionRange
    }

    func body(content: Content) -> some View {
        content
            .environment(\.titleProgress, titleProgress)
            .onScrollPhaseChange { oldPhase, newPhase in
                isScrolling = [ScrollPhase.interacting, ScrollPhase.decelerating].contains(newPhase)
                
                // When scrolling stops, snap to nearest position
                if !isScrolling {
                    let snapTarget = titleProgress > 0.5 ? 1.0 : 0.0
                    withAnimation(.smooth(duration: 0.3)) {
                        titleProgress = snapTarget
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { oldValue, newValue in
                scrollOffset = newValue

                // Only update progress while actively scrolling
                if isScrolling {
                    let progress = calculateProgress(for: newValue)
                    withAnimation(.smooth(duration: 0.2)) {
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

                    // Try to find both custom view anchors
                    let customSrcKey = AnchorKeyID(kind: "source", id: title, type: "customView")
                    let customDstKey = AnchorKeyID(kind: "destination", id: title, type: "customView")
                    let customSrcAnchor = anchors[customSrcKey]
                    let customDstAnchor = anchors[customDstKey]
                    
                    // Try to find both system image anchors
                    let iconSrcKey = AnchorKeyID(kind: "source", id: title, type: "systemImage")
                    let iconDstKey = AnchorKeyID(kind: "destination", id: title, type: "systemImage")
                    let iconSrcAnchor = anchors[iconSrcKey]
                    let iconDstAnchor = anchors[iconDstKey]
                    
                    // Try to find both image anchors
                    let imageSrcKey = AnchorKeyID(kind: "source", id: title, type: "image")
                    let imageDstKey = AnchorKeyID(kind: "destination", id: title, type: "image")
                    let imageSrcAnchor = anchors[imageSrcKey]
                    let imageDstAnchor = anchors[imageDstKey]

                    // Clamp progress t ∈ [0,1]
                    let clamped = min(max(abs(titleProgress), 0), 1)
                    let t: CGFloat = CGFloat(clamped)

                    // Handle title animation if anchors exist
                    if titleSrcAnchor != nil || titleDstAnchor != nil {
                        let srcRect =
                            titleSrcAnchor != nil
                            ? geometry[titleSrcAnchor!] : (titleDstAnchor != nil ? geometry[titleDstAnchor!] : .zero)
                        let dstRect =
                            titleDstAnchor != nil
                            ? geometry[titleDstAnchor!] : (titleSrcAnchor != nil ? geometry[titleSrcAnchor!] : .zero)

                        // Lerp centers
                        let x = srcRect.midX + (dstRect.midX - srcRect.midX) * t
                        let y = srcRect.midY + (dstRect.midY - srcRect.midY) * t

                        // Compute scale from 28→17pt
                        let sourceFontSize: CGFloat = 28
                        let destFontSize: CGFloat = 17
                        let finalScale = destFontSize / sourceFontSize
                        let currentScale = 1 + (finalScale - 1) * t

                        // Draw title at the source size, scaled & positioned
                        Text(title)
                            .font(.system(size: sourceFontSize, weight: .semibold))
                            .foregroundStyle(.primary)
                            .scaleEffect(currentScale)
                            .position(x: x, y: y)
                    }

                    // Handle system image animation if anchors exist and systemImage is provided
                    if let systemImage = systemImage, iconSrcAnchor != nil || iconDstAnchor != nil {
                        let srcRect =
                            iconSrcAnchor != nil
                            ? geometry[iconSrcAnchor!] : (iconDstAnchor != nil ? geometry[iconDstAnchor!] : .zero)
                        let dstRect =
                            iconDstAnchor != nil
                            ? geometry[iconDstAnchor!] : (iconSrcAnchor != nil ? geometry[iconSrcAnchor!] : .zero)

                        // Lerp centers for system image
                        let x = srcRect.midX + (dstRect.midX - srcRect.midX) * t
                        let y = srcRect.midY + (dstRect.midY - srcRect.midY) * t

                        // Scale the system image (from source size to destination size)
                        let sourceSize = srcRect.size
                        let destSize = dstRect.size

                        // Calculate scale factor to go from source size to destination size
                        let targetWidth = sourceSize.width + (destSize.width - sourceSize.width) * t
                        let targetHeight = sourceSize.height + (destSize.height - sourceSize.height) * t

                        // Render the system image with transformations
                        Image(systemName: systemImage)
                            .font(.system(size: 64))
                            .foregroundStyle(.tint)
                            .frame(width: sourceSize.width, height: sourceSize.height)
                            .scaleEffect(x: targetWidth / sourceSize.width, y: targetHeight / sourceSize.height)
                            .position(x: x, y: y)
                    }

                    // Handle custom view animation if anchors exist and custom view is provided
                    if let customView = customView, customSrcAnchor != nil || customDstAnchor != nil {
                        let srcRect =
                            customSrcAnchor != nil
                            ? geometry[customSrcAnchor!] : (customDstAnchor != nil ? geometry[customDstAnchor!] : .zero)
                        let dstRect =
                            customDstAnchor != nil
                            ? geometry[customDstAnchor!] : (customSrcAnchor != nil ? geometry[customSrcAnchor!] : .zero)

                        // Lerp centers for custom view
                        let x = srcRect.midX + (dstRect.midX - srcRect.midX) * t
                        let y = srcRect.midY + (dstRect.midY - srcRect.midY) * t

                        // Scale the custom view (from source size to destination size)
                        let sourceSize = srcRect.size
                        let destSize = dstRect.size

                        // Calculate scale factor to go from source size to destination size
                        let targetWidth = sourceSize.width + (destSize.width - sourceSize.width) * t
                        let targetHeight = sourceSize.height + (destSize.height - sourceSize.height) * t

                        // Render the actual custom view with transformations
                        customView
                            .frame(width: sourceSize.width, height: sourceSize.height)
                            .scaleEffect(x: targetWidth / sourceSize.width, y: targetHeight / sourceSize.height)
                            .position(x: x, y: y)
                    }

                    // Handle image animation if anchors exist and image is provided
                    if let image = image, imageSrcAnchor != nil || imageDstAnchor != nil {
                        let srcRect =
                            imageSrcAnchor != nil
                            ? geometry[imageSrcAnchor!] : (imageDstAnchor != nil ? geometry[imageDstAnchor!] : .zero)
                        let dstRect =
                            imageDstAnchor != nil
                            ? geometry[imageDstAnchor!] : (imageSrcAnchor != nil ? geometry[imageSrcAnchor!] : .zero)

                        // Lerp centers for image
                        let x = srcRect.midX + (dstRect.midX - srcRect.midX) * t
                        let y = srcRect.midY + (dstRect.midY - srcRect.midY) * t

                        // Scale the image (from source size to destination size)
                        let sourceSize = srcRect.size
                        let destSize = dstRect.size

                        // Calculate scale factor to go from source size to destination size
                        let targetWidth = sourceSize.width + (destSize.width - sourceSize.width) * t
                        let targetHeight = sourceSize.height + (destSize.height - sourceSize.height) * t

                        // Render the actual image with transformations
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: sourceSize.width, height: sourceSize.height)
                            .scaleEffect(x: targetWidth / sourceSize.width, y: targetHeight / sourceSize.height)
                            .position(x: x, y: y)
                    }

                    // Debug message if no anchors found
                    if titleSrcAnchor == nil && titleDstAnchor == nil && 
                       customSrcAnchor == nil && customDstAnchor == nil &&
                       iconSrcAnchor == nil && iconDstAnchor == nil &&
                       imageSrcAnchor == nil && imageDstAnchor == nil
                    {
                        Text("none found – keys: \\(anchors.keys), looking for \\(title)")
                            .foregroundStyle(.red)
                            .background(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }
    }

    /// Calculates transition progress based on scroll offset.
    ///
    /// - Parameter offset: Current scroll offset from scroll geometry
    /// - Returns: Progress value from 0.0 to 1.0
    private func calculateProgress(for offset: CGFloat) -> Double {
        // When scrolling down in the content, offset becomes positive
        // We want to start transitioning when scrolling down past the threshold

        // If we haven't scrolled down enough past the start threshold, return 0
        if offset < transitionStartOffset {
            return 0.0
        }

        // Calculate progress over the transition range
        let progress = min(1.0, (offset - transitionStartOffset) / transitionRange)
        return Double(progress)
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
    /// - Returns: A view with the flowing header transition applied
    ///
    /// - Important: This modifier must be applied outside the NavigationStack,
    ///   while `.flowingHeaderDestination()` should be applied to the scroll content.
    func flowingHeader(
        _ title: String,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40
    ) -> some View {
        modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: nil,
                image: nil,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange
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
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader(
        _ title: String,
        systemImage: String,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40
    ) -> some View {
        modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: systemImage,
                image: nil,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange
            ))
    }
    
    /// Adds a flowing header transition with optional system image.
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - systemImage: Optional SF Symbol that should flow to the navigation bar
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader(
        _ title: String,
        systemImage: String?,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40
    ) -> some View {
        let actualSystemImage = (systemImage?.isEmpty == false) ? systemImage : nil
        return modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: actualSystemImage,
                image: nil,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange
            ))
    }

    /// Adds a flowing header transition with optional image.
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - image: Optional Image that should flow to the navigation bar
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader(
        _ title: String,
        image: Image?,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40
    ) -> some View {
        modifier(
            FlowingHeaderTransition<EmptyView>(
                title: title,
                systemImage: nil,
                image: image,
                customView: nil,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange
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
    /// - Returns: A view with the flowing header transition applied
    func flowingHeader<CustomView: View>(
        _ title: String,
        customView: CustomView,
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40
    ) -> some View {
        modifier(
            FlowingHeaderTransition(
                title: title,
                systemImage: nil,
                image: nil,
                customView: customView,
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange
            ))
    }
}
