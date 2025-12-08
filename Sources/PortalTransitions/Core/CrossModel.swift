//
//  CrossModel.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

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

    /// Transfers the active portal state from one ID to another without animation.
    ///
    /// Use this when the user navigates between items in a detail view (e.g., a carousel)
    /// and you want the dismiss animation to return to the new item's source position
    /// rather than the original item.
    ///
    /// This method:
    /// 1. Cleans up the old portal's state (resets it to uninitialized)
    /// 2. Sets up the new portal as if it was already transitioned (ready for reverse animation)
    ///
    /// - Parameters:
    ///   - fromID: The ID of the currently active portal to deactivate
    ///   - toID: The ID of the new portal to activate
    ///
    /// Example usage:
    /// ```swift
    /// // For static string IDs:
    /// portalModel.transferActivePortal(from: "panel1", to: "panel2")
    ///
    /// // For Identifiable items, prefer the type-safe overload:
    /// portalModel.transferActivePortal(from: oldItem, to: newItem)
    /// ```
    public func transferActivePortal<ID: Hashable>(from fromID: ID, to toID: ID) {
        let fromKey = AnyHashable(fromID)
        let toKey = AnyHashable(toID)

        guard fromKey != toKey else { return }

        // Find the source portal and copy its configuration
        guard let fromIndex = info.firstIndex(where: { $0.infoID == fromKey }) else {
            PortalLogs.logger.log(
                "Transfer failed: source portal not found",
                level: .warning,
                tags: [PortalLogs.Tags.transition],
                metadata: ["fromID": String(reflecting: fromID), "toID": String(reflecting: toID)]
            )
            return
        }

        let sourceInfo = info[fromIndex]

        // Create or update the destination portal
        if let toIndex = info.firstIndex(where: { $0.infoID == toKey }) {
            // Transfer state to existing portal
            info[toIndex].initialized = true
            info[toIndex].animateView = true
            info[toIndex].hideView = true
            info[toIndex].showLayer = false
            info[toIndex].animation = sourceInfo.animation
            info[toIndex].completionCriteria = sourceInfo.completionCriteria
            info[toIndex].corners = sourceInfo.corners
            info[toIndex].fade = sourceInfo.fade
            info[toIndex].completion = sourceInfo.completion
            info[toIndex].layerView = sourceInfo.layerView
        } else {
            // Create new portal info with transferred state
            var newInfo = PortalInfo(id: toKey)
            newInfo.initialized = true
            newInfo.animateView = true
            newInfo.hideView = true
            newInfo.showLayer = false
            newInfo.animation = sourceInfo.animation
            newInfo.completionCriteria = sourceInfo.completionCriteria
            newInfo.corners = sourceInfo.corners
            newInfo.fade = sourceInfo.fade
            newInfo.completion = sourceInfo.completion
            newInfo.layerView = sourceInfo.layerView
            info.append(newInfo)
        }

        // Reset the source portal
        info[fromIndex].initialized = false
        info[fromIndex].animateView = false
        info[fromIndex].hideView = false
        info[fromIndex].showLayer = false
        info[fromIndex].layerView = nil
        info[fromIndex].sourceAnchor = nil
        info[fromIndex].destinationAnchor = nil
        info[fromIndex].cachedSourceAnchor = nil
        info[fromIndex].cachedDestinationAnchor = nil

        PortalLogs.logger.log(
            "Transferred active portal",
            level: .notice,
            tags: [PortalLogs.Tags.transition],
            metadata: ["fromID": String(reflecting: fromID), "toID": String(reflecting: toID)]
        )
    }

    /// Transfers the active portal state from one `Identifiable` item to another.
    ///
    /// This is a convenience method that extracts the IDs from the provided items.
    /// Uses distinct parameter labels (`fromItem`/`toItem`) to avoid a Swift compiler
    /// crash in Xcode 26.1+ that occurs with the `from`/`to` overload pattern.
    ///
    /// - Parameters:
    ///   - fromItem: The item whose portal should be deactivated
    ///   - toItem: The item whose portal should be activated
    public func transferActivePortal<Item: Identifiable>(fromItem: Item, toItem: Item) {
        transferActivePortal(from: fromItem.id, to: toItem.id)
    }

    // MARK: - Disabled Overload (Swift Compiler Crash)

    // This overload causes a Swift compiler crash in Xcode 26.1+ when:
    // 1. You have a @Binding var of the same Identifiable type
    // 2. You call this method
    // 3. You assign to the binding AFTER the call
    //
    // Using distinct parameter labels (`fromItem`/`toItem` above) avoids the crash.
    //
    // Radar: FB00000000
    //
    // To check if fixed: Uncomment the overload below and run the test target.
    // If CompilerCrashTests passes, the bug is fixed and this can be re-enabled.
    //
    // public func transferActivePortal<Item: Identifiable>(from fromItem: Item, to toItem: Item) {
    //     transferActivePortal(from: fromItem.id, to: toItem.id)
    // }
}
