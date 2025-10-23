//
//  PortalPrivate.swift
//  Portal
//
//  Portal transitions using _UIPortalView for true view instance sharing
//

import SwiftUI
import Portal
import PortalView

// MARK: - Extended Portal Info

/// Extended portal info that includes the source container for view mirroring
@MainActor
public class PortalPrivateInfo {
    /// The source view container holding the UIHostingController
    public var sourceContainer: AnyObject? = nil

    /// Whether the portal is using private implementation
    public var isPrivatePortal: Bool = false
}

// MARK: - Storage for Private Portal Info

@MainActor
private class PortalPrivateStorage {
    static let shared = PortalPrivateStorage()
    var privateInfo: [String: PortalPrivateInfo] = [:]

    private init() {}
}

// MARK: - PortalPrivate View Wrapper

/// A view that manages a single SwiftUI view instance that can be shown in multiple places
public struct PortalPrivate<Content: View>: View {
    private let id: String
    @ViewBuilder private let content: () -> Content
    @State private var sourceContainer: SourceViewContainer<AnyView>?
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalDebugOverlays) private var debugOverlaysEnabled

    public init(id: String, @ViewBuilder content: @escaping () -> Content) {
        self.id = id
        self.content = content
    }

    public var body: some View {
        Group {
            // Create and store the source container on appear
            Color.clear
                .frame(width: 0, height: 0)
                .onAppear {
                    if sourceContainer == nil {
                        print("🟣 PortalPrivate: Creating container for id: \(id)")
                        // Create type-erased container that can be shared
                        let container = SourceViewContainer(content: AnyView(content()))
                        sourceContainer = container

                        // Store in private storage
                        let info = PortalPrivateInfo()
                        info.sourceContainer = container
                        info.isPrivatePortal = true
                        PortalPrivateStorage.shared.privateInfo[id] = info
                        print("🟣 PortalPrivate: Stored container in storage for id: \(id)")

                        // Ensure portal info exists in model
                        if !portalModel.info.contains(where: { $0.infoID == id }) {
                            portalModel.info.append(PortalInfo(id: id))
                            print("🟣 PortalPrivate: Added PortalInfo for id: \(id)")
                        }
                    }
                }
                .onDisappear {
                    // Clean up
                    PortalPrivateStorage.shared.privateInfo[id] = nil
                }

            // The actual source view (always visible)
            if let container = sourceContainer {
                SourceViewRepresentable(
                    container: container,
                    content: AnyView(content())
                )
                .overlay(
                    Group {
                        #if DEBUG
                        if debugOverlaysEnabled {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.purple, lineWidth: 2)
                                .overlay(
                                    DebugOverlayIndicator("PortalPrivate", color: .purple)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                        .padding(5)
                                )
                        }
                        #endif
                    }
                )
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    [id: anchor]
                }
                .onPreferenceChange(AnchorKey.self) { prefs in
                    Task { @MainActor in
                        guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else {
                            print("🟡 PortalPrivate source: No PortalInfo found for id: \(id)")
                            return
                        }

                        // Don't require initialized - we need to set anchor even before transition
                        guard let anchor = prefs[id] else {
                            print("🟡 PortalPrivate source: No anchor in prefs for id: \(id)")
                            return
                        }

                        // Update source anchor for positioning
                        portalModel.info[idx].sourceAnchor = anchor
                        print("🟣 PortalPrivate source: Set source anchor for id: \(id)")
                    }
                }
            }
        }
    }
}

// MARK: - Modified Portal Container

/// Extended portal container that includes PortalPrivate support
public struct PortalContainerPrivate<Content: View>: View {
    @ViewBuilder public var content: Content
    @Environment(\.scenePhase) private var scene
    @State private var portalModel = CrossModel()
    private let hideStatusBar: Bool

    public init(
        hideStatusBar: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.hideStatusBar = hideStatusBar
        self.content = content()
    }

    public var body: some View {
        // Use standard PortalContainer which creates the overlay window
        PortalContainer(hideStatusBar: hideStatusBar, portalModel: portalModel) {
            content
        }
    }
}

// MARK: - View Extensions

public extension View {
    /// Marks this view as a private portal that uses view mirroring
    ///
    /// Unlike regular portals, this creates a single view instance that can be
    /// displayed in multiple places using _UIPortalView.
    ///
    /// Example:
    /// ```swift
    /// MyComplexView()
    ///     .portalPrivate(id: "myView")
    /// ```
    func portalPrivate<Content: View>(
        id: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            PortalPrivate(id: id, content: content)
        )
    }

    /// Simplified portal private for when the view itself should be mirrored
    func portalPrivate(id: String) -> some View {
        PortalPrivate(id: id) {
            self
        }
    }

    /// Triggers a portal transition for a private portal using the mirrored view
    ///
    /// This modifier triggers the animation for PortalPrivate views.
    /// Unlike regular `.portalTransition`, you don't provide a layer view
    /// since it uses the _UIPortalView mirror of the source.
    ///
    /// Example:
    /// ```swift
    /// .portalPrivateTransition(
    ///     id: "myView",
    ///     isActive: $showDetail
    /// )
    /// ```
    func portalPrivateTransition(
        id: String,
        config: PortalTransitionConfig = .init(),
        isActive: Binding<Bool>,
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateTransitionModifier(
                id: id,
                config: config,
                isActive: isActive,
                completion: completion
            )
        )
    }

    /// Triggers a portal transition for a private portal with an optional item
    func portalPrivateTransition<Item: Identifiable>(
        item: Binding<Item?>,
        config: PortalTransitionConfig = .init(),
        completion: @escaping (Bool) -> Void = { _ in }
    ) -> some View {
        self.modifier(
            PortalPrivateItemTransitionModifier(
                item: item,
                config: config,
                completion: completion
            )
        )
    }
}

// MARK: - Transition Modifiers

/// Transition modifier for private portals with boolean state
struct PortalPrivateTransitionModifier: ViewModifier {
    let id: String
    let config: PortalTransitionConfig
    @Binding var isActive: Bool
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel

    func body(content: Content) -> some View {
        content
            .onChange(of: isActive) { _, newValue in
                guard let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) else { return }

                // Initialize portal info
                portalModel.info[idx].initalized = true
                portalModel.info[idx].animation = config.animation
                portalModel.info[idx].corners = config.corners
                portalModel.info[idx].completion = completion

                // For PortalPrivate, we don't set layerView - the layer uses the stored container

                if newValue {
                    // Forward transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                        config.animation.performAnimation({
                            portalModel.info[idx].animateView = true
                        }) {
                            portalModel.info[idx].hideView = true
                            portalModel.info[idx].completion(true)
                        }
                    }
                } else {
                    // Reverse transition
                    portalModel.info[idx].hideView = false

                    config.animation.performAnimation({
                        portalModel.info[idx].animateView = false
                    }) {
                        portalModel.info[idx].initalized = false
                        portalModel.info[idx].sourceAnchor = nil
                        portalModel.info[idx].destinationAnchor = nil
                        portalModel.info[idx].completion(false)
                    }
                }
            }
    }
}

/// Transition modifier for private portals with optional item
struct PortalPrivateItemTransitionModifier<Item: Identifiable>: ViewModifier {
    @Binding var item: Item?
    let config: PortalTransitionConfig
    let completion: (Bool) -> Void
    @Environment(CrossModel.self) private var portalModel
    @State private var lastKey: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: item != nil) { _, hasValue in
                if hasValue {
                    guard let item = item else { return }
                    // Use the same ID format as the source and destination
                    let key: String
                    if let uuid = item.id as? UUID {
                        key = uuid.uuidString
                    } else {
                        key = "\(item.id)"
                    }
                    lastKey = key
                    print("🔵 PortalPrivateTransition: Starting transition for key: \(key)")

                    // Ensure portal info exists
                    if portalModel.info.firstIndex(where: { $0.infoID == key }) == nil {
                        portalModel.info.append(PortalInfo(id: key))
                        print("🔵 PortalPrivateTransition: Added PortalInfo for key: \(key)")
                    }

                    guard let idx = portalModel.info.firstIndex(where: { $0.infoID == key }) else {
                        print("🔴 PortalPrivateTransition: Could not find PortalInfo for key: \(key)")
                        return
                    }

                    // Initialize portal info
                    portalModel.info[idx].initalized = true
                    portalModel.info[idx].animation = config.animation
                    portalModel.info[idx].corners = config.corners
                    portalModel.info[idx].completion = completion
                    print("🔵 PortalPrivateTransition: Initialized PortalInfo for key: \(key)")

                    // Set the layer view to use the PortalView of the stored container
                    if let privateInfo = PortalPrivateStorage.shared.privateInfo[key],
                       let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView> {
                        print("🔵 PortalPrivateTransition: Found container in storage for key: \(key)")
                        // Create a portal view that will be animated
                        portalModel.info[idx].layerView = AnyView(
                            PortalView(
                                source: container,
                                hidesSource: false,  // Don't hide source during animation
                                matchesAlpha: true,
                                matchesTransform: false,
                                matchesPosition: false
                            )
                        )
                        print("🔵 PortalPrivateTransition: Set layerView for key: \(key)")
                    } else {
                        print("🔴 PortalPrivateTransition: No container found in storage for key: \(key)")
                        print("🔴 Available keys in storage: \(PortalPrivateStorage.shared.privateInfo.keys)")
                    }

                    // Check anchors
                    if let sourceAnchor = portalModel.info[idx].sourceAnchor {
                        print("🔵 PortalPrivateTransition: Source anchor exists for key: \(key)")
                    } else {
                        print("🟡 PortalPrivateTransition: No source anchor for key: \(key)")
                    }

                    if let destAnchor = portalModel.info[idx].destinationAnchor {
                        print("🔵 PortalPrivateTransition: Destination anchor exists for key: \(key)")
                    } else {
                        print("🟡 PortalPrivateTransition: No destination anchor for key: \(key)")
                    }

                    // Forward transition
                    print("🔵 PortalPrivateTransition: Starting animation with delay: \(config.animation.delay)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.animation.delay) {
                        print("🔵 PortalPrivateTransition: Setting animateView = true for key: \(key)")
                        config.animation.performAnimation({
                            portalModel.info[idx].animateView = true
                        }) {
                            print("🔵 PortalPrivateTransition: Animation complete, hiding view for key: \(key)")
                            portalModel.info[idx].hideView = true
                            portalModel.info[idx].completion(true)
                        }
                    }

                } else {
                    // Reverse transition
                    guard let key = lastKey,
                          let idx = portalModel.info.firstIndex(where: { $0.infoID == key })
                    else {
                        print("🔴 PortalPrivateTransition: Reverse - no key or index")
                        return
                    }
                    print("🔵 PortalPrivateTransition: Starting reverse transition for key: \(key)")

                    portalModel.info[idx].hideView = false

                    config.animation.performAnimation({
                        portalModel.info[idx].animateView = false
                    }) {
                        portalModel.info[idx].initalized = false
                        portalModel.info[idx].sourceAnchor = nil
                        portalModel.info[idx].destinationAnchor = nil
                        portalModel.info[idx].completion(false)
                    }

                    lastKey = nil
                }
            }
    }
}

// MARK: - Destination View for Private Portals

/// A destination view that shows a portal of the private source
public struct PortalPrivateDestination: View {
    let id: String
    @Environment(CrossModel.self) private var portalModel
    @Environment(\.portalDebugOverlays) private var debugOverlaysEnabled

    public init(id: String) {
        self.id = id
    }

    public var body: some View {
        Group {
            if let privateInfo = PortalPrivateStorage.shared.privateInfo[id],
               let container = privateInfo.sourceContainer as? SourceViewContainer<AnyView>,
               let idx = portalModel.info.firstIndex(where: { $0.infoID == id }) {

                let info = portalModel.info[idx]
                // Destination should be visible after animation completes (opposite of hideView)
                let opacity = info.hideView ? 1 : 0

                // Show portal of the source
                PortalView(
                    source: container,
                    hidesSource: false,
                    matchesAlpha: true,
                    matchesTransform: true,
                    matchesPosition: false
                )
                .opacity(Double(opacity))
                .onAppear {
                    print("🟢 PortalPrivateDestination appeared for id: \(id)")
                    print("🟢 - animateView: \(info.animateView), hideView: \(info.hideView)")
                    print("🟢 - opacity: \(opacity)")
                }
                .overlay(
                    Group {
                        #if DEBUG
                        if debugOverlaysEnabled {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                                .overlay(
                                    DebugOverlayIndicator("PortalPrivate Dest", color: .purple)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                        .padding(5)
                                )
                        }
                        #endif
                    }
                )
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    ["\(id)DEST": anchor]
                }
                .onPreferenceChange(AnchorKey.self) { prefs in
                    Task { @MainActor in
                        // Don't require initialized - we need to set anchor even before transition
                        guard let anchor = prefs["\(id)DEST"] else {
                            print("🟡 PortalPrivateDestination: No anchor in prefs for id: \(id)DEST")
                            return
                        }

                        // Update destination anchor for positioning
                        portalModel.info[idx].destinationAnchor = anchor
                        print("🟢 PortalPrivateDestination: Set destination anchor for id: \(id)")
                    }
                }
            } else {
                // Placeholder when source not available
                Color.clear
                    .onAppear {
                        print("🔴 PortalPrivateDestination: Missing container for id: \(id)")
                        print("🔴 - Storage keys: \(PortalPrivateStorage.shared.privateInfo.keys)")
                        if let info = PortalPrivateStorage.shared.privateInfo[id] {
                            print("🔴 - Info exists, container: \(info.sourceContainer != nil)")
                        }
                    }
                    .overlay(
                        Group {
                            #if DEBUG
                            if debugOverlaysEnabled {
                                Text("Awaiting PortalPrivate: \(id)")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                            #endif
                        }
                    )
            }
        }
    }
}

// MARK: - Debug Overlay (Reuse from Portal)

#if DEBUG
/// Debug indicator view to visualize portal elements
internal struct DebugOverlayIndicator: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = .pink) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 3)
            .padding(6)
            .background(color.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(.capsule)
            .foregroundStyle(.white)
            .allowsHitTesting(false)
    }
}
#endif
