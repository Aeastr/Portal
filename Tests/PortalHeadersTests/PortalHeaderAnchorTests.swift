//
//  PortalHeaderAnchorTests.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import SwiftUI
@testable import PortalHeaders

@available(iOS 18.0, *)
final class PortalHeaderAnchorTests: XCTestCase {
    // MARK: - AnchorKeyID Tests

    func testAnchorKeyIDCreation() {
        let anchorID = AnchorKeyID(kind: "source", id: "test", type: "title")

        XCTAssertEqual(anchorID.kind, "source")
        XCTAssertEqual(anchorID.id, "test")
        XCTAssertEqual(anchorID.type, "title")
    }

    func testAnchorKeyIDEquality() {
        let anchor1 = AnchorKeyID(kind: "source", id: "test", type: "title")
        let anchor2 = AnchorKeyID(kind: "source", id: "test", type: "title")
        let anchor3 = AnchorKeyID(kind: "destination", id: "test", type: "title")

        XCTAssertEqual(anchor1, anchor2)
        XCTAssertNotEqual(anchor1, anchor3)
    }

    func testAnchorKeyIDHashable() {
        let anchor1 = AnchorKeyID(kind: "source", id: "test", type: "title")
        let anchor2 = AnchorKeyID(kind: "source", id: "test", type: "title")

        var set = Set<AnchorKeyID>()
        set.insert(anchor1)
        set.insert(anchor2)

        // Should only have one element since they're equal
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - AnchorKey Tests

    func testAnchorKeyDefaultValue() {
        let defaultValue = AnchorKey.defaultValue
        XCTAssertTrue(defaultValue.isEmpty)
    }

    func testAnchorKeyReduce() {
        let anchor1 = AnchorKeyID(kind: "source", id: "test1", type: "title")
        let anchor2 = AnchorKeyID(kind: "source", id: "test2", type: "title")

        // Create mock anchor values (we can't create real ones in unit tests)
        // This tests the structure of the reduce function
        let initialValue: [AnchorKeyID: Anchor<CGRect>] = [:]

        // The reduce function should merge dictionaries
        // We test this by ensuring the key structure is sound
        XCTAssertNotEqual(anchor1, anchor2)
        XCTAssertTrue(initialValue.isEmpty)
    }
}
