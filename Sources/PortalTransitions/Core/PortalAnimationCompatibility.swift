//
//  PortalAnimationCompatibility.swift
//  Portal
//
//  Compatibility helpers for projects whose deployment target is below iOS 17.
//

import SwiftUI

/// Portable stand-in for SwiftUI's iOS 17+ animation completion criteria.
public enum PortalAnimationCompletionCriteria: Sendable {
    case logicallyComplete
    case removed
}

@MainActor
public func portalWithAnimation<Result>(
    _ animation: Animation,
    completionCriteria: PortalAnimationCompletionCriteria,
    _ body: () throws -> Result,
    completion: @escaping () -> Void
) rethrows -> Result {
    if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
        let nativeCompletionCriteria: SwiftUI.AnimationCompletionCriteria = {
            switch completionCriteria {
            case .logicallyComplete:
                return .logicallyComplete
            case .removed:
                return .removed
            }
        }()

        return try withAnimation(animation, completionCriteria: nativeCompletionCriteria, body) {
            completion()
        }
    } else {
        let result = try withAnimation(animation, body)
        DispatchQueue.main.async {
            completion()
        }
        return result
    }
}
