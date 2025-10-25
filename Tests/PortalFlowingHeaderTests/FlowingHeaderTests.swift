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
        environment.FlowingHeaderContent = config
        XCTAssertNotNil(environment.FlowingHeaderContent)
        XCTAssertEqual(environment.FlowingHeaderContent?.title, "Test")
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

    // MARK: - Mock Data Tests

    func testMockPhotoCreation() {
        let photo = FlowingHeaderExample.MockPhoto(
            name: "Test Photo",
            category: "Test Category",
            color: .blue
        )

        XCTAssertEqual(photo.name, "Test Photo")
        XCTAssertEqual(photo.category, "Test Category")
        XCTAssertNotNil(photo.id)
    }

    func testMockUserCreation() {
        let user = FlowingHeaderExample.MockUser(
            name: "Test User",
            username: "@testuser",
            bio: "Test bio",
            followers: 100,
            following: 50,
            posts: 25,
            avatar: "person.circle"
        )

        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.username, "@testuser")
        XCTAssertEqual(user.followers, 100)
        XCTAssertEqual(user.following, 50)
        XCTAssertEqual(user.posts, 25)
    }

    @MainActor
    func testSampleDataConsistency() {
        let photos = FlowingHeaderExample.samplePhotos
        let stats = FlowingHeaderExample.sampleStats
        let artwork = FlowingHeaderExample.sampleArtwork

        // Verify sample data is not empty
        XCTAssertFalse(photos.isEmpty, "Sample photos should not be empty")
        XCTAssertFalse(stats.isEmpty, "Sample stats should not be empty")
        XCTAssertFalse(artwork.isEmpty, "Sample artwork should not be empty")

        // Verify all photos have required properties
        for photo in photos {
            XCTAssertFalse(photo.name.isEmpty, "Photo name should not be empty")
            XCTAssertFalse(photo.category.isEmpty, "Photo category should not be empty")
            XCTAssertNotNil(photo.id, "Photo should have valid ID")
        }

        // Verify all stats have required properties
        for stat in stats {
            XCTAssertFalse(stat.title.isEmpty, "Stat title should not be empty")
            XCTAssertFalse(stat.value.isEmpty, "Stat value should not be empty")
            XCTAssertFalse(stat.change.isEmpty, "Stat change should not be empty")
        }

        // Verify all artwork has required properties
        for art in artwork {
            XCTAssertFalse(art.title.isEmpty, "Artwork title should not be empty")
            XCTAssertFalse(art.artist.isEmpty, "Artwork artist should not be empty")
            XCTAssertFalse(art.year.isEmpty, "Artwork year should not be empty")
            XCTAssertNotNil(art.id, "Artwork should have valid ID")
        }
    }

    @MainActor
    func testSampleDataMemoryEfficiency() {
        // Test that accessing sample data multiple times doesn't cause excessive memory usage
        let photos1 = FlowingHeaderExample.samplePhotos
        let photos2 = FlowingHeaderExample.samplePhotos

        // Should return the same instance (since it's a computed property with static data)
        XCTAssertEqual(photos1.count, photos2.count)
        XCTAssertEqual(photos1.first?.name, photos2.first?.name)
    }

    // MARK: - Example Component Tests

    @MainActor
    func testFlowingHeaderExampleCreation() {
        let example = FlowingHeaderExample()
        XCTAssertNotNil(example)
    }

    @MainActor
    func testFlowingHeaderCustomViewExampleCreation() {
        let example = FlowingHeaderCustomViewExample()
        XCTAssertNotNil(example)
    }

    @MainActor
    func testFlowingHeaderTextOnlyExampleCreation() {
        let example = FlowingHeaderTextOnlyExample()
        XCTAssertNotNil(example)
    }

    @MainActor
    func testFlowingHeaderTitleOnlyTransitionExampleCreation() {
        let example = FlowingHeaderTitleOnlyTransitionExample()
        XCTAssertNotNil(example)
    }

    @MainActor
    func testFlowingHeaderMultiStyleExampleCreation() {
        let example = FlowingHeaderMultiStyleExample()
        XCTAssertNotNil(example)
    }

    @MainActor
    func testFlowingHeaderNavigationExampleCreation() {
        let example = FlowingHeaderNavigationExample()
        XCTAssertNotNil(example)
    }

    // MARK: - Header Style Tests

    func testHeaderStyleCaseIterable() {
        let allStyles = FlowingHeaderExample.HeaderStyle.allCases
        XCTAssertEqual(allStyles.count, 3)
        XCTAssertTrue(allStyles.contains(.standard))
        XCTAssertTrue(allStyles.contains(.compact))
        XCTAssertTrue(allStyles.contains(.minimal))
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
    func testLargeSampleDataPerformance() {
        measure {
            // Test performance of accessing large sample data
            let photos = FlowingHeaderExample.samplePhotos
            _ = photos.count
            _ = photos.first?.name
            _ = photos.last?.category
        }
    }

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
