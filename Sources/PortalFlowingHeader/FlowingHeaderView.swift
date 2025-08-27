//
//  FlowingHeaderView.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
//

import SwiftUI

/// A header view that smoothly transitions to the navigation bar during scroll.
///
/// `FlowingHeaderView` creates a header that contains an icon or custom view, title, and subtitle.
/// As the user scrolls, these elements animate toward their corresponding positions in the
/// navigation bar, creating a fluid transition effect.
///
/// ## Basic Usage
///
/// Create a simple icon-based header:
///
/// ```swift
/// FlowingHeaderView(
///     icon: "star.fill",
///     title: "Favorites",
///     subtitle: "Your starred items"
/// )
/// ```
///
/// ## Custom View Header
///
/// Use a custom view instead of an icon:
///
/// ```swift
/// FlowingHeaderView(
///     customView: ProfileAvatar(),
///     title: "Profile",
///     subtitle: "Account settings"
/// )
/// ```
///
/// ## Integration
///
/// The header must be used with the flowing header modifiers:
///
/// ```swift
/// ScrollView {
///     FlowingHeaderView(icon: "star", title: "Title", subtitle: "Subtitle")
///     // Content...
/// }
/// .flowingHeaderDestination("Title")
/// ```
///
/// - Important: This view is only available on iOS 18.0 and later due to its use of
///   advanced scroll tracking APIs.
@available(iOS 18.0, *)
public struct FlowingHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.titleProgress) var titleProgress

    private let icon: String?
    private let customView: AnyView?
    private let title: String
    private let subtitle: String
    private let iconSize: CGFloat
    private let brightness: Double
    private let saturation: Double
    private let blur: Double
    private let verticalPadding: CGFloat
    private let gradientColor1: Color
    private let gradientColor2: Color

    /// Creates a flowing header with an SF Symbols icon.
    ///
    /// - Parameters:
    ///   - icon: The SF Symbols name for the header icon
    ///   - title: The main title text that will flow to the navigation bar
    ///   - subtitle: Secondary text that appears below the title
    ///   - iconSize: The size of the icon in points (default: 58)
    ///   - brightness: Brightness adjustment for the icon (default: 0.8)
    ///   - saturation: Saturation boost for the icon (default: 5)
    ///   - blur: Blur radius for icon effects (default: 6)
    ///   - verticalPadding: Vertical spacing around the header (default: 5)
    ///   - gradientColor1: Start color for the icon gradient (default: primary)
    ///   - gradientColor2: End color for the icon gradient (default: primary)
    public init(
        icon: String,
        title: String,
        subtitle: String,
        iconSize: CGFloat = 58,
        brightness: Double = 0.8,
        saturation: Double = 5,
        blur: Double = 6,
        verticalPadding: CGFloat = 5,
        gradientColor1: Color = Color.primary,
        gradientColor2: Color = Color.primary
    ) {
        self.icon = icon
        self.customView = nil
        self.title = title
        self.subtitle = subtitle
        self.iconSize = iconSize
        self.brightness = brightness
        self.saturation = saturation
        self.blur = blur
        self.verticalPadding = verticalPadding
        self.gradientColor1 = gradientColor1
        self.gradientColor2 = gradientColor2
    }

    /// Creates a flowing header with a custom view.
    ///
    /// - Parameters:
    ///   - customView: A custom SwiftUI view to display instead of an icon
    ///   - title: The main title text that will flow to the navigation bar
    ///   - subtitle: Secondary text that appears below the title
    ///   - iconSize: The size constraint for the custom view (default: 60)
    ///   - verticalPadding: Vertical spacing around the header (default: 6)
    ///   - gradientColor1: Primary gradient color for styling (default: blue)
    ///   - gradientColor2: Secondary gradient color for styling (default: purple)
    public init<Content: View>(
        customView: Content,
        title: String,
        subtitle: String,
        iconSize: CGFloat = 60,
        verticalPadding: CGFloat = 6,
        gradientColor1: Color = .blue,
        gradientColor2: Color = .purple
    ) {
        self.icon = nil
        self.customView = AnyView(customView)
        self.title = title
        self.subtitle = subtitle
        self.iconSize = iconSize
        self.brightness = 0  // Not used for customView
        self.saturation = 0  // Not used for customView
        self.blur = 0  // Not used for customView
        self.verticalPadding = verticalPadding
        self.gradientColor1 = gradientColor1
        self.gradientColor2 = gradientColor2
    }

    public var body: some View {
        VStack(spacing: customView == nil ? 8 : 12) {
            let progress = (titleProgress * 4)
            
            // Show either icon or customView
            if let customView = customView {
                customView
                    .opacity(0)  // Always invisible to maintain layout, just like the title
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "customView"): anchor]
                    }
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [gradientColor1, gradientColor2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(max(0.6, (1 - progress)))
                    .scaleEffect((max(0.6, (1 - progress))), anchor: .top)
                    .animation(.smooth(duration: 0.3), value: progress)
            }
            
            VStack(spacing: 4) {
                // Source title (always invisible for layout)
                Text(title)
                    .font(.title.weight(.semibold))
                    .opacity(0)  // Always invisible to maintain layout
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "title"): anchor]
                    }
                    
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle(title)
        #if canImport(UIKit)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .padding(.vertical, verticalPadding)
        .animation(.smooth(duration: 0.3), value: icon)
    }
}