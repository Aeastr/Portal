import XCTest
import SwiftUI
@testable import Portal

final class PortalCoreTests: XCTestCase {

    // MARK: - PortalAnimation Tests

    func testPortalAnimationInitialization() {
        let animation = PortalAnimation()

        XCTAssertNotNil(animation.value)
        XCTAssertEqual(animation.delay, 0.08)
    }

    func testPortalAnimationCustomInitialization() {
        let customAnimation = Animation.easeInOut(duration: 0.5)
        let animation = PortalAnimation(customAnimation, delay: 0.2)

        XCTAssertNotNil(animation.value)
        XCTAssertEqual(animation.delay, 0.2)
    }

    func testPortalAnimationDeprecatedDuration() {
        let animation = PortalAnimation()

        // Test deprecated duration property
        let duration = animation.duration
        XCTAssertEqual(duration, 0.38)
    }

    // MARK: - PortalAnimationWithCompletion Tests

    func testPortalAnimationWithCompletionInitialization() {
        let animation = PortalAnimationWithCompletion(
            .spring(duration: 0.5),
            delay: 0.1,
            completionCriteria: .logicallyComplete
        )

        XCTAssertNotNil(animation.value)
        XCTAssertEqual(animation.delay, 0.1)
        XCTAssertEqual(animation.completionCriteria, .logicallyComplete)
    }

    func testPortalAnimationWithCompletionDefaults() {
        let animation = PortalAnimationWithCompletion(.linear(duration: 0.3))

        XCTAssertNotNil(animation.value)
        XCTAssertEqual(animation.delay, 0.06)
        XCTAssertEqual(animation.completionCriteria, .removed)
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

    // MARK: - PortalTransitionConfig Tests

    func testPortalTransitionConfigWithPortalAnimation() {
        let animation = PortalAnimation(.spring(), delay: 0.15)
        let corners = PortalCorners(source: 8, destination: 16)
        let config = PortalTransitionConfig(animation: animation, corners: corners)

        XCTAssertNotNil(config.animation)
        XCTAssertNotNil(config.corners)
        XCTAssertEqual(config.corners?.source, 8)
        XCTAssertEqual(config.corners?.destination, 16)
    }

    func testPortalTransitionConfigWithCompletionAnimation() {
        let animation = PortalAnimationWithCompletion(
            .easeOut(duration: 0.4),
            completionCriteria: .logicallyComplete
        )
        let config = PortalTransitionConfig(animation: animation)

        XCTAssertNotNil(config.animation)
        XCTAssertNil(config.corners)
    }

    func testPortalTransitionConfigDefaults() {
        let config = PortalTransitionConfig()

        XCTAssertNotNil(config.animation)
        XCTAssertNil(config.corners)
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

    func testPerformancePortalAnimationCreation() {
        measure {
            for _ in 0..<1000 {
                _ = PortalAnimation(.spring(), delay: 0.1)
            }
        }
    }

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

    // MARK: - Protocol Conformance Tests

    func testPortalAnimationProtocolConformance() {
        let animation: PortalAnimationProtocol = PortalAnimation()
        XCTAssertNotNil(animation.value)
        XCTAssertGreaterThanOrEqual(animation.delay, 0)
    }

    func testPortalAnimationWithCompletionProtocolConformance() {
        let animation: PortalAnimationProtocol = PortalAnimationWithCompletion(.linear(duration: 0.3))
        XCTAssertNotNil(animation.value)
        XCTAssertGreaterThanOrEqual(animation.delay, 0)
    }
}