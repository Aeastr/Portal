//
//  FlowingHeaderSupport.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
//

import SwiftUI

// MARK: - Internal Support Types

/// Content info carried with anchor data for flowing header transitions.
internal struct FlowingHeaderContent: Hashable {
    let title: String
    let systemImage: String?
    let image: String? // We'll store image name/identifier as string for hashability
    let hasCustomView: Bool
}

/// A unique identifier for anchor preferences used in flowing header transitions.
///
/// This type combines components to create unique keys for tracking UI elements:
/// - `id`: The unique identifier (title) for matching source/destination pairs
/// - `kind`: Whether this is a "source" or "destination" anchor
/// - `type`: The element type ("title" or "accessory")
internal struct AnchorKeyID: Hashable {
    let id: String
    let kind: String
    let type: String
}

/// Extended anchor data that includes both bounds and content info.
internal struct AnchorData {
    let anchor: Anchor<CGRect>
    let content: FlowingHeaderContent
}

/// Preference key for collecting anchor bounds and content during flowing header transitions.
///
/// This preference key accumulates anchor bounds from both source (header content)
/// and destination (navigation bar) locations along with content information.
/// Uses an array to preserve the order anchors are added in the view hierarchy.
internal struct AnchorKey: PreferenceKey {
    typealias Value = [(key: AnchorKeyID, data: AnchorData)]
    nonisolated(unsafe) static var defaultValue: [(key: AnchorKeyID, data: AnchorData)] = []

    static func reduce(
        value: inout [(key: AnchorKeyID, data: AnchorData)],
        nextValue: () -> [(key: AnchorKeyID, data: AnchorData)]
    ) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Environment Values

/// Environment key for tracking title transition progress.
///
/// This key stores a `Double` value from 0.0 to 1.0 representing how far
/// the header has transitioned toward the navigation bar state.
private struct TitleProgressKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}

/// Environment key for tracking whether the system image is flowing.
private struct SystemImageFlowingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

/// Environment key for tracking whether the image is flowing.
private struct ImageFlowingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

/// Environment key for tracking whether a custom view is flowing.
private struct CustomViewFlowingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// The current progress of the flowing header transition.
    ///
    /// This value ranges from 0.0 (header fully visible) to 1.0 (header fully
    /// transitioned to navigation bar). Views can use this to create custom
    /// animations that sync with the header transition.
    internal var titleProgress: Double {
        get { self[TitleProgressKey.self] }
        set { self[TitleProgressKey.self] = newValue }
    }
    
    /// Whether the system image is configured to flow to the navigation bar.
    internal var systemImageFlowing: Bool {
        get { self[SystemImageFlowingKey.self] }
        set { self[SystemImageFlowingKey.self] = newValue }
    }
    
    /// Whether the image is configured to flow to the navigation bar.
    internal var imageFlowing: Bool {
        get { self[ImageFlowingKey.self] }
        set { self[ImageFlowingKey.self] = newValue }
    }
    
    /// Whether the custom view is configured to flow to the navigation bar.
    internal var customViewFlowing: Bool {
        get { self[CustomViewFlowingKey.self] }
        set { self[CustomViewFlowingKey.self] = newValue }
    }
}