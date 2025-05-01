import SwiftUI

/// Internal overlay view that renders and animates portal layers
internal struct PortalLayerView: View {
    @EnvironmentObject private var portalModel: CrossModel
    
    let logger = PortalLogging.logger
    
    var body: some View {
        GeometryReader { proxy in
            ForEach($portalModel.info) { $info in
                ZStack {
                    if let source = info.sourceAnchor,
                       let destination = info.destinationAnchor,
                       let layer = info.layerView,
                       !info.hideView {
                        let sRect = proxy[source]
                        let dRect = proxy[destination]
                        let animate = info.animateView
                        let width = animate ? dRect.size.width : sRect.size.width
                        let height = animate ? dRect.size.height : sRect.size.height
                        let x = animate ? dRect.minX : sRect.minX
                        let y = animate ? dRect.minY : sRect.minY
                        
                        layer
                            .frame(width: width, height: height)
                            .offset(x: x, y: y)
                            .transition(.identity)
                    }
                }
                .onChangeCompat(of: info.animateView) { newValue in
                    logger.log("info.animateView changed", level: .debug, tags: [.transitionLayer], metadata: [
                        "animateView" : newValue
                    ])
                    // Delay to allow animation to finish
                    if !newValue {
                        // if NOT animateView
                        DispatchQueue.main.asyncAfter(deadline: .now() + info.animationDuration + 0.2) {
                            info.initalized = false
                            info.layerView = nil
                            info.sourceAnchor = nil
                            info.destinationAnchor = nil
                            info.sourceProgress = 0
                            info.destinationProgress = 0
                            info.completion(false)
                            
                            logger.log("PortalLayerView hide animation completed", level: .debug, tags: [.transitionLayer])
                        }
                    } else {
                        // if animateView
                        DispatchQueue.main.asyncAfter(deadline: .now() + info.animationDuration  + 0.2) {
                            info.hideView = true
                            info.completion(true)
                            
                            logger.log("PortalLayerView show animation completed", level: .debug, tags: [.transitionLayer])
                        }
                    }
                }
            }
        }
    }
}
