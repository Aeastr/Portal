//
//  .swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI

/// Compatibility onChange for iOS/macOS
public extension View {
    /// Like onChange(of:), but works uniformly across iOS 17+/macOS 14+ and earlier.
    @ViewBuilder
    func onChangeCompat<Value: Equatable>(of value: Value, perform action: @escaping (Value) -> Void) -> some View {
        if #available(iOS 17, macOS 14, *) {
            self.onChange(of: value) { oldValue, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value) { newValue in
                action(newValue)
            }
        }
    }
}
