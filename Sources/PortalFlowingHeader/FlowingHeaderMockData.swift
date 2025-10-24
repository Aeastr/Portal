//
//  FlowingHeaderMockData.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Mock data structures for FlowingHeader examples
@available(iOS 18.0, *)
public extension FlowingHeaderExample {
    /// A mock photo with basic properties for demonstration purposes
    struct MockPhoto: Identifiable {
        public let id = UUID()
        let name: String
        let category: String
        let color: Color
    }

    /// Mock user data
    struct MockUser {
        let name: String
        let username: String
        let bio: String
        let followers: Int
        let following: Int
        let posts: Int
        let avatar: String
    }

    /// Mock statistics data
    struct MockStats {
        let title: String
        let value: String
        let change: String
        let color: Color
    }

    /// Mock artwork data for gallery examples
    struct MockArtwork: Identifiable {
        public let id = UUID()
        let title: String
        let artist: String
        let year: String
        let color: Color
    }

    /// Header style variations for multi-style example
    enum HeaderStyle: CaseIterable {
        case standard, compact, minimal
    }
}

/// Sample data collections - lazily computed to reduce memory impact
@available(iOS 18.0, *)
public extension FlowingHeaderExample {
    /// Sample photos for gallery examples
    /// Note: Lazily computed to reduce initial memory footprint
    static var samplePhotos: [MockPhoto] {
        [
            MockPhoto(name: "Sunset Lake", category: "Nature", color: .orange),
            MockPhoto(name: "City Lights", category: "Street", color: .purple),
            MockPhoto(name: "Modern Building", category: "Architecture", color: .blue),
            MockPhoto(name: "Forest Path", category: "Nature", color: .green),
            MockPhoto(name: "Portrait Study", category: "Portrait", color: .pink),
            MockPhoto(name: "Desert Dunes", category: "Nature", color: .yellow),
            MockPhoto(name: "Abstract Art", category: "Art", color: .red),
            MockPhoto(name: "Mountain Peak", category: "Nature", color: .cyan),
            MockPhoto(name: "Urban Life", category: "Street", color: .indigo),
            MockPhoto(name: "Coastal View", category: "Nature", color: .teal),
            MockPhoto(name: "Winter Scene", category: "Nature", color: .mint),
            MockPhoto(name: "Cultural Event", category: "Event", color: .orange),
            MockPhoto(name: "Tech Innovation", category: "Technology", color: .purple),
            MockPhoto(name: "Food Photography", category: "Food", color: .brown),
            MockPhoto(name: "Sports Action", category: "Sports", color: .green),
            MockPhoto(name: "Travel Memory", category: "Travel", color: .blue),
            MockPhoto(name: "Family Time", category: "Family", color: .pink),
            MockPhoto(name: "Creative Process", category: "Art", color: .yellow),
            MockPhoto(name: "Night Sky", category: "Nature", color: .indigo),
            MockPhoto(name: "Historic Place", category: "History", color: .brown),
            MockPhoto(name: "Fashion Style", category: "Fashion", color: .purple),
            MockPhoto(name: "Garden Beauty", category: "Nature", color: .green),
            MockPhoto(name: "Music Performance", category: "Music", color: .orange),
            MockPhoto(name: "Science Discovery", category: "Science", color: .cyan),
            MockPhoto(name: "Artistic Expression", category: "Art", color: .red),
            MockPhoto(name: "Adventure Time", category: "Adventure", color: .mint),
            MockPhoto(name: "Cultural Heritage", category: "Culture", color: .teal),
            MockPhoto(name: "Innovation Lab", category: "Technology", color: .blue),
            MockPhoto(name: "Natural Wonder", category: "Nature", color: .green),
            MockPhoto(name: "Creative Vision", category: "Art", color: .pink)
        ]
    }

    /// Sample user data
    static let sampleUser = MockUser(
        name: "Jane Photographer",
        username: "@janephoto",
        bio: "📷 Capturing moments that matter\n🌍 Travel & Nature Photography\n✨ Available for commissioned work",
        followers: 12543,
        following: 892,
        posts: 1247,
        avatar: "person.crop.circle.fill"
    )

    /// Sample statistics data
    static var sampleStats: [MockStats] {
        [
            MockStats(title: "Revenue", value: "$24,500", change: "+12.5%", color: .green),
            MockStats(title: "Users", value: "1,234", change: "+8.2%", color: .blue),
            MockStats(title: "Conversion", value: "3.45%", change: "-0.3%", color: .orange),
            MockStats(title: "Sessions", value: "12,890", change: "+15.7%", color: .purple)
        ]
    }

    /// Sample artwork data
    static var sampleArtwork: [MockArtwork] {
        [
            MockArtwork(title: "Digital Harmony", artist: "Alex Chen", year: "2024", color: .blue),
            MockArtwork(title: "Urban Flow", artist: "Sam Rivera", year: "2023", color: .orange),
            MockArtwork(title: "Nature's Code", artist: "Taylor Kim", year: "2024", color: .green),
            MockArtwork(title: "Light Patterns", artist: "Jordan Lee", year: "2023", color: .purple),
            MockArtwork(title: "Abstract Motion", artist: "Casey Brown", year: "2024", color: .red),
            MockArtwork(title: "Geometric Dreams", artist: "Robin Garcia", year: "2023", color: .cyan)
        ]
    }
}
