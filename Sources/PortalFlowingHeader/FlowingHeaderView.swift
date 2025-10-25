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
    @Environment(\.flowingHeaderConfig) private var config
    @Environment(\.flowingHeaderAccessoryView) private var accessoryView
    @Environment(\.titleProgress) private var titleProgress
    @Environment(\.customViewFlowing) private var customViewFlowing

    private let id: String

    /// Creates a flowing header that reads configuration from environment.
    ///
    /// - Parameter id: Optional identifier to match specific header config (default: "default")
    public init(id: String = "default") {
        self.id = id
    }

    public var body: some View {
        Group {
            if let config = config, config.id == id {
                headerContent(config: config)
            } else {
                // Fallback when no config is provided
                Text("No flowing header configuration found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func headerContent(config: FlowingHeaderConfig) -> some View {
        VStack(spacing: hasAccessory ? 12 : 8) {
            let progress = (titleProgress * 4)

            // Show accessory if provided
            if let accessoryView = accessoryView {
                accessoryView
                    .opacity(customViewFlowing ? 0 : max(0.6, (1 - progress)))
                    .scaleEffect(customViewFlowing ? 1 : (max(0.6, (1 - progress))), anchor: .top)
                    .animation(.smooth(duration: FlowingHeaderTokens.transitionDuration), value: progress)
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: config.title, type: "accessory"): anchor]
                    }
            }

            VStack(spacing: 4) {
                // Source title (always invisible for layout)
                Text(config.title)
                    .font(.title.weight(.semibold))
//                    .opacity(0)  // Always invisible to maintain layout
                    .accessibilityHidden(true)  // Hide from VoiceOver since actual title is rendered separately
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: config.title, type: "title"): anchor]
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

    private var hasAccessory: Bool {
        accessoryView != nil
    }
}
