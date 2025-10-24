//
//  PortalExampleList.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI
import LogOutLoudConsole

/// Portal list example showing photo transitions in a native SwiftUI List
public struct PortalExampleList: View {
    @State private var selectedItem: PortalExampleListItem?
    @State private var listItems: [PortalExampleListItem] = PortalExampleList.generateLargeDataSet()
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
                                // Photo - Portal Source

                                Group {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(item.color.gradient)
                                }
                                .overlay(
                                    Image(systemName: item.icon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white)
                                )

                                .frame(width: 60, height: 60)
                                .portal(item: item, .source)

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
                .navigationTitle("Portal Performance Test")
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
                PortalExampleListDetail(item: item)
            }
            .portalTransition(
                item: $selectedItem,
                config: .init(
                    animation: PortalAnimation(portal_animationExample)
                )
            ) { item in
                Group {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color.gradient)
                }
                .overlay(
                    Image(systemName: item.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                )
            }
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

    private struct ItemData {
        let title: String
        let subtitle: String
        let color: Color
        let icon: String
    }

    private static func generateLargeDataSet() -> [PortalExampleListItem] {
        let baseItems: [ItemData] = [
            ItemData(title: "Mountain Peak", subtitle: "Breathtaking views from the summit", color: .blue, icon: "mountain.2.fill"),
            ItemData(title: "Ocean Waves", subtitle: "Peaceful sounds of the sea", color: .cyan, icon: "water.waves"),
            ItemData(title: "Forest Trail", subtitle: "Winding path through ancient trees", color: .green, icon: "tree.fill"),
            ItemData(title: "Desert Sunset", subtitle: "Golden hour in the wilderness", color: .orange, icon: "sun.max.fill"),
            ItemData(title: "City Lights", subtitle: "Urban landscape at night", color: .purple, icon: "building.2.fill"),
            ItemData(title: "Starry Sky", subtitle: "Countless stars above", color: .indigo, icon: "sparkles"),
            ItemData(title: "Autumn Leaves", subtitle: "Colorful foliage in fall", color: .red, icon: "leaf.fill"),
            ItemData(title: "Snow Covered", subtitle: "Winter wonderland scene", color: .gray, icon: "snowflake"),
            ItemData(title: "Cherry Blossoms", subtitle: "Spring flowers in bloom", color: .pink, icon: "leaf.circle.fill"),
            ItemData(title: "Lightning Storm", subtitle: "Electric display in the sky", color: .yellow, icon: "bolt.fill"),
            ItemData(title: "Coral Reef", subtitle: "Underwater paradise", color: .teal, icon: "fish.fill"),
            ItemData(title: "Northern Lights", subtitle: "Aurora dancing overhead", color: .mint, icon: "moon.stars.fill"),
            ItemData(title: "Waterfall", subtitle: "Cascading water over rocks", color: .blue, icon: "drop.fill"),
            ItemData(title: "Meadow Flowers", subtitle: "Wildflowers in summer", color: .green, icon: "tree"),
            ItemData(title: "Rocky Coast", subtitle: "Waves crashing on cliffs", color: .brown, icon: "mountain.2.circle.fill"),
            ItemData(title: "Foggy Morning", subtitle: "Mist rolling over hills", color: .gray, icon: "cloud.fog.fill"),
            ItemData(title: "Rainbow Arc", subtitle: "Colors after the rain", color: .red, icon: "rainbow"),
            ItemData(title: "Sand Dunes", subtitle: "Endless waves of sand", color: .yellow, icon: "triangle.fill"),
            ItemData(title: "Ice Cave", subtitle: "Frozen crystal formations", color: .cyan, icon: "snowflake.circle.fill"),
            ItemData(title: "Volcano Peak", subtitle: "Majestic volcanic landscape", color: .red, icon: "flame.fill"),
            ItemData(title: "Bamboo Forest", subtitle: "Tall green stalks swaying", color: .green, icon: "leaf.arrow.triangle.circlepath"),
            ItemData(title: "Prairie Wind", subtitle: "Grass dancing in breeze", color: .yellow, icon: "wind"),
            ItemData(title: "Glacier View", subtitle: "Ancient ice formations", color: .blue, icon: "snowflake.road.lane"),
            ItemData(title: "Sunset Beach", subtitle: "Golden light on sand", color: .orange, icon: "sun.horizon.fill"),
            ItemData(title: "Moonlit Lake", subtitle: "Reflection on still water", color: .indigo, icon: "moon.circle.fill")
        ]

        var items: [PortalExampleListItem] = []

        // Generate 1000 items by repeating the base items with different suffixes
        for i in 0..<1000 {
            let baseIndex = i % baseItems.count
            let baseItem = baseItems[baseIndex]
            let suffix = i / baseItems.count + 1

            let item = PortalExampleListItem(
                title: "\(baseItem.title) \(suffix)",
                description: "\(baseItem.subtitle) - Item #\(i + 1)",
                color: baseItem.color,
                icon: baseItem.icon
            )
            items.append(item)
        }

        return items
    }
}

/// List item model for the Portal example
public struct PortalExampleListItem: Identifiable {
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

private struct PortalExampleListDetail: View {
    let item: PortalExampleListItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Destination Photo

                    Group {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.color.gradient)
                    }
                    .overlay(
                        Image(systemName: item.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    )

                    .frame(width: 280, height: 200)
                    .portal(item: item, .destination)
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

                        Text("This photo seamlessly transitioned from the list using Portal. The same visual element now appears larger in this detail view, creating a smooth and natural user experience.")
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

#Preview("List Example") {
    PortalExampleList()
}

#Preview("Detail View") {
    PortalExampleListDetail(
        item: PortalExampleListItem(
            title: "Mountain Peak",
            description: "Breathtaking views from the summit",
            color: .blue,
            icon: "mountain.2.fill"
        )
    )
}


#endif
