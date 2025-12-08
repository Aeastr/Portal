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
import PortalTransitions

// Configuration for animation timing - can be customized via environment or init
struct AnimatedLayerConfig {
    let duration: TimeInterval
    let bounceAnimation: Animation
    let extraBounceAnimation: Animation

    static let `default` = AnimatedLayerConfig()

    init(duration: TimeInterval = 0.4, extraBounce: Double = 0.65, extraBounceDuration: Double = 0.12) {
        self.duration = duration
        self.bounceAnimation = Animation.smooth(duration: duration, extraBounce: extraBounce)
        self.extraBounceAnimation = Animation.smooth(duration: duration + extraBounceDuration, extraBounce: max(0, extraBounce - 0.1))
    }
}

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
    var scale: CGFloat = 2
    var animationConfig: AnimatedLayerConfig = .default
    @ViewBuilder let content: () -> Content

    init<ID: Hashable>(portalID: ID, scale: CGFloat = 2, animationConfig: AnimatedLayerConfig = .default, @ViewBuilder content: @escaping () -> Content) {
        self.portalID = AnyHashable(portalID)
        self.scale = scale
        self.animationConfig = animationConfig
        self.content = content
    }

    @State private var layerScale: CGFloat = 1

    @ViewBuilder
    func animatedContent(isActive: Bool) -> some View {
        content()
//            .background(.red.opacity(0.2))
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
            withAnimation(animationConfig.bounceAnimation) {
                layerScale = scale
            }
            // Timing calculation: Trigger second bounce slightly before halfway point
            // The 0.1 offset is an animation design parameter for this specific bounce choreography,
            // NOT PortalConstants.animationDelay (which is for portal system timing, not animation design)
            DispatchQueue.main.asyncAfter(deadline: .now() + (animationConfig.duration / 2) - 0.1) {
                withAnimation(animationConfig.extraBounceAnimation) {
                    layerScale = 1
                }
            }
        } else {
            withAnimation(animationConfig.bounceAnimation) {
                layerScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (animationConfig.duration / 2) - PortalConstants.animationDelay) {
                withAnimation(animationConfig.extraBounceAnimation) {
                    layerScale = 1
                }
            }
        }
    }
}
#endif
