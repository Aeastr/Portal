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
import Portal

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
struct AnimatedLayer<Content: View>: AnimatedPortalLayer {
    let portalID: String
    var scale: CGFloat = 2
    var animationConfig: AnimatedLayerConfig = .default
    @ViewBuilder let content: () -> Content

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
            DispatchQueue.main.asyncAfter(deadline: .now() + (animationConfig.duration / 2) - 0.1) {
                withAnimation(animationConfig.extraBounceAnimation) {
                    layerScale = 1
                }
            }
        } else {
            withAnimation(animationConfig.bounceAnimation) {
                layerScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (animationConfig.duration / 2) - 0.1) {
                withAnimation(animationConfig.extraBounceAnimation) {
                    layerScale = 1
                }
            }
        }
    }
}
#endif
