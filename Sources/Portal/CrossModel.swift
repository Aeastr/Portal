import SwiftUI

/// Shared model for managing Portal animations and transitions.
///
/// This class serves as the central coordinator for portal animations, managing the state
/// and anchor information for both source and destination views. It tracks animation states,
/// opacity values, and coordinate transformations needed for smooth portal transitions.
///
/// The model uses the `@Observable` macro for SwiftUI integration and is marked with
/// `@MainActor` to ensure all UI-related operations happen on the main thread.
@MainActor @Observable
public class CrossModel {
    /// Array containing information about all active portal animations.
    /// Each `PortalInfo` object tracks the state of a specific portal transition.
    public var info: [PortalInfo] = []
    
    /// Array containing root-level portal information.
    /// Used for managing portal hierarchies and nested portal scenarios.
    public var rootInfo: [PortalInfo] = []
    
    /// Initializes a new CrossModel instance.
    /// Creates empty arrays for managing portal information.
    public init() {}
}
