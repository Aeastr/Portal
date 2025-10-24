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
@testable import Portal

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

        XCTAssertEqual(info.infoID, "test-portal")
        XCTAssertEqual(info.groupID, "test-group")
        XCTAssertNil(info.sourceAnchor)
        XCTAssertNil(info.destinationAnchor)
    }

    @MainActor
    func testPortalInfoWithoutGroup() {
        let info = PortalInfo(id: "standalone-portal")

        XCTAssertEqual(info.infoID, "standalone-portal")
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
        XCTAssertEqual(model.info[0].infoID, "portal-1")
        XCTAssertEqual(model.info[1].infoID, "portal-2")
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

        model.info.removeAll { $0.infoID == "portal-1" }
        XCTAssertEqual(model.info.count, 1)
        XCTAssertEqual(model.info[0].infoID, "portal-2")
    }

    // MARK: - Performance Tests

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

}
