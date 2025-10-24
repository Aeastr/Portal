//
//  FlowingHeaderView.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A header view that smoothly transitions to the navigation bar during scroll.
///
/// `FlowingHeaderView` creates a header that contains an accessory (icon, image, or custom view), title, and subtitle.
/// As the user scrolls, these elements animate toward their corresponding positions in the
/// navigation bar, creating a fluid transition effect.
///
/// ## Basic Usage
///
/// Create a simple accessory-based header:
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
/// Use a custom view accessory:
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
    @Environment(\.systemImageFlowing) var systemImageFlowing
    @Environment(\.imageFlowing) var imageFlowing
    @Environment(\.customViewFlowing) var customViewFlowing

    private let title: String
    private let subtitle: String
    private let icon: String?
    private let image: Image?
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

    /// Creates a flowing header with an SF Symbols accessory.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - systemImage: The SF Symbols name for the header accessory
    ///   - subtitle: Secondary text that appears below the title
    public init(_ title: String, systemImage: String, subtitle: String) where Content == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = systemImage
        self.image = nil
        self.content = nil
    }

    /// Creates a flowing header with an Image accessory.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - image: The Image accessory to display in the header
    ///   - subtitle: Secondary text that appears below the title
    public init(_ title: String, image: Image, subtitle: String) where Content == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.icon = nil
        self.image = image
        self.content = nil
    }

    /// Creates a flowing header with a custom view accessory.
    ///
    /// - Parameters:
    ///   - title: The main title text that will flow to the navigation bar
    ///   - subtitle: Secondary text that appears below the title
    ///   - content: A view builder that creates the custom accessory content
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
                    .opacity(customViewFlowing ? 0 : max(0.6, (1 - progress)))
                    .scaleEffect(customViewFlowing ? 1 : (max(0.6, (1 - progress))), anchor: .top)
                    .animation(.smooth(duration: FlowingHeaderConstants.transitionDuration), value: progress)
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "accessory"): anchor]
                    }
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                    .opacity(systemImageFlowing ? 0 : max(0.6, (1 - progress)))
                    .scaleEffect(systemImageFlowing ? 1 : (max(0.6, (1 - progress))), anchor: .top)
                    .animation(.smooth(duration: FlowingHeaderConstants.transitionDuration), value: progress)
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "accessory"): anchor]
                    }
            } else if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .opacity(imageFlowing ? 0 : max(0.6, (1 - progress)))
                    .scaleEffect(imageFlowing ? 1 : (max(0.6, (1 - progress))), anchor: .top)
                    .animation(.smooth(duration: FlowingHeaderConstants.transitionDuration), value: progress)
                    .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                        return [AnchorKeyID(kind: "source", id: title, type: "accessory"): anchor]
                    }
            }

            VStack(spacing: 4) {
                // Source title (always invisible for layout)
                Text(title)
                    .font(.title.weight(.semibold))
                    .opacity(0)  // Always invisible to maintain layout
                    .accessibilityHidden(true)  // Hide from VoiceOver since actual title is rendered separately
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
