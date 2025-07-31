#if DEBUG
import SwiftUI

let portal_animationDuration: TimeInterval = 0.4
let portal_animationExample: Animation = Animation.smooth(duration: portal_animationDuration, extraBounce: 0.25)
let portal_animationExampleExtraBounce: Animation = Animation.smooth(duration: portal_animationDuration + 0.12, extraBounce: 0.55)

/// A reusable animated layer component for Portal examples.
/// Provides visual feedback during portal transitions with a scale animation.
@available(iOS 15.0, *)
struct AnimatedLayer<Content: View>: View {
    let id: String
    var scale: CGFloat = 1.25
    @ViewBuilder let content: () -> Content
    
    @State private var layerScale: CGFloat = 1
    
    var body: some View {
        if #available(iOS 17.0, *) {
            AnimatedLayerModern(id: id, scale: scale, content: content, layerScale: $layerScale)
        } else {
            AnimatedLayerLegacy(id: id, scale: scale, content: content, layerScale: $layerScale)
        }
    }
}



@available(iOS 17.0, *)
private struct AnimatedLayerModern<Content: View>: View {
    @Environment(CrossModel.self) private var portalModel
    let id: String
    var scale: CGFloat = 1.25
    @ViewBuilder let content: () -> Content
    @Binding var layerScale: CGFloat
    
    var body: some View {
        let idx = portalModel.info.firstIndex { $0.infoID == id }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false
        
        content()
            .scaleEffect(layerScale)
            .onAppear {
                layerScale = 1
            }
            .onChange(of: isActive) { oldValue, newValue in
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
                    withAnimation {
                        layerScale = 1
                    }
                }
            }
    }
}

@available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
private struct AnimatedLayerLegacy<Content: View>: View {
    @EnvironmentObject private var portalModel: CrossModelLegacy
    let id: String
    var scale: CGFloat = 1.25
    @ViewBuilder let content: () -> Content
    @Binding var layerScale: CGFloat
    
    var body: some View {
        let idx = portalModel.info.firstIndex { $0.infoID == id }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false
        
        content()
            .scaleEffect(layerScale)
            .onAppear {
                layerScale = 1
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        layerScale = scale
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            layerScale = 1
                        }
                    }
                } else {
                    withAnimation {
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
