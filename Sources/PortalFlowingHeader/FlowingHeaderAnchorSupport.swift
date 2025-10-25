//
//  FlowingHeaderSupport.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Internal Support Types

/// A unique identifier for anchor preferences used in flowing header transitions.
///
/// This type combines three components to create unique keys for tracking UI elements
/// during the flowing header animation:
/// - `kind`: Whether this is a "source" or "destination" anchor
/// - `id`: The unique identifier string for the header
/// - `type`: The element type ("title" or "customView")
internal struct AnchorKeyID: Hashable {
    let kind: String
    let id: String
    let type: String
}

/// Preference key for collecting anchor bounds during flowing header transitions.
///
/// This preference key accumulates anchor bounds from both source (header content)
/// and destination (navigation bar) locations to enable smooth position interpolation.
internal struct AnchorKey: PreferenceKey {
    typealias Value = [AnchorKeyID: Anchor<CGRect>]
    nonisolated(unsafe) static var defaultValue: [AnchorKeyID: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [AnchorKeyID: Anchor<CGRect>],
        nextValue: () -> [AnchorKeyID: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Environment Values

/// Environment key for tracking title transition progress.
///
/// This key stores a `Double` value from 0.0 to 1.0 representing how far
/// the header has transitioned toward the navigation bar state.
private struct TitleProgressKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}

/// Environment key for tracking whether a custom view is flowing.
private struct AccessoryFlowingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// The current progress of the flowing header transition.
    ///
    /// This value ranges from 0.0 (header fully visible) to 1.0 (header fully
    /// transitioned to navigation bar). Views can use this to create custom
    /// animations that sync with the header transition.
    internal var titleProgress: Double {
        get { self[TitleProgressKey.self] }
        set { self[TitleProgressKey.self] = newValue }
    }

    /// Whether the custom view is configured to flow to the navigation bar.
    internal var accessoryFlowing: Bool {
        get { self[AccessoryFlowingKey.self] }
        set { self[AccessoryFlowingKey.self] = newValue }
    }
}
