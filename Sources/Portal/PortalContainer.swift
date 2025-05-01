import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import LogOutLoud

/// A SwiftUI container that overlays a transparent window above your app's UI,
/// optionally hiding the status bar in the overlay.
///
/// Use this to inject a portal layer for cross-view communication or overlays.
/// The overlay is managed automatically as the app's scene becomes active/inactive.
///
/// - Parameters:
///   - hideStatusBar: Whether the overlay should hide the status bar. Default is `true`.
///   - content: The main content of your view hierarchy.
/// - Example:
/// ```swift
/// PortalContainer(hideStatusBar: false) {
///     MyMainView()
/// }
/// ```
public struct PortalContainer<Content: View>: View {
    @ViewBuilder public var content: Content
    @Environment(\.scenePhase) private var scene
    @StateObject private var portalModel = CrossModel()
    private let hideStatusBar: Bool
    
    /// Creates a new PortalContainer.
    /// - Parameters:
    ///   - hideStatusBar: Whether the overlay should hide the status bar.
    ///   - content: The main content view.
    
    public init(
        hideStatusBar: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.hideStatusBar = hideStatusBar
        self.content = content()
    }
    
    public var body: some View {
        content
            .onAppear {
                setupWindow(scene)
            }
            .onDisappear() {
                OverlayWindowManager.shared.removeOverlayWindow()
            }
            .onChangeCompat(of: scene) { newValue in
                setupWindow(newValue)
            }
            .environmentObject(portalModel)
    }
    
    private func setupWindow(_ scenePhase: ScenePhase) {
#if canImport(UIKit)
        if scenePhase == .active {
            print("add overlay")
            OverlayWindowManager.shared.addOverlayWindow(
                with: portalModel,
                hideStatusBar: hideStatusBar
            )
        } else {
            print("remove overlay")
            OverlayWindowManager.shared.removeOverlayWindow()
        }
#endif
    }
}

/// Adds a portal container overlay to the view, optionally hiding the status bar.
///
/// - Parameter hideStatusBar: Whether the overlay should hide the status bar. Default is `true`.
/// - Returns: A view wrapped in a `PortalContainer`.
/// - Example:
/// ```swift
/// MyView()
///     .portalContainer(hideStatusBar: false)
/// ```
extension View {
    
    @ViewBuilder
    public func portalContainer(hideStatusBar: Bool = true) -> some View {
        PortalContainer(hideStatusBar: hideStatusBar) {
            self
        }
    }
}

#if canImport(UIKit)
import UIKit

/// Manages the overlay window for the portal layer.
@MainActor
final class OverlayWindowManager {
    static let shared = OverlayWindowManager()
    private var overlayWindow: PassThroughWindow?
    
    /// Adds the overlay window to the active scene.
    /// - Parameters:
    ///   - portalModel: The shared portal model.
    ///   - hideStatusBar: Whether the overlay should hide the status bar.
    func addOverlayWindow(
        with portalModel: CrossModel,
        hideStatusBar: Bool
    ) {
        guard overlayWindow == nil else { return }
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene,
                      scene.activationState == .foregroundActive else { continue }
                
                let window = PassThroughWindow(windowScene: windowScene)
                window.backgroundColor = .clear
                window.isUserInteractionEnabled = false
                window.isHidden = false
                
                let root: UIViewController
                if hideStatusBar {
                    root = HiddenStatusHostingController(
                        rootView: PortalLayerView()
                            .environmentObject(portalModel)
                    )
                } else {
                    root = UIHostingController(
                        rootView: PortalLayerView()
                            .environmentObject(portalModel)
                    )
                }
                root.view.backgroundColor = .clear
                root.view.frame = windowScene.screen.bounds
                
                window.rootViewController = root
                guard self.overlayWindow == nil else {
                    
                        print("overlayWindow populated, return")
                    return }
                self.overlayWindow = window
                break
            }
        }
    }
    
    /// Removes the overlay window from the scene.
    func removeOverlayWindow() {
        DispatchQueue.main.async {
            self.overlayWindow?.isHidden = true
            self.overlayWindow = nil
        }
    }
}

/// A HostingController that always hides the status bar.
final class HiddenStatusHostingController<Content: View>: UIHostingController<Content> {
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
}
#endif
