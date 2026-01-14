//
//  PortalContainer.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif


/// A SwiftUI container that overlays a transparent window above your app's UI,
/// optionally hiding the status bar in the overlay.
///
/// Use this to inject a portal layer for cross-view communication or overlays.
/// The overlay is managed automatically as the app's scene becomes active/inactive.
///
/// - Parameters:
///   - hideStatusBar: Whether the overlay should hide the status bar. Default is `false`.
///   - content: The main content of your view hierarchy.
/// Prefer using `PortalContainer` unless you specifically need to reference the modern-only
/// implementation (e.g. for conditional compilation).
public struct PortalContainerModern<Content: View>: View {
    @ViewBuilder public var content: Content
    @Environment(\.scenePhase) private var scene
    @Environment(\.portalTransitionDebugSettings) private var debugSettings
    // The @State property will no longer have an initial value directly here.
    // Its initial value will be set in the initializer.
    @State private var portalModel: CrossModel

    private let hideStatusBar: Bool

    /// Initializes a `PortalContainerModern` with optional custom settings.
    /// - Parameters:
    ///   - hideStatusBar: A boolean indicating whether the status bar should be hidden. Defaults to `false`.
    ///   - portalModel: An optional `CrossModel` to use. If `nil`, a default `CrossModel()` is created.
    ///   - content: The content view builder for the container.
    public init(
        hideStatusBar: Bool = false,
        portalModel: CrossModel? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.hideStatusBar = hideStatusBar
        // Initialize the @State property using its special initializer syntax.
        // If portalModel is nil, use a default CrossModel instance.
        _portalModel = State(initialValue: portalModel ?? CrossModel())
        self.content = content()
    }

    public var body: some View {
        content
            .onAppear { setupWindow(scene) }
            .onDisappear { teardownWindow() }
            .onChange(of: scene) { _, new in setupWindow(new) }
            .environment(portalModel)
    }

    private func teardownWindow() {
#if canImport(UIKit)
        OverlayWindowManager.shared.removeOverlayWindow(for: portalModel)
#endif
    }

    private func setupWindow(_ scenePhase: ScenePhase) {
#if canImport(UIKit)
        if scenePhase == .active {
            PortalLogs.logger.log(
                "Activating portal overlay window",
                level: .notice,
                tags: [PortalLogs.Tags.container],
                metadata: ["scenePhase": "active"]
            )
            OverlayWindowManager.shared.addOverlayWindow(with: portalModel, hideStatusBar: hideStatusBar, debugSettings: debugSettings)
        } else {
            PortalLogs.logger.log(
                "Scene no longer active; unregistering portal model",
                level: .notice,
                tags: [PortalLogs.Tags.container],
                metadata: ["scenePhase": String(reflecting: scenePhase)]
            )
            OverlayWindowManager.shared.removeOverlayWindow(for: portalModel)
        }
#endif
    }
}

// MARK: - Public Container Wrapper

/// Type-erased portal container that automatically selects the appropriate implementation
/// for the current OS version. Use this at the root of your app (e.g. in your `Scene` or
/// `App` entry point) to install the portal layer once.
public struct PortalContainer<Content: View>: View {
    private let hideStatusBar: Bool
    private let modernPortalModelBox: Any?
    private let content: () -> Content

    public init(
        hideStatusBar: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hideStatusBar = hideStatusBar
        self.content = content
        self.modernPortalModelBox = nil
    }

    public var body: some View {
        PortalContainerModern(
            hideStatusBar: hideStatusBar,
            portalModel: modernPortalModelBox as? CrossModel,
            content: content
        )
    }
}

public extension PortalContainer {
    init(
        hideStatusBar: Bool = false,
        portalModel: CrossModel? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hideStatusBar = hideStatusBar
        self.content = content
        self.modernPortalModelBox = portalModel
    }
}

#if canImport(UIKit)
import UIKit

// MARK: - Portal Model Registry

/// Observable registry that tracks all active CrossModels from multiple PortalContainers.
///
/// This allows multiple PortalContainers to coexist (e.g., in a carousel where each page
/// has its own container). Each container registers its model, and the overlay window
/// renders portals from all registered models.
@MainActor @Observable
final class PortalModelRegistry {
    /// All currently registered portal models, keyed by their object identity.
    var models: [ObjectIdentifier: CrossModel] = [:]

    /// Registers a portal model with the registry.
    /// - Parameter model: The CrossModel to register.
    func register(_ model: CrossModel) {
        let id = ObjectIdentifier(model)
        guard models[id] == nil else { return }
        models[id] = model
        PortalLogs.logger.log(
            "Registered portal model",
            level: .debug,
            tags: [PortalLogs.Tags.container],
            metadata: ["modelCount": models.count]
        )
    }

    /// Unregisters a portal model from the registry.
    /// - Parameter model: The CrossModel to unregister.
    func unregister(_ model: CrossModel) {
        let id = ObjectIdentifier(model)
        guard models[id] != nil else { return }
        models.removeValue(forKey: id)
        PortalLogs.logger.log(
            "Unregistered portal model",
            level: .debug,
            tags: [PortalLogs.Tags.container],
            metadata: ["modelCount": models.count]
        )
    }

    /// Whether any models are currently registered.
    var isEmpty: Bool { models.isEmpty }
}

/// Manages the overlay window for the portal layer.
@MainActor
final class OverlayWindowManager {
    static let shared = OverlayWindowManager()
    private var overlayWindow: PassThroughWindow?

    /// Registry of all active portal models from all containers.
    let registry = PortalModelRegistry()

    /// Registers a portal model and ensures the overlay window exists.
    /// - Parameters:
    ///   - portalModel: The portal model to register.
    ///   - hideStatusBar: Whether the overlay should hide the status bar.
    ///   - debugSettings: Debug overlay settings.
    func addOverlayWindow(
        with portalModel: CrossModel,
        hideStatusBar: Bool,
        debugSettings: PortalTransitionDebugSettings
    ) {
        // Always register the model
        registry.register(portalModel)

        // Only create window if it doesn't exist
        guard overlayWindow == nil else {
            PortalLogs.logger.log(
                "Overlay window already installed; registered model to existing window",
                level: .notice,
                tags: [PortalLogs.Tags.overlay],
                metadata: ["modelCount": registry.models.count]
            )
            return
        }
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene,
                      scene.activationState == .foregroundActive else { continue }

                PortalLogs.logger.log(
                    "Installing overlay window",
                    level: .info,
                    tags: [PortalLogs.Tags.overlay],
                    metadata: [
                        "hideStatusBar": hideStatusBar,
                        "scene": windowScene.session.persistentIdentifier
                    ]
                )

                let window = PassThroughWindow(windowScene: windowScene)
                window.backgroundColor = .clear
                window.isUserInteractionEnabled = false
                window.isHidden = false

                let root: UIViewController
                if hideStatusBar {
                    root = HiddenStatusHostingController(
                        rootView: PortalContainerRootView(registry: self.registry, debugSettings: debugSettings)
                    )
                } else {
                    root = UIHostingController(
                        rootView: PortalContainerRootView(registry: self.registry, debugSettings: debugSettings)
                    )
                }
                root.view.backgroundColor = .clear
                root.view.frame = windowScene.screen.bounds

                window.rootViewController = root
                guard self.overlayWindow == nil else {
                    PortalLogs.logger.log(
                        "Overlay window became populated while configuring; aborting new instance",
                        level: .warning,
                        tags: [PortalLogs.Tags.overlay]
                    )
                    return }
                self.overlayWindow = window
                PortalLogs.logger.log(
                    "Overlay window installed",
                    level: .notice,
                    tags: [PortalLogs.Tags.overlay]
                )
                break
            }

            if self.overlayWindow == nil {
                PortalLogs.logger.log(
                    "Unable to find active foreground scene for portal overlay",
                    level: .warning,
                    tags: [PortalLogs.Tags.overlay]
                )
            }
        }
    }

    /// Unregisters a portal model and removes the overlay window if no models remain.
    /// - Parameter portalModel: The portal model to unregister.
    func removeOverlayWindow(for portalModel: CrossModel) {
        registry.unregister(portalModel)

        // Only remove window if no models remain
        guard registry.isEmpty else {
            PortalLogs.logger.log(
                "Unregistered model; other models still active",
                level: .debug,
                tags: [PortalLogs.Tags.overlay],
                metadata: ["modelCount": registry.models.count]
            )
            return
        }

        DispatchQueue.main.async {
            guard let overlayWindow = self.overlayWindow else {
                PortalLogs.logger.log(
                    "Requested overlay removal but no window was active",
                    level: .debug,
                    tags: [PortalLogs.Tags.overlay]
                )
                return
            }

            PortalLogs.logger.log(
                "Removing overlay window (no models remaining)",
                level: .info,
                tags: [PortalLogs.Tags.overlay]
            )

            overlayWindow.isHidden = true
            self.overlayWindow = nil
        }
    }

    /// Removes the overlay window from the scene (legacy method for compatibility).
    @available(*, deprecated, message: "Use removeOverlayWindow(for:) instead")
    func removeOverlayWindow() {
        DispatchQueue.main.async {
            guard let overlayWindow = self.overlayWindow else {
                PortalLogs.logger.log(
                    "Requested overlay removal but no window was active",
                    level: .debug,
                    tags: [PortalLogs.Tags.overlay]
                )
                return
            }

            PortalLogs.logger.log(
                "Removing overlay window (legacy call)",
                level: .info,
                tags: [PortalLogs.Tags.overlay]
            )

            overlayWindow.isHidden = true
            self.overlayWindow = nil
        }
    }
}

#if DEBUG
/// Debug indicator view to visualize overlay window presence
internal struct DebugOverlayIndicator: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = .pink) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Text(text)
                    .font(.caption2)
                    .padding(.horizontal, 3)
                    .padding(6)
                    .glassEffect(.regular.tint(color.opacity(0.6)))
                    .foregroundStyle(.white)
            } else {
                Text(text)
                    .font(.caption2)
                    .padding(.horizontal, 3)
                    .padding(6)
                    .background(color.opacity(0.6))
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    .foregroundStyle(.white)
            }
        }
        .allowsHitTesting(false)
    }
}

/// Complete debug overlay component with border, label, and background
internal struct PortalDebugOverlay: View {
    let text: String
    let color: Color
    let style: PortalTransitionDebugStyle

    init(_ text: String, color: Color, showing style: PortalTransitionDebugStyle) {
        self.text = text
        self.color = color
        self.style = style
    }

    var body: some View {
        Group {
            if style.contains(.background) {
                color.opacity(0.1)
            }

            if style.contains(.border) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 2)
            }

            if style.contains(.label) {
                DebugOverlayIndicator(text, color: color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(5)
            }
        }
    }
}

#Preview{
    DebugOverlayIndicator("PortalContainerOverlay")
        .padding(20)
        .ignoresSafeArea()
}
#endif

// MARK: - Root Views

private struct PortalContainerRootView: View {
    let registry: PortalModelRegistry
    let debugSettings: PortalTransitionDebugSettings

    var body: some View {
        ZStack {
            // Render portal layers for all registered models
            ForEach(Array(registry.models.values), id: \.id) { model in
                PortalLayerView()
                    .environment(model)
            }
            .portalTransitionDebugOverlays(debugSettings.style(for: .layer), for: .layer)
            #if DEBUG
            let layerStyle = debugSettings.style(for: .layer)
            if !layerStyle.isEmpty {
                DebugOverlayIndicator("PortalContainerOverlay (\(registry.models.count))")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(20)
                    .ignoresSafeArea()
            }
            #endif
        }
    }
}

#endif
