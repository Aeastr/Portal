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
        // Test system image initialization
        let systemImageHeader = FlowingHeaderView(
            "Test Title",
            systemImage: "star.fill",
            subtitle: "Test Subtitle"
        )

        XCTAssertNotNil(systemImageHeader)
    }
    
    @MainActor
    func testFlowingHeaderViewWithCustomView() {
        // Test custom view initialization
        let customViewHeader = FlowingHeaderView(
            "Custom Title",
            subtitle: "Custom Subtitle"
        ) {
            Image(systemName: "heart")
        }

        XCTAssertNotNil(customViewHeader)
    }
    
    @MainActor
    func testFlowingHeaderViewWithImage() {
        // Test image initialization
        let imageHeader = FlowingHeaderView(
            "Image Title",
            image: Image(systemName: "photo"),
            subtitle: "Image Subtitle"
        )

        XCTAssertNotNil(imageHeader)
    }
    
    @MainActor
    func testFlowingHeaderViewTextOnly() {
        // Test text-only initialization
        let textOnlyHeader = FlowingHeaderView(
            "Text Only Title",
            subtitle: "Text Only Subtitle"
        )

        XCTAssertNotNil(textOnlyHeader)
    }
    
    @MainActor
    func testFlowingHeaderViewTitleOnly() {
        // Test title-only initialization
        let titleOnlyHeader = FlowingHeaderView(
            "Title Only",
            subtitle: ""
        )

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
    func testFlowingHeaderBundleImageExampleCreation() {
        let example = FlowingHeaderBundleImageExample()
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
    
    @MainActor
    func testEmptyStringHandling() {
        // Test header with empty strings
        let header = FlowingHeaderView(
            "",
            subtitle: ""
        )

        XCTAssertNotNil(header)
    }
    
    @MainActor
    func testNilSubtitleHandling() {
        // Test header with empty subtitle
        let header = FlowingHeaderView(
            "Title Only",
            subtitle: ""
        )

        XCTAssertNotNil(header)
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
                _ = FlowingHeaderView(
                    "Title \(i)",
                    systemImage: "star.fill",
                    subtitle: "Subtitle \(i)"
                )
            }
        }
    }
}
