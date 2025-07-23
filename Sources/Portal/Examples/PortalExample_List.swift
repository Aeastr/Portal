#if DEBUG
import SwiftUI

/// Portal list example showing photo transitions in a native SwiftUI List
@available(iOS 15.0, *)
public struct PortalExample_List: View {
    @State private var selectedItem: PortalExample_ListItem? = nil
    @State private var listItems: [PortalExample_ListItem] = PortalExample_List.generateLargeDataSet()
    
    public init() {}
    
    public var body: some View {
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
                                if #available(iOS 16.0, *) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(item.color.gradient)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(item.color)
                                }
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
                            selectedItem = item
                        }
                    }
                }
            }
            .navigationTitle("Portal Performance Test")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .sheet(item: $selectedItem) { item in
            PortalExample_ListDetail(item: item)
        }
        .portalTransition(
            item: $selectedItem,
            config: .init(
                animation: PortalAnimation(portal_animationExample)
            )
        ) { item in
            
            Group {
                if #available(iOS 16.0, *) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color.gradient)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color)
                }
            }
            .overlay(
                Image(systemName: item.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            )
            
        }
        .portalContainer()
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
@available(iOS 15.0, *)
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

@available(iOS 15.0, *)
private struct PortalExample_ListDetail: View {
    let item: PortalExample_ListItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Destination Photo
                    
                    Group {
                        if #available(iOS 16.0, *) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(item.color.gradient)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(item.color)
                        }
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
    PortalExample_List()
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
    .portalContainer()
}


#endif
