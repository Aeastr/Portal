//
//  FlowingHeaderTransition.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
//

import SwiftUI

/// Helper function to select the current header ID with debug logging
@available(iOS 18.0, *)
private func selectHeaderID(from anchors: [(key: AnchorKeyID, data: AnchorData)]) -> String? {
    // Convert array to dictionary for easier lookups
    let anchorDict = Dictionary(anchors.map { ($0.key, $0.data) }, uniquingKeysWith: { _, last in last })
    
    // Find the last source title in the array (most recently added)
    let lastSourceTitle = anchors.reversed().first { $0.key.kind == "source" && $0.key.type == "title" }
    
    guard let activeID = lastSourceTitle?.key.id else {
        #if DEBUG
        print("=== Anchor Selection Debug ===")
        print("No source title anchors found")
        print("==============================")
        #endif
        return nil
    }
    
    // Verify this ID has both title anchors needed for animation
    let hasSrcTitle = anchorDict[AnchorKeyID(id: activeID, kind: "source", type: "title")] != nil
    let hasDstTitle = anchorDict[AnchorKeyID(id: activeID, kind: "destination", type: "title")] != nil
    
    if hasSrcTitle && hasDstTitle {
        #if DEBUG
        print("=== Anchor Selection Debug ===")
        print("Anchor order: \(anchors.map { "\($0.key.id):\($0.key.kind):\($0.key.type)" })")
        print("Selected ID: \(activeID) (last source title with destination)")
        print("==============================")
        #endif
        return activeID
    }
    
    #if DEBUG
    print("=== Anchor Selection Debug ===")
    print("Selected ID: \(activeID) missing destination, skipping")
    print("==============================")
    #endif
    
    return nil
}

/// A view modifier that creates smooth scroll-based transitions for flowing headers.
///
/// This modifier tracks scroll position and animates header elements between their
/// source position (in the scroll view) and destination position (in the navigation bar).
/// It uses anchor preferences to precisely track element bounds and interpolate between them.
///
/// The transition supports both text titles and custom views, with configurable timing
/// and scroll thresholds.
@available(iOS 18.0, *)
internal struct FlowingHeaderTransition: ViewModifier {
    let transitionStartOffset: CGFloat
    let transitionRange: CGFloat
    let experimentalAvoidance: Bool
    @State private var titleProgress: Double = 0.0
    @State private var isScrolling = false
    @State private var scrollOffset: CGFloat = 0

    /// Creates a new flowing header transition modifier.
    ///
    /// - Parameters:
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    init(transitionStartOffset: CGFloat = -20, transitionRange: CGFloat = 40, experimentalAvoidance: Bool = false) {
        self.transitionStartOffset = transitionStartOffset
        self.transitionRange = transitionRange
        self.experimentalAvoidance = experimentalAvoidance
    }

    func body(content: Content) -> some View {
        content
            .environment(\.titleProgress, titleProgress)
            // TODO: Set flowing flags based on detected content
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
                    ZStack {
                        // Use helper function to select header ID with debug logging
                        let currentID = selectHeaderID(from: anchors)
                        
                        // Convert array to dictionary for lookups
                        let anchorDict = Dictionary(anchors.map { ($0.key, $0.data) }, uniquingKeysWith: { _, last in last })
                        
                        // Get unique IDs for debug display
                        let sourceAnchors = anchors.filter { $0.key.kind == "source" }
                        let uniqueIDs = Set(sourceAnchors.map { $0.key.id })
                        
                        if let currentID = currentID {
                            // Try to find both title anchors
                            let titleSrcKey = AnchorKeyID(id: currentID, kind: "source", type: "title")
                            let titleDstKey = AnchorKeyID(id: currentID, kind: "destination", type: "title")
                            let titleSrcData = anchorDict[titleSrcKey]
                            let titleDstData = anchorDict[titleDstKey]

                            // Try to find both accessory anchors
                            let accessorySrcKey = AnchorKeyID(id: currentID, kind: "source", type: "accessory")
                            let accessoryDstKey = AnchorKeyID(id: currentID, kind: "destination", type: "accessory")
                            let accessorySrcData = anchorDict[accessorySrcKey]
                            let accessoryDstData = anchorDict[accessoryDstKey]

                            // Extract content info from the first available data
                            let content = titleSrcData?.content ?? titleDstData?.content ?? 
                                        accessorySrcData?.content ?? accessoryDstData?.content

                            // Clamp progress t ∈ [0,1]
                            let clamped = min(max(abs(titleProgress), 0), 1)
                            let t: CGFloat = CGFloat(clamped)

                            // Render title if both anchors exist
                            if let titleSrcData = titleSrcData, let titleDstData = titleDstData {
                                renderTitle(
                                    geometry: geometry,
                                    srcAnchor: titleSrcData.anchor,
                                    dstAnchor: titleDstData.anchor,
                                    progress: t,
                                    accessorySrcAnchor: accessorySrcData?.anchor,
                                    title: content?.title ?? ""
                                )
                            }

                            // Render accessory if both anchors exist
                            if let accessorySrcData = accessorySrcData, let accessoryDstData = accessoryDstData, let content = content {
                                renderAccessory(
                                    geometry: geometry,
                                    srcAnchor: accessorySrcData.anchor,
                                    dstAnchor: accessoryDstData.anchor,
                                    progress: t,
                                    content: content
                                )
                            }
                            
                            // Debug overlay
                            #if DEBUG
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🔍 Active: \"\(currentID)\"")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.white)
                                
                                if uniqueIDs.count > 1 {
                                    let availableInfo = uniqueIDs.sorted().map { id in
                                        let count = [
                                            anchorDict[AnchorKeyID(id: id, kind: "source", type: "title")] != nil,
                                            anchorDict[AnchorKeyID(id: id, kind: "destination", type: "title")] != nil,
                                            anchorDict[AnchorKeyID(id: id, kind: "source", type: "accessory")] != nil,
                                            anchorDict[AnchorKeyID(id: id, kind: "destination", type: "accessory")] != nil
                                        ].filter { $0 }.count
                                        return "\(id)(\(count))"
                                    }.joined(separator: ", ")
                                    
                                    Text("Available: \(availableInfo)")
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(.yellow)
                                }
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Title")
                                            .font(.caption2.weight(.semibold))
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(titleSrcData != nil ? .green : .red)
                                                .frame(width: 8, height: 8)
                                            Text("src")
                                                .font(.caption2.monospaced())
                                        }
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(titleDstData != nil ? .green : .red)
                                                .frame(width: 8, height: 8)
                                            Text("dst")
                                                .font(.caption2.monospaced())
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Accessory")
                                            .font(.caption2.weight(.semibold))
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(accessorySrcData != nil ? .green : .red)
                                                .frame(width: 8, height: 8)
                                            Text("src")
                                                .font(.caption2.monospaced())
                                        }
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(accessoryDstData != nil ? .green : .red)
                                                .frame(width: 8, height: 8)
                                            Text("dst")
                                                .font(.caption2.monospaced())
                                        }
                                    }
                                }
                                
                                if let content = content {
                                    Text("Content: \(content.systemImage ?? "none")")
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                
                                Text("Progress: \(String(format: "%.2f", t))")
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding(8)
                            .background(.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .padding()
                            #endif
                        } else {
                            // No headers found debug
                            #if DEBUG
                            VStack(alignment: .leading, spacing: 4) {
                                Text("⚠️ No headers detected")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.white)
                                
                                Text("Available IDs: \(uniqueIDs.isEmpty ? "none" : uniqueIDs.joined(separator: ", "))")
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                Text("Total anchors: \(anchors.count)")
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding(8)
                            .background(.orange.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .padding()
                            #endif
                        }
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
    
    
    /// Renders the title with animation between source and destination positions.
    private func renderTitle(
        geometry: GeometryProxy,
        srcAnchor: Anchor<CGRect>,
        dstAnchor: Anchor<CGRect>,
        progress: CGFloat,
        accessorySrcAnchor: Anchor<CGRect>?,
        title: String
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
        progress: CGFloat,
        content: FlowingHeaderContent
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
        let targetWidth = sourceSize.width + (destSize.width - sourceSize.width) * progress
        let targetHeight = sourceSize.height + (destSize.height - sourceSize.height) * progress

        // Render the appropriate accessory content with transformations
        return Group {
            if let systemImage = content.systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
            } else if content.hasCustomView {
                // For custom views, we'd need a way to reconstruct them
                // For now, show a placeholder
                Circle().fill(.tint.opacity(0.5))
            } else if content.image != nil {
                // Similarly for images, we'd need the actual Image
                RoundedRectangle(cornerRadius: 8).fill(.tint.opacity(0.5))
            }
        }
        .frame(width: sourceSize.width, height: sourceSize.height)
        .scaleEffect(x: targetWidth / sourceSize.width, y: targetHeight / sourceSize.height)
        .position(x: x, y: y)
    }

    /// Calculates dynamic offset during transition using sine curve.
    ///
    /// - Parameters:
    ///   - progress: Current transition progress (0-1)
    ///   - accessoryOffset: Base offset amount from accessory width
    /// - Returns: Smoothly interpolated offset that peaks at mid-transition
    private func calculateDynamicOffset(progress: CGFloat, accessoryOffset: CGFloat) -> CGFloat {
        let offsetMultiplier = sin(progress * .pi) // Peaks at 0.5 progress, zero at start/end
        return accessoryOffset * offsetMultiplier
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
        let baseX = srcRect.midX + (dstRect.midX - srcRect.midX) * progress
        let x = baseX + offset
        let y = srcRect.midY + (dstRect.midY - srcRect.midY) * progress
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Public API

@available(iOS 18.0, *)
public extension View {
    /// Adds a flowing header transition that animates based on scroll position.
    ///
    /// This modifier creates a smooth transition effect where header content flows
    /// to the navigation bar as the user scrolls. It automatically detects the current
    /// header by matching source and destination anchors.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// NavigationStack {
    ///     ScrollView {
    ///         FlowingHeaderView("Title", systemImage: "star", subtitle: "Subtitle")
    ///         // Content...
    ///     }
    ///     .flowingHeaderDestination("Title", systemImage: "star")
    /// }
    /// .flowingHeader()  // No parameters needed!
    /// ```
    ///
    /// - Parameters:
    ///   - transitionStartOffset: Scroll offset where transition begins (default: -20)
    ///   - transitionRange: Distance over which transition occurs (default: 40)
    ///   - experimentalAvoidance: Enable experimental collision avoidance (default: false)
    /// - Returns: A view with the flowing header transition applied
    ///
    /// - Important: This modifier must be applied outside the NavigationStack,
    ///   while `.flowingHeaderDestination()` should be applied to the scroll content.
    func flowingHeader(
        transitionStartOffset: CGFloat = -20,
        transitionRange: CGFloat = 40,
        experimentalAvoidance: Bool = false
    ) -> some View {
        modifier(
            FlowingHeaderTransition(
                transitionStartOffset: transitionStartOffset,
                transitionRange: transitionRange,
                experimentalAvoidance: experimentalAvoidance
            ))
    }
}
