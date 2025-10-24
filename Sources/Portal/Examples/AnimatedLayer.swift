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

let portal_animationDuration: TimeInterval = 0.4
let portal_animationExample = Animation.smooth(duration: portal_animationDuration, extraBounce: 0.25)
let portal_animationExampleExtraBounce = Animation.smooth(duration: portal_animationDuration + 0.12, extraBounce: 0.55)

/// A reusable animated layer component for Portal examples.
/// Provides visual feedback during portal transitions with a scale animation.
///
/// This is an example implementation using the `AnimatedPortalLayer` protocol.
/// Users can copy and modify this to create their own custom animations.
struct AnimatedLayer<Content: View>: AnimatedPortalLayer {
    let portalID: String
    var scale: CGFloat = 1.25
    @ViewBuilder let content: () -> Content

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
            withAnimation(portal_animationExample) {
                layerScale = scale
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (portal_animationDuration / 2) - 0.1) {
                withAnimation(portal_animationExampleExtraBounce) {
                    layerScale = 1
                }
            }
        } else {
            withAnimation(portal_animationExample) {
                layerScale = scale
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (portal_animationDuration / 2) - 0.1) {
                withAnimation(portal_animationExampleExtraBounce) {
                    layerScale = 1
                }
            }
        }
    }
}

#Preview("Card Grid Example") {
    PortalExample_CardGrid()
}

#endif
