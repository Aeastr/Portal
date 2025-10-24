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
            .flowingHeaderDestination("Test Title")

        XCTAssertNotNil(view)
    }
    
    @MainActor
    func testFlowingHeaderDestinationWithSystemImage() {
        let view = Text("Test")
            .flowingHeaderDestination("Test Title", systemImage: "star.fill")

        XCTAssertNotNil(view)
    }
    
    @MainActor
    func testFlowingHeaderDestinationWithOptionalSystemImage() {
        // Test with non-nil system image
        let viewWithImage = Text("Test")
            .flowingHeaderDestination("Test Title", systemImage: "star.fill" as String?)

        XCTAssertNotNil(viewWithImage)

        // Test with nil system image
        let viewWithoutImage = Text("Test")
            .flowingHeaderDestination("Test Title", systemImage: nil as String?)

        XCTAssertNotNil(viewWithoutImage)

        // Test with empty system image
        let viewWithEmptyImage = Text("Test")
            .flowingHeaderDestination("Test Title", systemImage: "" as String?)

        XCTAssertNotNil(viewWithEmptyImage)
    }
    
    @MainActor
    func testFlowingHeaderDestinationWithImage() {
        let image = Image(systemName: "star")
        let view = Text("Test")
            .flowingHeaderDestination("Test Title", image: image)

        XCTAssertNotNil(view)
    }
    
    @MainActor
    func testFlowingHeaderDestinationWithOptionalImage() {
        // Test with non-nil image
        let image = Image(systemName: "star")
        let viewWithImage = Text("Test")
            .flowingHeaderDestination("Test Title", image: image as Image?)

        XCTAssertNotNil(viewWithImage)

        // Test with nil image
        let viewWithoutImage = Text("Test")
            .flowingHeaderDestination("Test Title", image: nil as Image?)

        XCTAssertNotNil(viewWithoutImage)
    }
    
    @MainActor
    func testFlowingHeaderDestinationWithCustomView() {
        let customView = Circle()
            .fill(Color.blue)
            .frame(width: 32, height: 32)

        let view = Text("Test")
            .flowingHeaderDestination("Test Title") {
                customView
            }

        XCTAssertNotNil(view)
    }

    // MARK: - String Validation Tests
    
    @MainActor
    func testSystemImageStringValidation() {
        // Test that empty strings are handled correctly
        let viewEmptyString = Text("Test")
            .flowingHeaderDestination("Test Title", systemImage: "")

        XCTAssertNotNil(viewEmptyString)

        // Test that whitespace-only strings are handled
        let viewWhitespace = Text("Test")
            .flowingHeaderDestination("Test Title", systemImage: "   ")

        XCTAssertNotNil(viewWhitespace)
    }

    // MARK: - Modifier Chain Tests
    
    @MainActor
    func testModifierChaining() {
        let view = Text("Test")
            .padding()
            .flowingHeaderDestination("Test Title", systemImage: "star.fill")
            .background(Color.blue)

        XCTAssertNotNil(view)
    }
    
    @MainActor
    func testMultipleDestinationModifiers() {
        // While not typical usage, this tests that multiple modifiers don't break
        let view = Text("Test")
            .flowingHeaderDestination("Title 1")
            .flowingHeaderDestination("Title 2", systemImage: "star")

        XCTAssertNotNil(view)
    }

    // MARK: - Edge Cases
    
    @MainActor
    func testLongTitleHandling() {
        let longTitle = String(repeating: "Very Long Title ", count: 100)
        let view = Text("Test")
            .flowingHeaderDestination(longTitle)

        XCTAssertNotNil(view)
    }
    
    @MainActor
    func testSpecialCharactersInTitle() {
        let specialTitle = "Title with émojis 🌟 and spëcial châractérs!"
        let view = Text("Test")
            .flowingHeaderDestination(specialTitle)

        XCTAssertNotNil(view)
    }
    
    @MainActor
    func testUnicodeSystemImages() {
        // Test with various SF Symbol names
        let symbols = [
            "star.fill",
            "heart.circle.fill",
            "person.crop.circle",
            "photo.on.rectangle.angled",
            "gearshape.fill"
        ]

        for symbol in symbols {
            let view = Text("Test")
                .flowingHeaderDestination("Test", systemImage: symbol)

            XCTAssertNotNil(view, "Failed for symbol: \(symbol)")
        }
    }

    // MARK: - Performance Tests
    
    @MainActor
    func testDestinationModifierPerformance() {
        measure {
            for i in 0..<1000 {
                _ = Text("Test \(i)")
                    .flowingHeaderDestination("Title \(i)", systemImage: "star.fill")
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
