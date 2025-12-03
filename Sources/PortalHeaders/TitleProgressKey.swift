//
//  TitleProgressKey.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Environment key for tracking title transition progress.
///
/// This key stores a `Double` value from 0.0 to 1.0 representing how far
/// the header has transitioned toward the navigation bar state.
internal struct TitleProgressKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
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
}
