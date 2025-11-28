//
//  PortalHeaderView.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A header view that smoothly transitions to the navigation bar during scroll.
///
/// `PortalHeaderView` reads its configuration from the environment, set by the
/// `.portalHeader()` modifier applied to the parent NavigationStack.
///
/// ## Basic Usage
///
/// ```swift
/// NavigationStack {
///     ScrollView {
///         PortalHeaderView()
///     }
///     .portalHeaderDestination()
/// }
/// .portalHeader(title: "Favorites", subtitle: "Your starred items")
/// ```
///
/// ## With Accessory
///
/// ```swift
/// NavigationStack {
///     ScrollView {
///         PortalHeaderView()
///     }
///     .portalHeaderDestination(displays: [.title, .accessory])
/// }
/// .portalHeader(
///     title: "Profile",
///     subtitle: "Account settings",
///     displays: [.title, .accessory]
/// ) {
///     Image(systemName: "person.circle")
///         .font(.system(size: 64))
/// }
/// ```
///
/// - Important: This view is only available on iOS 18.0 and later due to its use of
///   advanced scroll tracking APIs.
@available(iOS 18.0, *)
public struct PortalHeaderView: View {
    // Note: We intentionally do NOT read titleProgress here.
    // Reading titleProgress would cause this view to re-render on every scroll frame,
    // which creates significant lag. Instead, the fade effect is applied in the overlay's
    // renderAccessory function, which already re-renders per-frame anyway.
    @Environment(\.portalHeaderContent) private var config
    @Environment(\.portalHeaderAccessoryView) private var accessoryView
    @Environment(\.accessoryFlowing) private var accessoryFlowing
    @Environment(\.portalHeaderDebugOverlays) private var debugOverlaysEnabled

    private let id: String
    private let visibleComponents: Set<PortalHeaderDisplayComponent>?

    /// Creates a flowing header that reads configuration from environment.
    ///
    /// - Parameters:
    ///   - id: Optional identifier to match specific header config (default: "default")
    ///   - displays: Optional override for which components to show in the header (default: shows all)
    public init(id: String = "default", displays: Set<PortalHeaderDisplayComponent>? = nil) {
        self.id = id
        self.visibleComponents = displays
    }

    public var body: some View {
        Group {
            if let config = config, config.id == id {
                headerContent(config: config)
            } else {
                // Fallback when no config is provided
                Text("No flowing header configuration found (expected id: \"\(id)\")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func headerContent(config: PortalHeaderContent) -> some View {
        // visibleComponents controls what shows in the header
        // config.displays controls what flows to nav bar (creates anchors)
        let showComponents = visibleComponents ?? [.title, .accessory]  // Default: show everything
        let flowComponents = config.displays  // What flows to nav bar

        let showAccessory = showComponents.contains(.accessory) && accessoryView != nil
        let showTitle = showComponents.contains(.title)
        let createAccessoryAnchor = flowComponents.contains(.accessory) && accessoryView != nil
        let createTitleAnchor = flowComponents.contains(.title)

        VStack(spacing: showAccessory ? 12 : 8) {
            // Show accessory if in visibleComponents
            // Source is always invisible (opacity: 0) - it only provides layout and anchor.
            // The overlay's renderAccessory handles the actual visible rendering with fade/position.
            // This avoids re-rendering PortalHeaderView on every scroll frame.
            if showAccessory, let accessoryView = accessoryView {
                if createAccessoryAnchor {
                    accessoryView
                        .opacity(0)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: AccessorySourceHeightKey.self,
                                    value: geo.size.height
                                )
                            }
                        )
                        .overlay(
                            Group {
                                #if DEBUG
                                PortalHeaderDebugOverlay("Source", color: .blue, showing: debugOverlaysEnabled)
                                #endif
                            }
                        )
                        .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                            return [AnchorKeyID(kind: "source", id: config.id, type: "accessory"): anchor]
                        }
                } else {
                    // Not flowing - just show the accessory normally (no transition)
                    accessoryView
                }
            }

            VStack(spacing: 4) {
                // Source title (invisible for layout, only create anchor if flowing)
                if showTitle {
                    if createTitleAnchor {
                        Text(config.title)
                            .font(.title.weight(.semibold))
                            .opacity(0)  // Always invisible to maintain layout
                            .accessibilityHidden(true)  // Hide from VoiceOver since actual title is rendered separately
                            .overlay(
                                Group {
                                    #if DEBUG
                                    PortalHeaderDebugOverlay("Source", color: .blue, showing: debugOverlaysEnabled)
                                    #endif
                                }
                            )
                            .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                                return [AnchorKeyID(kind: "source", id: config.id, type: "title"): anchor]
                            }
                    } else {
                        // Show title but don't create anchor (not flowing)
                        Text(config.title)
                            .font(.title.weight(.semibold))
                            .opacity(0)
                            .accessibilityHidden(true)
                    }
                }

                Text(config.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle(config.title)
        #if canImport(UIKit)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 18.0, *)
#Preview {
    NavigationStack {
        ScrollView {
            PortalHeaderView()
                .padding(.top, 20)

            ForEach(0..<20) { index in
                Text("Item \(index)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .portalHeaderDestination()
    }
    .portalHeader(
        title: "Preview Title",
        subtitle: "This is a preview of the flowing header",
        displays: [.title]
    ) {
        Image(systemName: "star.fill")
            .font(.system(size: 64))
            .foregroundStyle(.yellow)
    }
    .portalHeaderDebugOverlays(showing: [.border])
}
#endif
