//
//  PortalCoreTests.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import SwiftUI
@testable import PortalTransitions

final class PortalCoreTests: XCTestCase {
    // MARK: - Animation Tests

    func testAnimationWithCompletionCriteria() {
        // Test using SwiftUI's Animation directly with completion criteria
        let animation = Animation.spring(duration: 0.5)
        XCTAssertNotNil(animation)

        // Test completion criteria
        let criteria = AnimationCompletionCriteria.logicallyComplete
        XCTAssertEqual(criteria, .logicallyComplete)
    }

    // MARK: - PortalCorners Tests

    func testPortalCornersInitialization() {
        let corners = PortalCorners(source: 10, destination: 20, style: .continuous)

        XCTAssertEqual(corners.source, 10)
        XCTAssertEqual(corners.destination, 20)
        XCTAssertEqual(corners.style, .continuous)
    }

    func testPortalCornersDefaults() {
        let corners = PortalCorners()

        XCTAssertEqual(corners.source, 0)
        XCTAssertEqual(corners.destination, 0)
        XCTAssertEqual(corners.style, .circular)
    }


    // MARK: - PortalInfo Tests

    @MainActor
    func testPortalInfoInitialization() {
        let info = PortalInfo(id: "test-portal", groupID: "test-group")

        XCTAssertEqual(info.infoID, AnyHashable("test-portal"))
        XCTAssertEqual(info.groupID, "test-group")
        XCTAssertNil(info.sourceAnchor)
        XCTAssertNil(info.destinationAnchor)
    }

    @MainActor
    func testPortalInfoWithoutGroup() {
        let info = PortalInfo(id: "standalone-portal")

        XCTAssertEqual(info.infoID, AnyHashable("standalone-portal"))
        XCTAssertNil(info.groupID)
    }

    // MARK: - CrossModel Tests

    @MainActor
    func testCrossModelInitialization() {
        let model = CrossModel()

        XCTAssertNotNil(model)
        XCTAssertTrue(model.info.isEmpty)
    }

    @MainActor
    func testCrossModelInfoManagement() {
        let model = CrossModel()

        let info1 = PortalInfo(id: "portal-1")
        let info2 = PortalInfo(id: "portal-2", groupID: "group-1")

        model.info.append(info1)
        model.info.append(info2)

        XCTAssertEqual(model.info.count, 2)
        XCTAssertEqual(model.info[0].infoID, AnyHashable("portal-1"))
        XCTAssertEqual(model.info[1].infoID, AnyHashable("portal-2"))
        XCTAssertEqual(model.info[1].groupID, "group-1")
    }

    @MainActor
    func testCrossModelInfoRemoval() {
        let model = CrossModel()

        let info1 = PortalInfo(id: "portal-1")
        let info2 = PortalInfo(id: "portal-2")

        model.info.append(info1)
        model.info.append(info2)
        XCTAssertEqual(model.info.count, 2)

        model.info.removeAll { $0.infoID == AnyHashable("portal-1") }
        XCTAssertEqual(model.info.count, 1)
        XCTAssertEqual(model.info[0].infoID, AnyHashable("portal-2"))
    }

    // MARK: - Performance Tests
    // Note: These tests have no baseline set. Run with Xcode's performance
    // test UI to establish baselines if needed.

    func testPerformancePortalCornersCreation() {
        measure {
            for _ in 0..<1000 {
                _ = PortalCorners(source: 8, destination: 16, style: .continuous)
            }
        }
    }

    @MainActor
    func testPerformancePortalInfoCreation() {
        measure {
            for i in 0..<1000 {
                _ = PortalInfo(id: "portal-\(i)", groupID: "group-\(i % 10)")
            }
        }
    }

    // MARK: - PortalKey Tests

    func testPortalKeyEquality() {
        let key1 = PortalKey("test", role: .source)
        let key2 = PortalKey("test", role: .source)
        let key3 = PortalKey("test", role: .destination)
        let key4 = PortalKey("other", role: .source)

        XCTAssertEqual(key1, key2)
        XCTAssertNotEqual(key1, key3) // Same ID, different role
        XCTAssertNotEqual(key1, key4) // Different ID, same role
    }

    func testPortalKeyHashing() {
        let key1 = PortalKey("test", role: .source)
        let key2 = PortalKey("test", role: .source)
        let key3 = PortalKey("test", role: .destination)

        var set: Set<PortalKey> = []
        set.insert(key1)
        set.insert(key2)
        set.insert(key3)

        XCTAssertEqual(set.count, 2) // key1 and key2 are equal, key3 is different
    }

    func testPortalKeyWithDifferentHashableTypes() {
        let stringKey = PortalKey("test", role: .source)
        let uuidKey = PortalKey(UUID(), role: .source)
        let intKey = PortalKey(42, role: .source)

        // All should be valid and distinct
        var set: Set<PortalKey> = [stringKey, uuidKey, intKey]
        XCTAssertEqual(set.count, 3)
    }

    // MARK: - PortalInfo Generic ID Tests

    @MainActor
    func testPortalInfoWithUUID() {
        let uuid = UUID()
        let info = PortalInfo(id: uuid)

        XCTAssertEqual(info.infoID, AnyHashable(uuid))
    }

    @MainActor
    func testPortalInfoWithInt() {
        let info = PortalInfo(id: 42)

        XCTAssertEqual(info.infoID, AnyHashable(42))
    }

    @MainActor
    func testPortalInfoWithCustomHashable() {
        struct CustomID: Hashable {
            let value: String
        }

        let customID = CustomID(value: "custom")
        let info = PortalInfo(id: customID)

        XCTAssertEqual(info.infoID, AnyHashable(customID))
    }

    @MainActor
    func testPortalInfoDoubleWrappingPrevention() {
        let uuid = UUID()
        let wrappedOnce = AnyHashable(uuid)
        let info = PortalInfo(id: wrappedOnce)

        // Should not double-wrap - the infoID should still equal the original UUID
        XCTAssertEqual(info.infoID, AnyHashable(uuid))

        // Verify we can find it with either the wrapped or unwrapped version
        let model = CrossModel()
        model.info.append(info)

        let foundByWrapped = model.info.first { $0.infoID == wrappedOnce }
        let foundByUUID = model.info.first { $0.infoID == AnyHashable(uuid) }

        XCTAssertNotNil(foundByWrapped)
        XCTAssertNotNil(foundByUUID)
    }

    // MARK: - transferActivePortal Tests

    @MainActor
    func testTransferActivePortalWithUUIDs() {
        let model = CrossModel()
        let fromID = UUID()
        let toID = UUID()

        // Setup source portal
        var sourceInfo = PortalInfo(id: fromID)
        sourceInfo.initialized = true
        sourceInfo.animateView = true
        sourceInfo.hideView = true
        model.info.append(sourceInfo)

        // Setup destination portal
        let destInfo = PortalInfo(id: toID)
        model.info.append(destInfo)

        // Transfer
        model.transferActivePortal(from: fromID, to: toID)

        // Verify source was reset
        let source = model.info.first { $0.infoID == AnyHashable(fromID) }
        XCTAssertNotNil(source)
        XCTAssertFalse(source?.initialized ?? true)

        // Verify destination was activated
        let dest = model.info.first { $0.infoID == AnyHashable(toID) }
        XCTAssertNotNil(dest)
        XCTAssertTrue(dest?.initialized ?? false)
    }

    @MainActor
    func testTransferActivePortalWithInts() {
        let model = CrossModel()

        var sourceInfo = PortalInfo(id: 1)
        sourceInfo.initialized = true
        model.info.append(sourceInfo)

        let destInfo = PortalInfo(id: 2)
        model.info.append(destInfo)

        model.transferActivePortal(from: 1, to: 2)

        let source = model.info.first { $0.infoID == AnyHashable(1) }
        XCTAssertFalse(source?.initialized ?? true)

        let dest = model.info.first { $0.infoID == AnyHashable(2) }
        XCTAssertTrue(dest?.initialized ?? false)
    }

    @MainActor
    func testTransferActivePortalWithIdentifiableItems() {
        struct TestItem: Identifiable {
            let id = UUID()
            let name: String
        }

        let model = CrossModel()
        let item1 = TestItem(name: "Item 1")
        let item2 = TestItem(name: "Item 2")

        var sourceInfo = PortalInfo(id: item1.id)
        sourceInfo.initialized = true
        model.info.append(sourceInfo)

        let destInfo = PortalInfo(id: item2.id)
        model.info.append(destInfo)

        // Use the item-based overload
        model.transferActivePortal(fromItem: item1, toItem: item2)

        let source = model.info.first { $0.infoID == AnyHashable(item1.id) }
        XCTAssertFalse(source?.initialized ?? true)

        let dest = model.info.first { $0.infoID == AnyHashable(item2.id) }
        XCTAssertTrue(dest?.initialized ?? false)
    }

    @MainActor
    func testTransferActivePortalSameIDNoOp() {
        let model = CrossModel()
        let id = UUID()

        var info = PortalInfo(id: id)
        info.initialized = true
        model.info.append(info)

        // Transfer to same ID should be a no-op
        model.transferActivePortal(from: id, to: id)

        let result = model.info.first { $0.infoID == AnyHashable(id) }
        XCTAssertTrue(result?.initialized ?? false) // Should remain unchanged
    }

    @MainActor
    func testTransferActivePortalMissingSource() {
        let model = CrossModel()
        let fromID = UUID()
        let toID = UUID()

        // Only add destination, no source
        let destInfo = PortalInfo(id: toID)
        model.info.append(destInfo)

        // Transfer should handle missing source gracefully
        model.transferActivePortal(from: fromID, to: toID)

        // Destination should remain unchanged
        let dest = model.info.first { $0.infoID == AnyHashable(toID) }
        XCTAssertFalse(dest?.initialized ?? true)
    }
}
