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
public struct FlowingHeaderView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.titleProgress) var titleProgress

    private let title: String
    private let subtitle: String
    private let icon: String?
    private let image: String?
    private let content: Content?

    /// Creates a flowing header with just title and subtitle.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - subtitle: Secondary text that appears below the title
    public init(_ title: String, subtitle: String) where Content == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = nil
        self.image = nil
        self.content = nil
    }

    /// Creates a flowing header with an SF Symbols icon.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - systemImage: The SF Symbols name for the header icon
    ///   - subtitle: Secondary text that appears below the title
    public init(_ title: String, systemImage: String, subtitle: String) where Content == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = systemImage
        self.image = nil
        self.content = nil
    }

    /// Creates a flowing header with an image from your app bundle.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - image: The name of an image in your app bundle
    ///   - subtitle: Secondary text that appears below the title
    public init(_ title: String, image: String, subtitle: String) where Content == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = nil
        self.image = image
        self.content = nil
    }

    /// Creates a flowing header with a custom view.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - subtitle: Secondary text that appears below the title
    ///   - content: A view builder that creates the custom header content
    public init(_ title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = nil
        self.image = nil
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: hasVisualContent ? 12 : 8) {
            let progress = (titleProgress * 4)
            
            // Show icon, image, or custom content
            if let content = content {
                content
                    .opacity(0)  // Always invisible to maintain layout, just like the title
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "customView"): anchor]
                    }
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                    .opacity(max(0.6, (1 - progress)))
                    .scaleEffect((max(0.6, (1 - progress))), anchor: .top)
                    .animation(.smooth(duration: 0.3), value: progress)
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "systemImage"): anchor]
                    }
            } else if let image = image {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
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
    }
    
    private var hasVisualContent: Bool {
        content != nil || icon != nil || image != nil
    }
}