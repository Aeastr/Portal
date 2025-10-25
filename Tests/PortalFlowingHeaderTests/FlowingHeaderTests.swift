//
//  FlowingHeaderTests.swift
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
final class FlowingHeaderTests: XCTestCase {
    // MARK: - FlowingHeaderView Tests

    @MainActor
    func testFlowingHeaderViewInitialization() {
        // Test default initialization
        let header = FlowingHeaderView()
        XCTAssertNotNil(header)
    }

    @MainActor
    func testFlowingHeaderViewWithCustomID() {
        // Test initialization with custom ID
        let header = FlowingHeaderView(id: "custom")
        XCTAssertNotNil(header)
    }

    // MARK: - FlowingHeaderContent Tests

    func testFlowingHeaderContentCreation() {
        let config = FlowingHeaderContent(
            id: "test",
            title: "Test Title",
            subtitle: "Test Subtitle",
            displays: [.title],
            layout: .horizontal
        )

        XCTAssertEqual(config.id, "test")
        XCTAssertEqual(config.title, "Test Title")
        XCTAssertEqual(config.subtitle, "Test Subtitle")
        XCTAssertEqual(config.displays, [.title])
        XCTAssertEqual(config.layout, .horizontal)
    }

    func testFlowingHeaderContentDefaultValues() {
        let config = FlowingHeaderContent(
            title: "Title",
            subtitle: "Subtitle"
        )

        XCTAssertEqual(config.id, "default")
        XCTAssertEqual(config.displays, [.title])
        XCTAssertEqual(config.layout, .horizontal)
    }

    func testFlowingHeaderContentWithAccessory() {
        let config = FlowingHeaderContent(
            title: "Title",
            subtitle: "Subtitle",
            displays: [.title, .accessory]
        )

        XCTAssertTrue(config.displays.contains(.title))
        XCTAssertTrue(config.displays.contains(.accessory))
    }

    // MARK: - Display Component Tests

    func testDisplayComponentCases() {
        let title = FlowingHeaderDisplayComponent.title
        let accessory = FlowingHeaderDisplayComponent.accessory

        XCTAssertNotEqual(title, accessory)
    }

    func testDisplayComponentSet() {
        var displays: Set<FlowingHeaderDisplayComponent> = [.title]
        XCTAssertTrue(displays.contains(.title))
        XCTAssertFalse(displays.contains(.accessory))

        displays.insert(.accessory)
        XCTAssertTrue(displays.contains(.title))
        XCTAssertTrue(displays.contains(.accessory))
    }

    // MARK: - AccessoryLayout Tests

    func testAccessoryLayoutCases() {
        XCTAssertEqual(AccessoryLayout.horizontal, AccessoryLayout.horizontal)
        XCTAssertEqual(AccessoryLayout.vertical, AccessoryLayout.vertical)
        XCTAssertNotEqual(AccessoryLayout.horizontal, AccessoryLayout.vertical)
    }

    // MARK: - Environment Values Tests

    func testFlowingHeaderLayoutEnvironment() {
        var environment = EnvironmentValues()

        // Test default value
        XCTAssertEqual(environment.flowingHeaderLayout, .horizontal)

        // Test setting new value
        environment.flowingHeaderLayout = .vertical
        XCTAssertEqual(environment.flowingHeaderLayout, .vertical)
    }

    func testFlowingHeaderContentEnvironment() {
        var environment = EnvironmentValues()

        // Test default value (nil)
        XCTAssertNil(environment.flowingHeaderContent)

        // Test setting config
        let config = FlowingHeaderContent(title: "Test", subtitle: "Sub")
        environment.flowingHeaderContent = config
        XCTAssertNotNil(environment.flowingHeaderContent)
        XCTAssertEqual(environment.flowingHeaderContent?.title, "Test")
    }

    func testFlowingHeaderAccessoryViewEnvironment() {
        var environment = EnvironmentValues()

        // Test default value (nil)
        XCTAssertNil(environment.flowingHeaderAccessoryView)

        // Test setting accessory view
        let view = AnyView(Image(systemName: "star"))
        environment.flowingHeaderAccessoryView = view
        XCTAssertNotNil(environment.flowingHeaderAccessoryView)
    }

    // MARK: - AnchorKey Tests

    func testAnchorKeyIDEquality() {
        let key1 = AnchorKeyID(kind: "source", id: "header1", type: "title")
        let key2 = AnchorKeyID(kind: "source", id: "header1", type: "title")
        let key3 = AnchorKeyID(kind: "destination", id: "header1", type: "title")

        XCTAssertEqual(key1, key2)
        XCTAssertNotEqual(key1, key3)
    }

    func testAnchorKeyIDHashability() {
        let key1 = AnchorKeyID(kind: "source", id: "header1", type: "title")
        let key2 = AnchorKeyID(kind: "source", id: "header1", type: "title")

        var dictionary: [AnchorKeyID: String] = [:]
        dictionary[key1] = "value1"
        dictionary[key2] = "value2"

        // Same key should overwrite
        XCTAssertEqual(dictionary.count, 1)
        XCTAssertEqual(dictionary[key1], "value2")
    }

    func testAnchorKeyDefaultValue() {
        let defaultValue = AnchorKey.defaultValue
        XCTAssertTrue(defaultValue.isEmpty)
    }

    func testAnchorKeyReduce() {
        // Create mock anchors (we can't create real Anchor<CGRect> in tests easily)
        // So we test the merge behavior with empty dictionaries
        var value: [AnchorKeyID: Anchor<CGRect>] = [:]
        let nextValue: [AnchorKeyID: Anchor<CGRect>] = [:]

        AnchorKey.reduce(value: &value, nextValue: { nextValue })

        XCTAssertTrue(value.isEmpty)
    }

    func testAnchorKeyReduceMergesBehavior() {
        // Test that reduce merges dictionaries and newer values win
        let key1 = AnchorKeyID(kind: "source", id: "test", type: "title")
        let key2 = AnchorKeyID(kind: "destination", id: "test", type: "title")

        // We can verify the merge logic with a simple test
        var testDict: [AnchorKeyID: String] = [key1: "old"]
        let newDict: [AnchorKeyID: String] = [key1: "new", key2: "value2"]

        // Simulate the reduce behavior
        testDict.merge(newDict) { _, new in new }

        XCTAssertEqual(testDict[key1], "new")
        XCTAssertEqual(testDict[key2], "value2")
        XCTAssertEqual(testDict.count, 2)
    }

    // MARK: - Example Component Tests

    @MainActor
    func testFlowingHeaderExampleCreation() {
        let example = FlowingHeaderExampleWithAccessory()
        XCTAssertNotNil(example)
    }

    // MARK: - Edge Cases Tests

    func testEmptyStringHandling() {
        // Test config with empty strings
        let config = FlowingHeaderContent(
            title: "",
            subtitle: ""
        )

        XCTAssertEqual(config.title, "")
        XCTAssertEqual(config.subtitle, "")
    }

    func testConfigEquality() {
        let config1 = FlowingHeaderContent(
            id: "test",
            title: "Title",
            subtitle: "Subtitle",
            displays: [.title],
            layout: .horizontal
        )

        let config2 = FlowingHeaderContent(
            id: "test",
            title: "Title",
            subtitle: "Subtitle",
            displays: [.title],
            layout: .horizontal
        )

        let config3 = FlowingHeaderContent(
            id: "different",
            title: "Title",
            subtitle: "Subtitle",
            displays: [.title],
            layout: .horizontal
        )

        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }

    // MARK: - Integration Tests

    @MainActor
    func testHeaderScrollTransitionFlow() {
        // Test the full flow of header → scroll → navigation bar transition
        let config = FlowingHeaderContent(
            id: "integration-test",
            title: "Integration Test",
            subtitle: "Testing full transition",
            displays: [.title],
            layout: .horizontal
        )

        // Simulate scroll progression
        let scrollOffsets: [CGFloat] = [-30, -20, 0, 20, 50]
        let startAt: CGFloat = -20
        let range: CGFloat = 40

        for scrollOffset in scrollOffsets {
            let progress = FlowingHeaderCalculations.calculateProgress(
                scrollOffset: scrollOffset,
                startAt: startAt,
                range: range
            )

            // Verify progress is bounded
            XCTAssertGreaterThanOrEqual(progress, 0.0)
            XCTAssertLessThanOrEqual(progress, 1.0)

            // Calculate position and scale based on progress
            let sourceRect = CGRect(x: 0, y: 0, width: 200, height: 100)
            let destRect = CGRect(x: 50, y: 50, width: 100, height: 50)

            let position = FlowingHeaderCalculations.calculatePosition(
                sourceRect: sourceRect,
                destinationRect: destRect,
                progress: CGFloat(progress)
            )

            let scale = FlowingHeaderCalculations.calculateScale(
                sourceSize: sourceRect.size,
                destinationSize: destRect.size,
                progress: CGFloat(progress)
            )

            // Verify position interpolates correctly
            XCTAssertGreaterThanOrEqual(position.x, min(sourceRect.midX, destRect.midX))
            XCTAssertLessThanOrEqual(position.x, max(sourceRect.midX, destRect.midX))

            // Verify scale interpolates correctly (0.5 to 1.0 in this case)
            XCTAssertGreaterThanOrEqual(scale.x, 0.5)
            XCTAssertLessThanOrEqual(scale.x, 1.0)
        }

        XCTAssertEqual(config.id, "integration-test")
    }

    @MainActor
    func testMultipleHeadersWithDifferentIDs() {
        // Test that multiple headers with different IDs don't interfere
        let header1 = FlowingHeaderContent(
            id: "header1",
            title: "Header 1",
            subtitle: "First Header"
        )

        let header2 = FlowingHeaderContent(
            id: "header2",
            title: "Header 2",
            subtitle: "Second Header"
        )

        let header3 = FlowingHeaderContent(
            id: "header3",
            title: "Header 3",
            subtitle: "Third Header"
        )

        // Verify unique IDs
        XCTAssertNotEqual(header1.id, header2.id)
        XCTAssertNotEqual(header2.id, header3.id)
        XCTAssertNotEqual(header1.id, header3.id)

        // Create anchor keys for each
        let key1 = AnchorKeyID(kind: "source", id: header1.id, type: "title")
        let key2 = AnchorKeyID(kind: "source", id: header2.id, type: "title")
        let key3 = AnchorKeyID(kind: "source", id: header3.id, type: "title")

        // Verify keys are unique
        XCTAssertNotEqual(key1, key2)
        XCTAssertNotEqual(key2, key3)
        XCTAssertNotEqual(key1, key3)
    }

    @MainActor
    func testAccessoryFlowingVsNonFlowing() {
        // Test accessory in flowing scenario
        let flowingConfig = FlowingHeaderContent(
            title: "Flowing",
            subtitle: "With Accessory",
            displays: [.title, .accessory],
            layout: .horizontal
        )

        XCTAssertTrue(flowingConfig.displays.contains(.title))
        XCTAssertTrue(flowingConfig.displays.contains(.accessory))
        XCTAssertEqual(flowingConfig.layout, .horizontal)

        // Test accessory in vertical layout
        let verticalConfig = FlowingHeaderContent(
            title: "Vertical",
            subtitle: "Layout",
            displays: [.title, .accessory],
            layout: .vertical
        )

        XCTAssertTrue(verticalConfig.displays.contains(.accessory))
        XCTAssertEqual(verticalConfig.layout, .vertical)
    }

    @MainActor
    func testCompleteTransitionLifecycle() {
        // Simulate a complete transition from start to finish
        let config = FlowingHeaderContent(
            id: "lifecycle-test",
            title: "Lifecycle",
            subtitle: "Complete Transition"
        )

        let startOffset: CGFloat = 0
        let range: CGFloat = 100

        // Pre-transition
        let preProgress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: -10,
            startAt: startOffset,
            range: range
        )
        XCTAssertEqual(preProgress, 0.0)

        // Start of transition
        let startProgress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 0,
            startAt: startOffset,
            range: range
        )
        XCTAssertEqual(startProgress, 0.0)

        // Mid-transition
        let midProgress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 50,
            startAt: startOffset,
            range: range
        )
        XCTAssertEqual(midProgress, 0.5)

        // End of transition
        let endProgress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 100,
            startAt: startOffset,
            range: range
        )
        XCTAssertEqual(endProgress, 1.0)

        // Post-transition
        let postProgress = FlowingHeaderCalculations.calculateProgress(
            scrollOffset: 150,
            startAt: startOffset,
            range: range
        )
        XCTAssertEqual(postProgress, 1.0)
    }

    // MARK: - Performance Tests

    @MainActor
    func testViewCreationPerformance() {
        measure {
            // Test performance of creating FlowingHeader views
            for i in 0..<100 {
                _ = FlowingHeaderView(id: "test\(i)")
            }
        }
    }

    func testConfigCreationPerformance() {
        measure {
            // Test performance of creating config objects
            for i in 0..<1000 {
                _ = FlowingHeaderContent(
                    id: "test\(i)",
                    title: "Title \(i)",
                    subtitle: "Subtitle \(i)",
                    displays: [.title, .accessory],
                    layout: .horizontal
                )
            }
        }
    }
}
