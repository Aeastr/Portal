//
//  FlowingHeaderDestination.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
//

import SwiftUI

/// A view modifier that provides destination anchors for flowing header transitions.
///
/// This modifier creates invisible anchor points in the navigation bar that serve as
/// the destination for header elements during scroll transitions. The anchors must
/// remain mounted in the view hierarchy to ensure smooth animations.
@available(iOS 18.0, *)
internal struct FlowingHeaderDestination: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .opacity(0)  // Invisible but present for anchor extraction
                        .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                            [AnchorKeyID(kind: "destination", id: title, type: "title"): anchor]
                        }
                }
            }
    }
}

/// A view modifier that provides destination anchors for both custom views and titles.
///
/// Use this variant when your flowing header includes a custom view that should also
/// transition to the navigation bar. Both the custom view and title will have invisible
/// destination anchors created.
@available(iOS 18.0, *)
internal struct FlowingHeaderDestinationWithCustomView<DestinationView: View>: ViewModifier {
    let title: String
    let destinationView: DestinationView

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        // Custom view (invisible but present for anchor extraction)
                        destinationView
                            .opacity(0)
                            .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                                [AnchorKeyID(kind: "destination", id: title, type: "customView"): anchor]
                            }

                        // Title (invisible but present for anchor extraction)
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .opacity(0)
                            .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                                [AnchorKeyID(kind: "destination", id: title, type: "title"): anchor]
                            }
                    }
                }
            }
    }
}

// MARK: - Public API

@available(iOS 18.0, *)
public extension View {
    /// Creates destination anchors for a flowing header transition.
    ///
    /// This modifier should be applied to scroll content (like `ScrollView` or `List`)
    /// to establish where header elements should transition to in the navigation bar.
    /// The anchors are invisible but remain mounted to ensure smooth animations.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// ScrollView {
    ///     FlowingHeaderView(icon: "star", title: "Favorites", subtitle: "Your items")
    ///     // Content...
    /// }
    /// .flowingHeaderDestination("Favorites")
    /// ```
    ///
    /// - Parameter title: The title string that matches your FlowingHeaderView
    /// - Returns: A view with destination anchors configured
    ///
    /// - Important: Apply this modifier inside the NavigationStack, typically
    ///   to the ScrollView or List containing your header content.
    func flowingHeaderDestination(_ title: String) -> some View {
        modifier(FlowingHeaderDestination(title: title))
    }
    
    /// Creates destination anchors for a flowing header with a custom view.
    ///
    /// Use this variant when your header includes a custom view component that should
    /// also transition to the navigation bar. This creates invisible anchors for both
    /// the custom view and the title text.
    ///
    /// ## Usage with Custom View
    ///
    /// ```swift
    /// ScrollView {
    ///     FlowingHeaderView(customView: ProfileAvatar(), title: "Profile", subtitle: "Settings")
    ///     // Content...
    /// }
    /// .flowingHeaderDestination("Profile") {
    ///     ProfileAvatar()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - customView: A view builder that creates the custom view destination
    /// - Returns: A view with destination anchors for both custom view and title
    ///
    /// - Note: The custom view provided here should match the one used in your
    ///   FlowingHeaderView for consistent animation behavior.
    func flowingHeaderDestination<DestinationView: View>(
        _ title: String, 
        @ViewBuilder customView: () -> DestinationView
    ) -> some View {
        modifier(FlowingHeaderDestinationWithCustomView(title: title, destinationView: customView()))
    }
}