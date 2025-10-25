//
//  FlowingHeaderView.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A header view that smoothly transitions to the navigation bar during scroll.
///
/// `FlowingHeaderView` reads its configuration from the environment, set by the
/// `.flowingHeader()` modifier applied to the parent NavigationStack.
///
/// ## Basic Usage
///
/// ```swift
/// NavigationStack {
///     ScrollView {
///         FlowingHeaderView()
///     }
///     .flowingHeaderDestination()
/// }
/// .flowingHeader(title: "Favorites", subtitle: "Your starred items")
/// ```
///
/// ## With Accessory
///
/// ```swift
/// NavigationStack {
///     ScrollView {
///         FlowingHeaderView()
///     }
///     .flowingHeaderDestination(displays: [.title, .accessory])
/// }
/// .flowingHeader(
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
public struct FlowingHeaderView: View {
    @Environment(\.flowingHeaderContent) private var config
    @Environment(\.flowingHeaderAccessoryView) private var accessoryView
    @Environment(\.titleProgress) private var titleProgress
    @Environment(\.accessoryFlowing) private var accessoryFlowing

    private let id: String
    private let visibleComponents: Set<FlowingHeaderDisplayComponent>?

    /// Creates a flowing header that reads configuration from environment.
    ///
    /// - Parameters:
    ///   - id: Optional identifier to match specific header config (default: "default")
    ///   - displays: Optional override for which components to show in the header (default: shows all)
    public init(id: String = "default", displays: Set<FlowingHeaderDisplayComponent>? = nil) {
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
    private func headerContent(config: FlowingHeaderContent) -> some View {
        // visibleComponents controls what shows in the header
        // config.displays controls what flows to nav bar (creates anchors)
        let showComponents = visibleComponents ?? [.title, .accessory]  // Default: show everything
        let flowComponents = config.displays  // What flows to nav bar

        let showAccessory = showComponents.contains(.accessory) && accessoryView != nil
        let showTitle = showComponents.contains(.title)
        let createAccessoryAnchor = flowComponents.contains(.accessory) && accessoryView != nil
        let createTitleAnchor = flowComponents.contains(.title)

        VStack(spacing: showAccessory ? 12 : 8) {
            let progressFade = (titleProgress * FlowingHeaderTokens.accessoryFadeMultiplier)

            // Show accessory if in visibleComponents
            if showAccessory, let accessoryView = accessoryView {
                if createAccessoryAnchor {
                    // Create anchor - hide if actually flowing (has destination)
                    accessoryView
                        .opacity(accessoryFlowing ? 0 : max(0.6, (1 - progressFade)))
                        .scaleEffect(accessoryFlowing ? 1 : max(0.6, (1 - progressFade)), anchor: .top)
                        .animation(.smooth(duration: FlowingHeaderTokens.transitionDuration), value: progressFade)
                        .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                            return [AnchorKeyID(kind: "source", id: config.id, type: "accessory"): anchor]
                        }
                } else {
                    // Not creating anchor, but still apply fade/scale effect
                    accessoryView
                        .opacity(max(0.6, (1 - progressFade)))
                        .scaleEffect(max(0.6, (1 - progressFade)), anchor: .top)
                        .animation(.smooth(duration: FlowingHeaderTokens.transitionDuration), value: progressFade)
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
