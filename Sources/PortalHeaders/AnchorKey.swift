//
//  AnchorKey.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

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
