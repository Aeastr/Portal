//
//  PortalExample_List.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI
import Portal
import LogOutLoudConsole

/// PortalPrivate list example showing photo transitions in a native SwiftUI List with view mirroring
public struct PortalPrivateExample_List: View {
    @State private var selectedItem: PortalExample_ListItem?
    @State private var listItems: [PortalExample_ListItem] = PortalPrivateExample_List.generateLargeDataSet()
    @State private var showConsole = false

    public init() {}

    public var body: some View {
        PortalContainer {
            NavigationView {
                List {
                    // Explanation section
                    Section {
                        VStack(alignment: .center, spacing: 12) {
                            Text("This list contains 1000 items to test Portal's performance with large datasets. Each photo uses Portal for seamless transitions. Tap any photo to see it smoothly animate to the detail view.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    // List items
                    Section("Scenic Views") {
                        ForEach(listItems) { item in
                            HStack(spacing: 16) {
                                // Photo - PortalPrivate Source
                                AnimatedLayer(portalID: "\(item.id)") {
                                    Group {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(item.color.gradient)
                                    }
                                    .overlay(
                                        Image(systemName: item.icon)
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                    )
                                    .portalPrivate(item: item)
                                }
                                .frame(width: 60, height: 60)

                                // Content
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)

                                    Text(item.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                PortalLogs.logger.log(
                                    "Selected item \(item.title)",
                                    level: .info,
                                    tags: [PortalLogs.Tags.transition]
                                )
                                selectedItem = item
                            }
                        }
                    }
                }
                .navigationTitle("PortalPrivate Performance")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Console") {
                            PortalLogs.logger.log(
                                "Presenting log console",
                                level: .notice,
                                tags: [PortalLogs.Tags.diagnostics]
                            )
                            showConsole = true
                        }
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                PortalExample_ListDetail(item: item)
            }
            .portalPrivateTransition(
                item: $selectedItem
            )
        }
        .sheet(isPresented: $showConsole) {
            LogConsolePanel()
        }
        .logConsole(enabled: true, logger: PortalLogs.logger, maxEntries: 1_000)
        .task {
            PortalLogs.logger.log(
                "Portal list example ready",
                level: .debug,
                tags: [PortalLogs.Tags.diagnostics]
            )
        }
    }

    private static func generateLargeDataSet() -> [PortalExample_ListItem] {
        let baseItems: [(String, String, Color, String)] = [
            ("Mountain Peak", "Breathtaking views from the summit", Color.blue, "mountain.2.fill"),
            ("Ocean Waves", "Peaceful sounds of the sea", Color.cyan, "water.waves"),
            ("Forest Trail", "Winding path through ancient trees", Color.green, "tree.fill"),
            ("Desert Sunset", "Golden hour in the wilderness", Color.orange, "sun.max.fill"),
            ("City Lights", "Urban landscape at night", Color.purple, "building.2.fill"),
            ("Starry Sky", "Countless stars above", Color.indigo, "sparkles"),
            ("Autumn Leaves", "Colorful foliage in fall", Color.red, "leaf.fill"),
            ("Snow Covered", "Winter wonderland scene", Color.gray, "snowflake"),
            ("Cherry Blossoms", "Spring flowers in bloom", Color.pink, "leaf.circle.fill"),
            ("Lightning Storm", "Electric display in the sky", Color.yellow, "bolt.fill"),
            ("Coral Reef", "Underwater paradise", Color.teal, "fish.fill"),
            ("Northern Lights", "Aurora dancing overhead", Color.mint, "moon.stars.fill"),
            ("Waterfall", "Cascading water over rocks", Color.blue, "drop.fill"),
            ("Meadow Flowers", "Wildflowers in summer", Color.green, "tree"),
            ("Rocky Coast", "Waves crashing on cliffs", Color.brown, "mountain.2.circle.fill"),
            ("Foggy Morning", "Mist rolling over hills", Color.gray, "cloud.fog.fill"),
            ("Rainbow Arc", "Colors after the rain", Color.red, "rainbow"),
            ("Sand Dunes", "Endless waves of sand", Color.yellow, "triangle.fill"),
            ("Ice Cave", "Frozen crystal formations", Color.cyan, "snowflake.circle.fill"),
            ("Volcano Peak", "Majestic volcanic landscape", Color.red, "flame.fill"),
            ("Bamboo Forest", "Tall green stalks swaying", Color.green, "leaf.arrow.triangle.circlepath"),
            ("Prairie Wind", "Grass dancing in breeze", Color.yellow, "wind"),
            ("Glacier View", "Ancient ice formations", Color.blue, "snowflake.road.lane"),
            ("Sunset Beach", "Golden light on sand", Color.orange, "sun.horizon.fill"),
            ("Moonlit Lake", "Reflection on still water", Color.indigo, "moon.circle.fill")
        ]

        var items: [PortalExample_ListItem] = []

        // Generate 1000 items by repeating the base items with different suffixes
        for i in 0..<1000 {
            let baseIndex = i % baseItems.count
            let baseItem = baseItems[baseIndex]
            let suffix = i / baseItems.count + 1

            let item = PortalExample_ListItem(
                title: "\(baseItem.0) \(suffix)",
                description: "\(baseItem.1) - Item #\(i + 1)",
                color: baseItem.2,
                icon: baseItem.3
            )
            items.append(item)
        }

        return items
    }
}

/// List item model for the Portal example
public struct PortalExample_ListItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let color: Color
    public let icon: String

    public init(title: String, description: String, color: Color, icon: String) {
        self.title = title
        self.description = description
        self.color = color
        self.icon = icon
    }
}

private struct PortalExample_ListDetail: View {
    let item: PortalExample_ListItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Destination Photo
                    PortalPrivateDestination(item: item)
                        .frame(width: 280, height: 200)
                    .padding(.top, 20)

                    // Content
                    VStack(spacing: 16) {
                        Text(item.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(item.description)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Text("This photo seamlessly transitioned from the list using PortalPrivate. The view is mirrored using UIKit's portal view for true instance sharing.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Photo Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(item.color)
                }
            }
        }
    }
}

#Preview("PortalPrivate List") {
    PortalPrivateExample_List()
}

#Preview("Detail View") {
    PortalExample_ListDetail(
        item: PortalExample_ListItem(
            title: "Mountain Peak",
            description: "Breathtaking views from the summit",
            color: .blue,
            icon: "mountain.2.fill"
        )
    )
}


#endif
