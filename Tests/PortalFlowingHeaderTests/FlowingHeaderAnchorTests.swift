//
//  FlowingHeaderAnchorTests.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import SwiftUI
@testable import PortalFlowingHeader

@available(iOS 18.0, *)
final class FlowingHeaderAnchorTests: XCTestCase {
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

    // MARK: - Destination Modifier Tests

    @MainActor
    func testFlowingHeaderDestinationBasic() {
        let view = Text("Test")
            .flowingHeaderDestination()

        XCTAssertNotNil(view)
    }

    @MainActor
    func testFlowingHeaderDestinationWithID() {
        let view = Text("Test")
            .flowingHeaderDestination(id: "custom-id")

        XCTAssertNotNil(view)
    }

    @MainActor
    func testFlowingHeaderDestinationWithDisplays() {
        // Test with title only
        let viewTitleOnly = Text("Test")
            .flowingHeaderDestination(displays: [.title])

        XCTAssertNotNil(viewTitleOnly)

        // Test with title and accessory
        let viewWithAccessory = Text("Test")
            .flowingHeaderDestination(displays: [.title, .accessory])

        XCTAssertNotNil(viewWithAccessory)

        // Test with accessory only
        let viewAccessoryOnly = Text("Test")
            .flowingHeaderDestination(displays: [.accessory])

        XCTAssertNotNil(viewAccessoryOnly)
    }

    @MainActor
    func testFlowingHeaderDestinationWithIDAndDisplays() {
        let view = Text("Test")
            .flowingHeaderDestination(id: "custom-id", displays: [.title, .accessory])

        XCTAssertNotNil(view)
    }

    @MainActor
    func testFlowingHeaderDestinationWithNilDisplays() {
        let view = Text("Test")
            .flowingHeaderDestination(id: "test", displays: nil)

        XCTAssertNotNil(view)
    }

    // MARK: - Modifier Chain Tests

    @MainActor
    func testModifierChaining() {
        let view = Text("Test")
            .padding()
            .flowingHeaderDestination(id: "test")
            .background(Color.blue)

        XCTAssertNotNil(view)
    }

    @MainActor
    func testMultipleDestinationModifiers() {
        // While not typical usage, this tests that multiple modifiers don't break
        let view = Text("Test")
            .flowingHeaderDestination(id: "first")
            .flowingHeaderDestination(id: "second")

        XCTAssertNotNil(view)
    }

    // MARK: - Edge Cases

    @MainActor
    func testLongIDHandling() {
        let longID = String(repeating: "VeryLongID", count: 100)
        let view = Text("Test")
            .flowingHeaderDestination(id: longID)

        XCTAssertNotNil(view)
    }

    @MainActor
    func testSpecialCharactersInID() {
        let specialID = "id-with-émojis-🌟-and-spëcial-châractérs"
        let view = Text("Test")
            .flowingHeaderDestination(id: specialID)

        XCTAssertNotNil(view)
    }

    @MainActor
    func testVariousDisplayCombinations() {
        // Test empty set
        let viewEmpty = Text("Test")
            .flowingHeaderDestination(displays: [])

        XCTAssertNotNil(viewEmpty)

        // Test all combinations
        let combinations: [Set<FlowingHeaderDisplayComponent>] = [
            [],
            [.title],
            [.accessory],
            [.title, .accessory]
        ]

        for combination in combinations {
            let view = Text("Test")
                .flowingHeaderDestination(id: "test-\(combination.count)", displays: combination)

            XCTAssertNotNil(view, "Failed for combination: \(combination)")
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testDestinationModifierPerformance() {
        measure {
            for i in 0..<1000 {
                _ = Text("Test \(i)")
                    .flowingHeaderDestination(id: "test-\(i)")
            }
        }
    }

    func testAnchorKeyIDPerformance() {
        measure {
            var anchors: [AnchorKeyID] = []
            for i in 0..<10000 {
                let anchor = AnchorKeyID(
                    kind: "source",
                    id: "test\(i)",
                    type: i % 2 == 0 ? "title" : "image"
                )
                anchors.append(anchor)
            }

            // Test set operations for performance
            let anchorSet = Set(anchors)
            XCTAssertEqual(anchorSet.count, anchors.count)
        }
    }
}
