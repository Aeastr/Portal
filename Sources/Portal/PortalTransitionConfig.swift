import SwiftUI

/// Comprehensive configuration container for portal transition animations.
///
/// This struct serves as the main configuration object that encapsulates all the settings
/// needed to customize a portal animation. It combines animation timing parameters with
/// visual styling options to provide complete control over the transition appearance.
///
/// The configuration is designed to be immutable and reusable across multiple portal
/// transitions, promoting consistency in animation behavior throughout an application.
///
/// **Usage Pattern:**
/// - Create once, use multiple times for consistent animations
/// - Pass to portal initialization or update methods
/// - Combine with different portal IDs for varied but consistent transitions
///
/// Example usage:
/// ```swift
/// let config = PortalTransitionConfig(
///     animation: PortalAnimation(.spring(duration: 0.5), delay: 0.1, duration: 0.5),
///     corners: PortalCorners(source: 8, destination: 16, style: .continuous)
/// )
///
/// // Use with portal animation
/// portalTransition(id: "myPortal", config: config)
/// ```
public struct PortalTransitionConfig {
    
    /// Animation timing and behavior configuration.
    ///
    /// Defines how the portal transition animates, including duration, easing curves,
    /// and delays. This controls the temporal aspects of the portal animation.
    public let animation: PortalAnimationProtocol
    
    /// Corner styling configuration for visual appearance.
    ///
    /// Defines the corner radius values and styling for both source and destination
    /// elements during the transition. This controls the spatial/visual aspects of
    /// the portal animation.
    ///
    /// When `nil`, no corner clipping is applied, allowing content to extend
    /// beyond frame boundaries during scaling transitions.
    public let corners: PortalCorners?
    
    /// Initializes a new portal transition configuration with basic animation.
    ///
    /// Creates a complete configuration object with specified animation and corner settings.
    /// Both parameters have sensible defaults, allowing for partial customization while
    /// maintaining good default behavior.
    ///
    /// - Parameters:
    ///   - animation: The animation configuration. Defaults to a smooth 0.38s animation.
    ///   - corners: The corner styling configuration. Defaults to nil (no clipping).
    public init(animation: PortalAnimation = .init(), corners: PortalCorners? = nil) {
        self.animation = animation
        self.corners = corners
    }
    
    /// Initializes a new portal transition configuration with iOS 17+ completion criteria.
    ///
    /// Creates a complete configuration object with specified animation and corner settings.
    /// This initializer allows you to use completion criteria for more precise animation control.
    ///
    /// - Parameters:
    ///   - animation: The animation configuration with completion criteria.
    ///   - corners: The corner styling configuration. Defaults to nil (no clipping).
    public init(animation: PortalAnimationWithCompletion, corners: PortalCorners? = nil) {
        self.animation = animation
        self.corners = corners
    }
}

/// Protocol that defines the common interface for portal animations.
///
/// This protocol allows both `PortalAnimation` and `PortalAnimationWithCompletion` to be
/// used interchangeably in the portal system while maintaining type safety.
public protocol PortalAnimationProtocol {
    
    /// The SwiftUI animation curve and timing configuration.
    var value: Animation { get }
    
    /// Delay before the animation begins, in seconds.
    var delay: TimeInterval { get }
    
    /// Executes the animation with appropriate completion handling for the iOS version.
    ///
    /// This method abstracts away the iOS version differences and provides a clean
    /// interface for executing animations with completion callbacks.
    ///
    /// - Parameters:
    ///   - animation: The animation block to execute.
    ///   - completion: Called when animation completes.
    func performAnimation<T>(
        _ animation: @escaping () -> T,
        completion: @escaping @MainActor () -> Void
    )
}

/// Animation configuration for portal transitions (iOS 15+).
///
/// This struct encapsulates basic timing parameters for portal animations,
/// including the SwiftUI animation curve and delay timing. It provides 
/// control over the temporal behavior of portal transitions while maintaining
/// compatibility with iOS 15+.
///
/// **Key Features:**
/// - Wraps SwiftUI's `Animation` type for curve definitions
/// - Configurable delay for staggered animation effects
/// - Explicit duration for accurate iOS 15-16 completion timing
/// - Automatically upgrades to modern completion criteria on iOS 17+
///
/// **Default Behavior:**
/// - Uses appropriate animation type for the iOS version
/// - Small delay to allow for view hierarchy updates
/// - Reliable completion detection across all iOS versions
public struct PortalAnimation: PortalAnimationProtocol {
    
    /// The SwiftUI animation curve and timing configuration.
    public let value: Animation
    
    /// Delay before the animation begins, in seconds.
    public let delay: TimeInterval
    
    /// Initializes a new portal animation configuration.
    ///
    /// Creates an animation configuration with specified timing parameters.
    /// This works on all iOS versions and uses appropriate completion detection.
    ///
    /// - Parameters:
    ///   - animation: The SwiftUI animation curve.
    ///   - delay: Start delay in seconds. Defaults to 0.06s.
    ///   - duration: Animation duration in seconds. Defaults to 0.38s.
    public init(
        _ animation: Animation,
        delay: TimeInterval = 0.1,
    ) {
        self.value = animation
        self.delay = delay
    }
    
    /// Default initializer that works across all iOS versions.
    ///
    /// Creates a PortalAnimation with sensible defaults, automatically selecting
    /// the best animation type for the current iOS version.
    public init() {
        self.init(.smooth(duration: 0.38, extraBounce: 0.1), delay: 0.08)
    }
    
    /// Executes the animation with appropriate completion handling for the iOS version.
    public func performAnimation<T>(
        _ animation: @escaping () -> T,
        completion: @escaping @MainActor () -> Void
    ) {
        withAnimation(value, completionCriteria: .removed) {
            _ = animation()
        } completion: {
            Task { @MainActor in
                completion()
            }
        }
    }
}

/// Animation configuration for portal transitions with iOS 17+ completion criteria.
///
/// This struct provides advanced animation control with modern completion criteria
/// detection. It's only available on iOS 17+ where `AnimationCompletionCriteria` 
/// is supported.
///
/// **Key Features:**
/// - Wraps SwiftUI's `Animation` type for curve definitions
/// - Configurable delay for staggered animation effects
/// - Configurable completion criteria for precise animation lifecycle control
/// - Type-safe completion criteria handling
///
/// **Usage:**
/// ```swift
/// let animation = PortalAnimationWithCompletion(
///     .smooth(duration: 0.5),
///     delay: 0.1,
///     completionCriteria: .logicallyComplete
/// )
/// ```
public struct PortalAnimationWithCompletion: PortalAnimationProtocol {
    
    /// The SwiftUI animation curve and timing configuration.
    public let value: Animation
    
    /// Delay before the animation begins, in seconds.
    public let delay: TimeInterval
    
    /// Completion criteria for detecting when the animation finishes.
    public let completionCriteria: AnimationCompletionCriteria
    
    /// Initializes a new portal animation configuration with completion criteria.
    ///
    /// Creates an animation configuration with modern completion criteria detection.
    /// This provides precise control over when completion callbacks are triggered.
    ///
    /// - Parameters:
    ///   - animation: The SwiftUI animation curve.
    ///   - delay: Start delay in seconds. Defaults to 0.06s.
    ///   - completionCriteria: How to detect animation completion. Defaults to .removed.
    public init(
        _ animation: Animation,
        delay: TimeInterval = 0.06,
        completionCriteria: AnimationCompletionCriteria = .removed
    ) {
        self.value = animation
        self.delay = delay
        self.completionCriteria = completionCriteria
    }
    
    /// Executes the animation with iOS 17+ completion criteria.
    public func performAnimation<T>(
        _ animation: @escaping () -> T,
        completion: @escaping @MainActor () -> Void
    ) {
        withAnimation(value, completionCriteria: completionCriteria) {
            _ = animation()
        } completion: {
            Task { @MainActor in
                completion()
            }
        }
    }
}

/// Corner radius configuration for portal transition elements.
///
/// This struct defines the corner styling for both the source and destination
/// elements of a portal transition. It allows for smooth interpolation between
/// different corner radius values during the animation, creating visually
/// cohesive transitions even when source and destination have different styling.
///
/// **Corner Interpolation:**
/// During the transition, the corner radius is smoothly interpolated from the
/// source value to the destination value, ensuring visual continuity throughout
/// the animation.
///
/// **Style Consistency:**
/// The corner style (circular vs. continuous) is applied uniformly to maintain
/// visual consistency with the rest of the application's design language.
public struct PortalCorners {
    
    /// Corner radius for the source (starting) element, in points.
    ///
    /// This value defines the corner radius of the element at the beginning
    /// of the portal transition. The animation will start with this radius
    /// and interpolate toward the destination radius.
    ///
    /// A value of 0 creates sharp corners (rectangular appearance).
    public let source: CGFloat
    
    /// Corner radius for the destination (ending) element, in points.
    ///
    /// This value defines the corner radius of the element at the end
    /// of the portal transition. The animation will interpolate from the
    /// source radius to this target radius.
    ///
    /// A value of 0 creates sharp corners (rectangular appearance).
    public let destination: CGFloat
    
    /// The style of corner rounding to apply.
    ///
    /// Defines the mathematical curve used for creating rounded corners.
    /// This affects the visual appearance of the corners during the entire
    /// transition animation.
    ///
    /// **Available Styles:**
    /// - `.circular`: Traditional circular arc corners (iOS default)
    /// - `.continuous`: Apple's continuous corner curve (more organic appearance)
    public let style: RoundedCornerStyle
    
    /// Initializes a new portal corner configuration.
    ///
    /// Creates a corner configuration with specified radius values for source
    /// and destination elements, along with the corner style to use throughout
    /// the transition.
    ///
    /// - Parameters:
    ///   - source: Source corner radius in points. Defaults to 0 (sharp corners).
    ///   - destination: Destination corner radius in points. Defaults to 0 (sharp corners).
    ///   - style: Corner rounding style. Defaults to circular corners.
    public init(source: CGFloat = 0, destination: CGFloat = 0, style: RoundedCornerStyle = .circular) {
        self.source = source
        self.destination = destination
        self.style = style
    }
}
