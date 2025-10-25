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
