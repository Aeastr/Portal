//
//  FlowingHeaderDestination.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Environment Key

/// Environment key for flowing header layout
@available(iOS 18.0, *)
private struct FlowingHeaderLayoutKey: EnvironmentKey {
    static let defaultValue: AccessoryLayout = .horizontal
}

@available(iOS 18.0, *)
public extension EnvironmentValues {
    var flowingHeaderLayout: AccessoryLayout {
        get { self[FlowingHeaderLayoutKey.self] }
        set { self[FlowingHeaderLayoutKey.self] = newValue }
    }
}

// MARK: - Destination Modifier

/// A view modifier that provides destination anchors for flowing header transitions.
///
/// This modifier reads configuration from the environment to create invisible anchor points
/// in the navigation bar that serve as destinations for header elements during scroll transitions.
@available(iOS 18.0, *)
internal struct FlowingHeaderDestination: ViewModifier {
    @Environment(\.flowingHeaderContent) private var config
    @Environment(\.flowingHeaderAccessoryView) private var accessoryView
    @Environment(\.flowingHeaderLayout) private var layout
    @Environment(\.titleProgress) private var titleProgress

    let id: String
    let displays: Set<FlowingHeaderDisplayComponent>?

    @State private var accessorySize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .toolbar {
                if let config = config, config.id == id {
                    ToolbarItem(placement: .title) {
                        destinationContent(config: config)
                    }
                }
            }
    }

    @ViewBuilder
    private func destinationContent(config: FlowingHeaderContent) -> some View {
        let effectiveDisplays = displays ?? config.displays
        let showAccessory = effectiveDisplays.contains(.accessory) && accessoryView != nil
        let showTitle = effectiveDisplays.contains(.title)

        // Components that should flow (have anchors)
        let flowingComponents = config.displays

        // Components that should be static (visible but no anchor)
        let staticAccessory = showAccessory && !flowingComponents.contains(.accessory)
        let staticTitle = showTitle && !flowingComponents.contains(.title)

        if showAccessory && showTitle {
            // Both accessory and title
            switch layout {
            case .horizontal:
                HStack {
                    accessoryDestination(config: config, isStatic: staticAccessory)
                    titleDestination(config: config, isStatic: staticTitle)
                }
            case .vertical:
                VStack(spacing: 2) {
                    accessoryDestination(config: config, isStatic: staticAccessory)
                    titleDestination(config: config, isStatic: staticTitle)
                }
            }
        } else if showAccessory {
            // Accessory only
            accessoryDestination(config: config, isStatic: staticAccessory)
        } else if showTitle {
            // Title only
            titleDestination(config: config, isStatic: staticTitle)
        }
    }

    @ViewBuilder
    private func accessoryDestination(config: FlowingHeaderContent, isStatic: Bool) -> some View {
        if let accessoryView = accessoryView {
            let targetSize = FlowingHeaderTokens.navigationBarAccessorySize

            // Calculate scale based on measured size
            let scale = accessorySize.width > 0 ? targetSize / accessorySize.width : 1.0

            if isStatic {
                // Static display - fades in with scroll progress
                accessoryView
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        accessorySize = newSize
                    }
                    .scaleEffect(scale)
                    .frame(width: targetSize, height: targetSize)
                    .opacity(titleProgress)
            } else {
                // Flowing - invisible anchor
                accessoryView
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        accessorySize = newSize
                    }
                    .scaleEffect(scale)
                    .frame(width: targetSize, height: targetSize)
                    .opacity(0)
                    .accessibilityHidden(true)
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        [AnchorKeyID(kind: "destination", id: config.title, type: "accessory"): anchor]
                    }
            }
        }
    }

    @ViewBuilder
    private func titleDestination(config: FlowingHeaderContent, isStatic: Bool) -> some View {
        if isStatic {
            // Static display - fades in with scroll progress
            Text(config.title)
                .font(.headline.weight(.semibold))
                .opacity(titleProgress)
        } else {
            // Flowing - invisible anchor
            Text(config.title)
                .font(.headline.weight(.semibold))
                .opacity(0)
                .accessibilityHidden(true)
                .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                    [AnchorKeyID(kind: "destination", id: config.title, type: "title"): anchor]
                }
        }
    }
}

// MARK: - Public API

@available(iOS 18.0, *)
public extension View {
    /// Creates destination anchors for a flowing header transition.
    ///
    /// This modifier reads configuration from the environment (set by `.flowingHeader()`)
    /// and creates invisible anchor points in the navigation bar for the transition destinations.
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
    /// .flowingHeader(title: "Favorites", subtitle: "Your items")
    /// ```
    ///
    /// ## Custom Display Components
    ///
    /// Override which components appear in the navigation bar:
    ///
    /// ```swift
    /// ScrollView {
    ///     FlowingHeaderView()
    /// }
    /// .flowingHeaderDestination(displays: [.title])  // Title only, no accessory
    /// ```
    ///
    /// - Parameters:
    ///   - id: Optional identifier to match specific header config (default: "default")
    ///   - displays: Optional override for which components to show (default: uses config.displays)
    /// - Returns: A view with destination anchors configured
    ///
    /// - Important: Apply this modifier inside the NavigationStack, typically
    ///   to the ScrollView or List containing your header content.
    func flowingHeaderDestination(
        id: String = "default",
        displays: Set<FlowingHeaderDisplayComponent>? = nil
    ) -> some View {
        modifier(FlowingHeaderDestination(id: id, displays: displays))
    }
}
