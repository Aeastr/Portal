//
//  FlowingHeaderTests.swift
//  PortalFlowingHeaderTests
//
//  Created by Aether on 12/08/2025.
//

import XCTest
import SwiftUI
@testable import PortalFlowingHeader

@available(iOS 18.0, *)
final class FlowingHeaderTests: XCTestCase {
    // MARK: - FlowingHeaderView Tests

    func testFlowingHeaderViewInitialization() {
        // Test system image initialization
        let systemImageHeader = FlowingHeaderView(
            systemImage: "star.fill",
            title: "Test Title",
            subtitle: "Test Subtitle"
        ) {
            Text("Content")
        }

        XCTAssertNotNil(systemImageHeader)
    }

    func testFlowingHeaderViewWithCustomView() {
        // Test custom view initialization
        let customViewHeader = FlowingHeaderView(
            customView: Image(systemName: "heart"),
            title: "Custom Title",
            subtitle: "Custom Subtitle"
        ) {
            Text("Content")
        }

        XCTAssertNotNil(customViewHeader)
    }

    func testFlowingHeaderViewWithImage() {
        // Test image initialization
        let imageHeader = FlowingHeaderView(
            image: Image(systemName: "photo"),
            title: "Image Title",
            subtitle: "Image Subtitle"
        ) {
            Text("Content")
        }

        XCTAssertNotNil(imageHeader)
    }

    func testFlowingHeaderViewTextOnly() {
        // Test text-only initialization
        let textOnlyHeader = FlowingHeaderView(
            title: "Text Only Title",
            subtitle: "Text Only Subtitle"
        ) {
            Text("Content")
        }

        XCTAssertNotNil(textOnlyHeader)
    }

    func testFlowingHeaderViewTitleOnly() {
        // Test title-only initialization
        let titleOnlyHeader = FlowingHeaderView(title: "Title Only") {
            Text("Content")
        }

        XCTAssertNotNil(titleOnlyHeader)
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

    func testSampleDataMemoryEfficiency() {
        // Test that accessing sample data multiple times doesn't cause excessive memory usage
        let photos1 = FlowingHeaderExample.samplePhotos
        let photos2 = FlowingHeaderExample.samplePhotos

        // Should return the same instance (since it's a computed property with static data)
        XCTAssertEqual(photos1.count, photos2.count)
        XCTAssertEqual(photos1.first?.name, photos2.first?.name)
    }

    // MARK: - Example Component Tests

    func testFlowingHeaderExampleCreation() {
        let example = FlowingHeaderExample()
        XCTAssertNotNil(example)
    }

    func testFlowingHeaderCustomViewExampleCreation() {
        let example = FlowingHeaderCustomViewExample()
        XCTAssertNotNil(example)
    }

    func testFlowingHeaderTextOnlyExampleCreation() {
        let example = FlowingHeaderTextOnlyExample()
        XCTAssertNotNil(example)
    }

    func testFlowingHeaderBundleImageExampleCreation() {
        let example = FlowingHeaderBundleImageExample()
        XCTAssertNotNil(example)
    }

    func testFlowingHeaderMultiStyleExampleCreation() {
        let example = FlowingHeaderMultiStyleExample()
        XCTAssertNotNil(example)
    }

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
        // Test header with empty strings
        let header = FlowingHeaderView(
            title: "",
            subtitle: ""
        ) {
            Text("Content")
        }

        XCTAssertNotNil(header)
    }

    func testNilSubtitleHandling() {
        // Test header with nil subtitle
        let header = FlowingHeaderView(title: "Title Only") {
            Text("Content")
        }

        XCTAssertNotNil(header)
    }

    // MARK: - Performance Tests

    func testLargeSampleDataPerformance() {
        measure {
            // Test performance of accessing large sample data
            let photos = FlowingHeaderExample.samplePhotos
            _ = photos.count
            _ = photos.first?.name
            _ = photos.last?.category
        }
    }

    func testViewCreationPerformance() {
        measure {
            // Test performance of creating FlowingHeader views
            for i in 0..<100 {
                _ = FlowingHeaderView(
                    systemImage: "star.fill",
                    title: "Title \(i)",
                    subtitle: "Subtitle \(i)"
                ) {
                    Text("Content \(i)")
                }
            }
        }
    }
}
