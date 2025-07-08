import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - iOS 17+ Implementation

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
@available(iOS 17.0, *)
public struct PortalContainer<Content: View>: View {
    @ViewBuilder public var content: Content
    @Environment(\.scenePhase) private var scene
    @State private var portalModel = CrossModel()
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
            .onAppear { setupWindow(scene) }
            .onDisappear(perform: OverlayWindowManager.shared.removeOverlayWindow)
            .onChange(of: scene) { _, new in setupWindow (new) }
            .environment(portalModel)
    }
    
    private func setupWindow(_ scenePhase: ScenePhase) {
#if canImport(UIKit)
        if scenePhase == .active {
//            print("add overlay")
            OverlayWindowManager.shared.addOverlayWindow(with: portalModel, hideStatusBar: hideStatusBar)
        } else {
//            print("remove overlay")
            OverlayWindowManager.shared.removeOverlayWindow()
        }
#endif
    }
}

// MARK: - iOS 15+ Fallback Implementation

/// iOS 15 compatible version of PortalContainer using StateObject and EnvironmentObject.
///
/// This fallback implementation provides the same functionality as the iOS 17 version
/// but uses the traditional StateObject/EnvironmentObject pattern for compatibility with earlier iOS versions.
///
/// - Warning: This implementation is deprecated and will be removed in a future version.
///   Use the iOS 17+ version when possible.
@available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
public struct PortalContainerLegacy<Content: View>: View {
    @ViewBuilder public var content: Content
    @Environment(\.scenePhase) private var scene
    @StateObject private var portalModel = CrossModelLegacy()
    private let hideStatusBar: Bool
    
    /// Creates a new PortalContainerLegacy.
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
            .onAppear { setupWindow(scene) }
            .onDisappear(perform: OverlayWindowManager.shared.removeOverlayWindow)
            .onChange(of: scene) { new in setupWindow(new) }
            .environmentObject(portalModel)
    }
    
    private func setupWindow(_ scenePhase: ScenePhase) {
#if canImport(UIKit)
        if scenePhase == .active {
//            print("add overlay")
            OverlayWindowManager.shared.addOverlayWindowLegacy(with: portalModel, hideStatusBar: hideStatusBar)
        } else {
//            print("remove overlay")
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
    
    @available(iOS 15.0, *)
    @ViewBuilder
    public func portalContainer(hideStatusBar: Bool = true) -> some View {
        if #available(iOS 17.0, *) {
            PortalContainer(hideStatusBar: hideStatusBar) {
                self
            }
        } else {
            PortalContainerLegacy(hideStatusBar: hideStatusBar) {
                self
            }
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
    @available(iOS 17.0, *)
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
                            .environment(portalModel)
                    )
                } else {
                    root = UIHostingController(
                        rootView: PortalLayerView()
                            .environment(portalModel)
                    )
                }
                root.view.backgroundColor = .clear
                root.view.frame = windowScene.screen.bounds
                
                window.rootViewController = root
                guard self.overlayWindow == nil else {
                    
//                        print("overlayWindow populated, return")
                    return }
                self.overlayWindow = window
                break
            }
        }
    }
    
    /// Adds the overlay window to the active scene (iOS 15 compatible version).
    /// - Parameters:
    ///   - portalModel: The shared portal model.
    ///   - hideStatusBar: Whether the overlay should hide the status bar.
    @available(iOS, introduced: 15.0, deprecated: 17.0, message: "Use the iOS 17+ version when possible")
    func addOverlayWindowLegacy(
        with portalModel: CrossModelLegacy,
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
                        rootView: PortalLayerViewLegacy()
                            .environmentObject(portalModel)
                    )
                } else {
                    root = UIHostingController(
                        rootView: PortalLayerViewLegacy()
                            .environmentObject(portalModel)
                    )
                }
                root.view.backgroundColor = .clear
                root.view.frame = windowScene.screen.bounds
                
                window.rootViewController = root
                guard self.overlayWindow == nil else {
                    
//                        print("overlayWindow populated, return")
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
#endif
