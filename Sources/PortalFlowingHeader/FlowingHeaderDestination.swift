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

/// A view modifier that provides destination anchors for both system image and title.
///
/// Use this variant when your flowing header includes a system image that should
/// transition to the navigation bar along with the title.
@available(iOS 18.0, *)
internal struct FlowingHeaderDestinationWithSystemImage: ViewModifier {
    let title: String
    let systemImage: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        // System image (invisible but present for anchor extraction)
                        Image(systemName: systemImage)
                            .font(.headline)
                            .opacity(0)
                            .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                                [AnchorKeyID(kind: "destination", id: title, type: "systemImage"): anchor]
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

@available(iOS 18.0, *)
internal struct FlowingHeaderDestinationWithImage: ViewModifier {
    let title: String
    let image: Image

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        // Image (invisible but present for anchor extraction)
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .opacity(0)
                            .anchorPreference(key: AnchorKey.self, value: .bounds) { anchor in
                                [AnchorKeyID(kind: "destination", id: title, type: "image"): anchor]
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
    ///     FlowingHeaderView("Favorites", subtitle: "Your items")
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

    /// Creates destination anchors for a flowing header with a system image.
    ///
    /// Use this variant when your header includes a system image that should flow
    /// to the navigation bar. The system image will be rendered invisibly in the
    /// navigation bar as the destination anchor.
    ///
    /// ## Usage with Flowing System Image
    ///
    /// ```swift
    /// ScrollView {
    ///     FlowingHeaderView("Profile", systemImage: "person.circle", subtitle: "Settings")
    ///     // Content...
    /// }
    /// .flowingHeaderDestination("Profile", systemImage: "person.circle")
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - systemImage: The SF Symbol that should serve as the destination
    /// - Returns: A view with destination anchors for both system image and title
    func flowingHeaderDestination(_ title: String, systemImage: String) -> some View {
        modifier(FlowingHeaderDestinationWithSystemImage(title: title, systemImage: systemImage))
    }
    
    /// Creates destination anchors with optional system image.
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - systemImage: Optional SF Symbol that should serve as the destination
    /// - Returns: A view with destination anchors
    func flowingHeaderDestination(_ title: String, systemImage: String?) -> some View {
        if let systemImage = systemImage, !systemImage.isEmpty {
            return AnyView(modifier(FlowingHeaderDestinationWithSystemImage(title: title, systemImage: systemImage)))
        } else {
            return AnyView(modifier(FlowingHeaderDestination(title: title)))
        }
    }

    /// Creates destination anchors with optional image.
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - image: Optional Image that should serve as the destination
    /// - Returns: A view with destination anchors
    func flowingHeaderDestination(_ title: String, image: Image?) -> some View {
        if let image = image {
            return AnyView(modifier(FlowingHeaderDestinationWithImage(title: title, image: image)))
        } else {
            return AnyView(modifier(FlowingHeaderDestination(title: title)))
        }
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

    /// Creates destination anchors for a flowing header with multiple optional content types.
    ///
    /// This is the most flexible variant that allows you to conditionally specify
    /// different destination anchor types for dynamic header switching scenarios.
    ///
    /// ## Usage with Dynamic Content
    ///
    /// ```swift
    /// ScrollView {
    ///     // Dynamic header content...
    /// }
    /// .flowingHeaderDestination("Title",
    ///     systemImage: showIcon ? "star" : nil,
    ///     image: showImage ? Image("hero") : nil
    /// ) {
    ///     if showCustom {
    ///         CustomView()
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The title string that matches your FlowingHeaderView
    ///   - systemImage: Optional system image for the destination anchor
    ///   - image: Optional image for the destination anchor
    ///   - customView: Optional view builder for custom view destination anchor
    /// - Returns: A view with destination anchors configured based on provided parameters
    ///
    /// - Note: Only the first non-nil content parameter will be used. Priority order is:
    ///   customView > image > systemImage
    func flowingHeaderDestination<DestinationView: View>(
        _ title: String,
        systemImage: String? = nil,
        image: Image? = nil,
        @ViewBuilder customView: () -> DestinationView = { EmptyView() }
    ) -> some View {
        // Priority: customView > image > systemImage
        if DestinationView.self != EmptyView.self {
            return AnyView(modifier(FlowingHeaderDestinationWithCustomView(title: title, destinationView: customView())))
        } else if let image = image {
            return AnyView(modifier(FlowingHeaderDestinationWithImage(title: title, image: image)))
        } else if let systemImage = systemImage {
            return AnyView(modifier(FlowingHeaderDestinationWithSystemImage(title: title, systemImage: systemImage)))
        } else {
            return AnyView(modifier(FlowingHeaderDestination(title: title)))
        }
    }
}