import SwiftUI

/// A SwiftUI PreferenceKey for collecting and managing Portal anchor information.
///
/// This preference key is used to gather anchor bounds from Portal views throughout the view hierarchy.
/// It enables the portal system to track the positions and sizes of source and destination views,
/// which is essential for calculating smooth transition animations between them.
///
/// The key collects a dictionary where:
/// - Keys are unique portal identifiers (including source/destination suffixes)
/// - Values are `Anchor<CGRect>` objects representing the bounds of portal views
///
/// This information flows up the view hierarchy and is consumed by the `CrossModel`
/// to coordinate portal transitions.
public struct AnchorKey: PreferenceKey {
    /// The default value when no portal anchors have been collected.
    ///
    /// An empty dictionary indicates that no portal views have reported their bounds yet.
    /// This is the starting point before any portal views are rendered or positioned.
    public static let defaultValue: [String: Anchor<CGRect>] = [:]

    /// Combines multiple anchor dictionaries as they flow up the view hierarchy.
    ///
    /// This method is called by SwiftUI's preference system when multiple child views
    /// provide anchor information. It merges all collected anchors into a single dictionary.
    ///
    /// The merge strategy uses `{ $1 }` as the conflict resolution closure, meaning that
    /// when two views report anchors with the same key, the newer value (from `nextValue()`)
    /// takes precedence. This ensures that the most recent anchor information is preserved.
    ///
    /// - Parameters:
    ///   - value: The current accumulated dictionary of portal anchors (modified in-place)
    ///   - nextValue: A closure that returns the next dictionary of anchors to merge
    public static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}
