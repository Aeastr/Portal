//
//  AnimatedLayer.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

let portalAnimationDuration: TimeInterval = 0.35
let portalAnimationExample = Animation.smooth(duration: portalAnimationDuration, extraBounce: 0.25)
let portalAnimationExampleExtraBounce = Animation.smooth(duration: portalAnimationDuration + 0.12, extraBounce: 0.55)

/// A reusable animated layer component for Portal examples.
/// Provides visual feedback during portal transitions with a scale animation.
///
/// This is an example implementation using the `AnimatedPortalLayer` protocol.
/// Users can copy and modify this to create their own custom animations.
///
/// **Note on timing values:**
/// The timing values in this implementation (0.1, 0.12, etc.) are animation design parameters
/// specific to this bounce effect choreography, NOT system constants. They control when the
/// second bounce animation triggers relative to the first one. When you copy this component,
/// these values are meant to be tuned for your specific animation design.
struct AnimatedLayer<Content: View>: AnimatedPortalLayer {
    let portalID: AnyHashable
    let namespace: Namespace.ID
    var scale: CGFloat = 1.1
    @ViewBuilder let content: () -> Content

    init<ID: Hashable>(portalID: ID, in namespace: Namespace.ID, scale: CGFloat = 1.1, @ViewBuilder content: @escaping () -> Content) {
        self.portalID = AnyHashable(portalID)
        self.namespace = namespace
        self.scale = scale
        self.content = content
    }

    @State private var layerScale: CGFloat = 1

    @ViewBuilder
    func animatedContent(isActive: Bool) -> some View {
        content()
            .scaleEffect(layerScale)
            .onAppear {
                layerScale = 1
            }
            .onChange(of: isActive) { oldValue, newValue in
                handleActiveChange(oldValue: oldValue, newValue: newValue)
            }
    }

    private func handleActiveChange(oldValue: Bool, newValue: Bool) {
        if newValue {
            withAnimation(portalAnimationExample) {
                layerScale = scale
            }
            // Timing calculation: Trigger second bounce slightly before halfway point
            // The 0.1 offset is an animation design parameter for this specific bounce choreography,
            // NOT PortalConstants.animationDelay (which is for portal system timing, not animation design)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(portalAnimationExampleExtraBounce) {
                    layerScale = 1
                }
            }
        } else {
            withAnimation(portalAnimationExample) {
                layerScale = 1.15
            }
            // Same timing calculation for reverse animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(portalAnimationExampleExtraBounce) {
                    layerScale = 1
                }
            }
        }
    }
}

#Preview("Card Grid Example") {
    PortalExampleCardGrid()
}

#endif
