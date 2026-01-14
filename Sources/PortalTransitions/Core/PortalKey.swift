//
//  PortalKey.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// A type-safe key for identifying portal anchors.
///
/// `PortalKey` combines a hashable identifier with a portal role to create unique keys
/// for the anchor preference system. This replaces the previous string-based approach
/// that used string concatenation (e.g., `"\(id)DEST"`) to distinguish source and destination.
///
/// Using `AnyHashable` for the ID allows any `Hashable` type to be used as a portal identifier,
/// including `String`, `UUID`, `Int`, or custom types.
public struct PortalKey: Hashable {
    
    /// The portal identifier, type-erased to support any `Hashable` type.
    public let id: AnyHashable

    /// The role of this portal (source or destination).
    public let role: PortalRole
    
    /// The operating namespace of this portal
    public let namespace: Namespace.ID

    /// Creates a portal key with the specified identifier and role.
    ///
    /// - Parameters:
    ///   - id: A hashable identifier for the portal.
    ///   - role: The role of this portal anchor.
    public init<ID: Hashable>(_ id: ID, role: PortalRole, in namespace: Namespace.ID) {
        self.id = AnyHashable(id)
        self.role = role
        self.namespace = namespace
    }
}
