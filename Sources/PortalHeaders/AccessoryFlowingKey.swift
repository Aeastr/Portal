//
//  AccessoryFlowingKey.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Environment key for tracking whether a custom view is flowing.
internal struct AccessoryFlowingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// Whether the custom view is configured to flow to the navigation bar.
    internal var accessoryFlowing: Bool {
        get { self[AccessoryFlowingKey.self] }
        set { self[AccessoryFlowingKey.self] = newValue }
    }
}

// MARK: - Accessory Source Height Preference

/// Preference key for reporting accessory source height from PortalHeaderView to the modifier.
internal struct AccessorySourceHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > 0 {
            value = next
        }
    }
}
