#if canImport(UIKit)
import UIKit
import SwiftUI

/// A specialized UIWindow that allows touch events to pass through non-content areas.
///
/// This window is designed for overlay scenarios where you want certain areas of the window
/// to be transparent to touch events. When a touch occurs on the root view controller's
/// background (areas without actual content), the touch is passed through to underlying
/// windows or views, creating a "hole-punch" effect for user interactions.
///
/// This is particularly useful for:
/// - Modal overlays that should only capture touches on specific content areas
/// - Portal transition animations where background touches should pass through
/// - Floating UI elements that don't want to block touches on empty areas
///
/// The window uses hit testing to determine whether touches should be handled or passed through.
internal class PassThroughWindow: UIWindow {
    /// Performs hit testing to determine which view should receive touch events.
    ///
    /// This override implements the pass-through behavior by checking if the touch
    /// hit the root view controller's background. If so, it returns `nil` to pass
    /// the touch through to underlying windows.
    ///
    /// The method works as follows:
    /// 1. Performs standard hit testing to find the touched view
    /// 2. Checks if we have a valid hit view and root view controller
    /// 3. On iOS 18+, iterates through subviews to find actual content
    /// 4. Returns `nil` if the touch is only on the background, allowing pass-through
    ///
    /// - Parameters:
    ///   - point: The touch point in the window's coordinate system
    ///   - event: The touch event containing additional context
    /// - Returns: The view that should handle the touch, or `nil` to pass through
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Perform standard hit testing first
        guard let hitView = super.hitTest(point, with: event),
              let rootView = rootViewController?.view else {
            return nil
        }

        // Enhanced hit testing for iOS 18+ to better detect content areas
        if #available(iOS 18, *) {
            // Check subviews in reverse order (top to bottom) to find actual content
            for subview in rootView.subviews.reversed() {
                // Convert the touch point to the subview's coordinate system
                let pointInSubView = subview.convert(point, from: rootView)

                // If the subview contains actual content at this point, handle the touch normally
                if subview.hitTest(pointInSubView, with: event) != nil {
                    return hitView
                }
            }
        }

        // If the hit view is only the root view (background), pass the touch through
        // Otherwise, return the hit view to handle the touch normally
        return hitView == rootView ? nil : hitView
    }
}
#else
import SwiftUI

/// Stub implementation for non-UIKit platforms (macOS, watchOS, tvOS).
///
/// This empty class provides API compatibility across platforms while doing nothing
/// on platforms that don't support UIKit. The actual pass-through functionality
/// is only available on iOS/iPadOS where UIKit is available.
///
/// On non-UIKit platforms, portal systems should use platform-appropriate
/// alternatives for managing window layering and touch handling.
internal class PassThroughWindow { }
#endif
