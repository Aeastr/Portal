//
//  PortalLayerView.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI


/// Internal overlay view responsible for rendering and animating portal transition layers.
///
/// This view serves as the main rendering engine for portal animations. It creates an overlay
/// that displays intermediate animation layers during portal transitions, handling the smooth
/// movement and scaling between source and destination positions.
///
/// The view uses a `GeometryReader` to access coordinate space information needed for
/// calculating precise positions and sizes during animations. It manages multiple concurrent
/// portal animations through the shared `CrossModel`.
///
/// **Architecture:**
/// - Uses `GeometryReader` to access coordinate space for position calculations
/// - Iterates through all active portal animations in the model
/// - Delegates individual animation rendering to `PortalLayerContentView`
internal struct PortalLayerView: View {
    /// The shared model containing all portal animation data and state.
    @Environment(CrossModel.self) private var portalModel

    var body: some View {
        GeometryReader(content: geometryReaderContent)
    }

    /// Builds the content within the geometry reader context.
    ///
    /// Creates individual `PortalLayerContentView` instances for each active portal animation,
    /// passing the geometry proxy for coordinate calculations. The `@Bindable` wrapper allows
    /// the individual content views to modify portal state directly.
    ///
    /// - Parameter proxy: Geometry proxy providing coordinate space access
    /// - Returns: A view containing all active portal animation layers
    @ViewBuilder
    private func geometryReaderContent(proxy: GeometryProxy) -> some View {
        @Bindable var model = portalModel
        ForEach($model.info) { $info in
            PortalLayerContentView(proxy: proxy, info: $info)
        }
    }
}

/// Individual portal layer content view that handles a single portal animation.
///
/// This view is responsible for rendering one specific portal transition, including:
/// - Animating the layer view between source and destination positions
/// - Managing the animation lifecycle and cleanup
/// - Handling size and position interpolation during transitions
/// - Executing completion callbacks at appropriate times
///
/// **Animation Lifecycle:**
/// 1. Layer appears at source position/size when animation starts
/// 2. Animates smoothly to destination position/size
/// 3. Handles cleanup and state reset after animation completes
/// 4. Calls completion handlers to notify the system of animation status
private struct PortalLayerContentView: View {
    /// Geometry proxy for coordinate space calculations and position conversions.
    var proxy: GeometryProxy

    /// Binding to the portal animation data, allowing direct state modifications.
    @Binding var info: PortalInfo

    @Environment(\.portalDebugOverlays) private var debugOverlaysEnabled

    /// Builds the animated layer view that transitions between source and destination.
    ///
    /// This computed property creates the visual layer that users see during the portal
    /// transition. It performs real-time interpolation between source and destination
    /// positions and sizes based on the current animation state.
    ///
    /// **Rendering Conditions:**
    /// - Source anchor must be available (source view positioned)
    /// - Destination anchor must be available (destination view positioned)
    /// - Layer view must be provided (transition content)
    /// - View must not be hidden (`!info.hideView`)
    ///
    /// **Animation Interpolation:**
    /// - Position: Animates from source minX/minY to destination minX/minY
    /// - Size: Animates from source width/height to destination width/height
    /// - Uses `info.animateView` flag to determine current target values
    ///
    /// **Coordinate System:**
    /// - Uses `proxy[anchor]` to convert anchor bounds to global coordinates
    /// - Positions layer using `.offset()` for precise placement
    /// - Uses `.frame()` for size animation
    var body: some View {
        if let source = info.sourceAnchor,
           let destination = info.destinationAnchor,
           let layer = info.layerView,
           !info.hideView {
            // Convert anchor bounds to concrete rectangles in global coordinate space
            let sRect = proxy[source]
            let dRect = proxy[destination]
            let animate = info.animateView

            // Interpolate size between source and destination based on animation state
            let width = animate ? dRect.size.width : sRect.size.width
            let height = animate ? dRect.size.height : sRect.size.height

            // Interpolate position between source and destination based on animation state
            let x = animate ? dRect.minX : sRect.minX
            let y = animate ? dRect.minY : sRect.minY

            // Only apply clipShape if corners are configured
            Group {
                if let corners = info.corners {
                    let cornerRadius = animate ? corners.destination : corners.source
                    layer
                        .clipShape(.rect(cornerRadius: cornerRadius, style: corners.style))
                } else {
                    layer
                }
            }
            .overlay(
                Group {
                    #if DEBUG
                    if debugOverlaysEnabled {
                        DebugOverlayIndicator("Portal Layer", color: .green)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(5)
                    }
                    #endif
                }
            )
            .frame(width: width, height: height)
            .offset(x: x, y: y)
            .transition(.identity)  // Prevents additional SwiftUI transitions
        }
    }
}
