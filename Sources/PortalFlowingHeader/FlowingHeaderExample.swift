//
//  FlowingHeaderExample.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
//

import SwiftUI

// MARK: - Main Example Views

@available(iOS 18.0, *)
public struct FlowingHeaderExample: View {
    @State private var photos = MockPhoto.samplePhotos
    @State private var selectedTag = "All"
    @State private var iconFlows = false
    
    private let tags = ["All", "Nature", "Architecture", "Street", "Portrait"]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Flowing header with system image accessory
                    FlowingHeaderView(
                        "Photos",
                        systemImage: "camera.fill", 
                        subtitle: "\(photos.count) memories captured"
                    )
                    .tint(.purple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    
                    // Filter tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(tags, id: \.self) { tag in
                                TagButton(
                                    tag: tag,
                                    isSelected: selectedTag == tag,
                                    action: { selectedTag = tag }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 20)
                    
                    // Photo grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(filteredPhotos) { photo in
                            PhotoGridItem(photo: photo)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom, content: {
                FlowToggle(title: "Icon flows to nav bar", isOn: $iconFlows)
            })
            .flowingHeaderDestination("Photos", systemImage: iconFlows ? "camera.fill" : nil)
        }
        .flowingHeader()
        .flowingHeaderLayout(.vertical)
    }
    
    private var filteredPhotos: [MockPhoto] {
        selectedTag == "All" ? photos : photos.filter { $0.category == selectedTag }
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderCustomViewExample: View {
    @State private var user = MockUser.sampleUser
    @State private var stats = MockStats.sampleStats
    @State private var avatarFlows = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header with custom view accessory
                    FlowingHeaderView(user.name, subtitle: user.bio) {
                        UserAvatar(user: user, size: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    
                    // Stats section
                    StatsSection(stats: stats)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    
                    // Settings sections
                    VStack(spacing: 16) {
                        SettingsSection(title: "Account") {
                            SettingsRow(
                                title: "Personal Information",
                                subtitle: "Update your details",
                                icon: "person.circle",
                                color: .blue
                            )
                            SettingsRow(
                                title: "Privacy & Security",
                                subtitle: "Manage your privacy",
                                icon: "lock.circle",
                                color: .green
                            )
                            SettingsRow(
                                title: "Notifications",
                                subtitle: "Configure alerts",
                                icon: "bell.circle",
                                color: .orange
                            )
                        }
                        
                        SettingsSection(title: "Preferences") {
                            SettingsRow(
                                title: "Appearance",
                                subtitle: "Light or dark theme",
                                icon: "paintbrush.pointed",
                                color: .purple
                            )
                            SettingsRow(
                                title: "Language",
                                subtitle: "Choose your language",
                                icon: "globe",
                                color: .mint
                            )
                        }
                        
                        SettingsSection(title: "Support") {
                            SettingsRow(
                                title: "Help Center",
                                subtitle: "Get assistance",
                                icon: "questionmark.circle",
                                color: .cyan
                            )
                            SettingsRow(
                                title: "Contact Us",
                                subtitle: "Send feedback",
                                icon: "envelope.circle",
                                color: .pink
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom, content: {
                FlowToggle(title: "Avatar flows to nav bar", isOn: $avatarFlows)
            })
            .flowingHeaderDestination(user.name) {
                if avatarFlows {
                    UserAvatar(user: user, size: 32)
                }
            }
        }
        .flowingHeader()
    }
}

// MARK: - Data Models

@available(iOS 18.0, *)
struct MockPhoto: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let color: Color
    
    static let samplePhotos = [
        MockPhoto(name: "Sunset Lake", category: "Nature", color: .orange),
        MockPhoto(name: "City Lights", category: "Street", color: .purple),
        MockPhoto(name: "Modern Building", category: "Architecture", color: .blue),
        MockPhoto(name: "Forest Path", category: "Nature", color: .green),
        MockPhoto(name: "Portrait Study", category: "Portrait", color: .pink),
        MockPhoto(name: "Bridge View", category: "Architecture", color: .cyan),
        MockPhoto(name: "Market Scene", category: "Street", color: .yellow),
        MockPhoto(name: "Mountain Peak", category: "Nature", color: .indigo),
        MockPhoto(name: "Urban Portrait", category: "Portrait", color: .red),
        MockPhoto(name: "Glass Tower", category: "Architecture", color: .mint),
        MockPhoto(name: "Night Walk", category: "Street", color: .purple),
        MockPhoto(name: "Ocean Waves", category: "Nature", color: .teal),
        MockPhoto(name: "Desert Dunes", category: "Nature", color: .brown),
        MockPhoto(name: "Cafe Interior", category: "Street", color: .orange),
        MockPhoto(name: "Skyscraper", category: "Architecture", color: .gray),
        MockPhoto(name: "Family Portrait", category: "Portrait", color: .blue),
        MockPhoto(name: "Cherry Blossoms", category: "Nature", color: .pink),
        MockPhoto(name: "Cathedral", category: "Architecture", color: .purple),
        MockPhoto(name: "Street Musician", category: "Street", color: .green),
        MockPhoto(name: "Business Portrait", category: "Portrait", color: .blue),
        MockPhoto(name: "Waterfall", category: "Nature", color: .cyan),
        MockPhoto(name: "Modern Art Museum", category: "Architecture", color: .red),
        MockPhoto(name: "Food Market", category: "Street", color: .yellow),
        MockPhoto(name: "Wedding Portrait", category: "Portrait", color: .white),
        MockPhoto(name: "Snow Mountains", category: "Nature", color: .white),
        MockPhoto(name: "Historic Library", category: "Architecture", color: .brown),
        MockPhoto(name: "Rush Hour", category: "Street", color: .gray),
        MockPhoto(name: "Senior Portrait", category: "Portrait", color: .mint),
        MockPhoto(name: "Tropical Beach", category: "Nature", color: .teal),
        MockPhoto(name: "Train Station", category: "Architecture", color: .black),
    ]
}

@available(iOS 18.0, *)
struct MockUser {
    let name: String
    let bio: String
    let avatarColor: Color
    let initials: String
    
    static let sampleUser = MockUser(
        name: "Alex Chen",
        bio: "iOS Developer & Design Enthusiast",
        avatarColor: .blue,
        initials: "AC"
    )
}

@available(iOS 18.0, *)
struct MockStats {
    let posts: Int
    let followers: Int
    let following: Int
    
    static let sampleStats = MockStats(posts: 127, followers: 2843, following: 196)
}

// MARK: - Supporting Views

@available(iOS 18.0, *)
private struct FlowToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        if #available(iOS 26.0, *) {
            Toggle(title, isOn: $isOn)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .glassEffect()
                .padding(.horizontal, 40)
        } else {
            Toggle(title, isOn: $isOn)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.thinMaterial)
                .clipShape(.capsule)
                .padding(.horizontal, 40)
        }
    }
}

@available(iOS 18.0, *)
private struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? .purple : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 18.0, *)
private struct PhotoGridItem: View {
    let photo: MockPhoto
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(photo.color.opacity(0.7))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                VStack {
                    Spacer()
                    Text(photo.name)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(8)
                }
            }
    }
}

@available(iOS 18.0, *)
private struct UserAvatar: View {
    let user: MockUser
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [user.avatarColor, user.avatarColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Text(user.initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(.white)
            }
    }
}

@available(iOS 18.0, *)
private struct StatsSection: View {
    let stats: MockStats
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(title: "Posts", value: stats.posts)
            Divider().frame(height: 32)
            StatItem(title: "Followers", value: stats.followers)
            Divider().frame(height: 32)
            StatItem(title: "Following", value: stats.following)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

@available(iOS 18.0, *)
private struct StatItem: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 18.0, *)
private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

@available(iOS 18.0, *)
private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

// MARK: - Additional Examples

@available(iOS 18.0, *)
public struct FlowingHeaderTextOnlyExample: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Simple text-only header
                    FlowingHeaderView("Settings", subtitle: "Manage your preferences")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    
                    VStack(spacing: 20) {
                        SettingsSection(title: "General") {
                            SettingsRow(title: "Notifications", subtitle: "Manage alerts", icon: "bell", color: .orange)
                            SettingsRow(title: "Privacy", subtitle: "Security settings", icon: "lock", color: .blue)
                            SettingsRow(title: "Account", subtitle: "Profile settings", icon: "person", color: .green)
                        }
                        
                        SettingsSection(title: "Preferences") {
                            SettingsRow(title: "Theme", subtitle: "Light or dark mode", icon: "paintbrush", color: .purple)
                            SettingsRow(title: "Language", subtitle: "Choose your language", icon: "globe", color: .mint)
                        }
                        
                        SettingsSection(title: "About") {
                            SettingsRow(title: "Help", subtitle: "Get support", icon: "questionmark.circle", color: .cyan)
                            SettingsRow(title: "Version", subtitle: "1.0.0", icon: "info.circle", color: .gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Settings")
        }
        .flowingHeader()
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderBundleImageExample: View {
    @State private var artworks = MockArtwork.sampleArtworks
    @State private var imageFlows = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header using rendered image accessory
                    FlowingHeaderView("Gallery", image: GalleryImages.heroImage, subtitle: "Your art collection")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(artworks) { artwork in
                            ArtworkCard(artwork: artwork)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom, content: {
                FlowToggle(title: "Image flows to nav bar", isOn: $imageFlows)
            })
            .flowingHeaderDestination("Gallery", image: imageFlows ? GalleryImages.heroImage : nil)
        }
        .flowingHeader()
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderMultiStyleExample: View {
    @State private var selectedStyle: HeaderStyle = .textOnly

    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Dynamic header that changes based on selection
                    Group {
                        switch selectedStyle {
                        case .textOnly:
                            FlowingHeaderView("Dynamic Header", subtitle: "Text only style")
                        case .withIcon:
                            FlowingHeaderView("Dynamic Header", systemImage: "sparkles", subtitle: "With system icon")
                                .tint(.pink)
                        case .withImage:
                            FlowingHeaderView("Dynamic Header", image: GalleryImages.heroImage, subtitle: "With rendered image")
                        case .withCustom:
                            FlowingHeaderView("Dynamic Header", subtitle: "With custom view") {
                                GradientCircle(colors: [.purple, .pink])
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .animation(.smooth(duration: 0.3), value: selectedStyle)
                    
                    // Style picker
                    VStack(spacing: 16) {
                        Picker("Header Style", selection: $selectedStyle) {
                            Text("Text Only").tag(HeaderStyle.textOnly)
                            Text("With Icon").tag(HeaderStyle.withIcon)
                            Text("With Image").tag(HeaderStyle.withImage)
                            Text("Custom View").tag(HeaderStyle.withCustom)
                        }
                        .pickerStyle(.segmented)
                        
                        // Sample content
                        VStack(spacing: 12) {
                            ForEach(0..<8) { index in
                                SampleContentRow(index: index)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Dynamic Header",
                systemImage: selectedStyle == .withIcon ? "sparkles" : nil,
                image: selectedStyle == .withImage ? GalleryImages.heroImage : nil
            ) {
                if selectedStyle == .withCustom {
                    GradientCircle(colors: [.purple, .pink])
                        .frame(width: 32, height: 32)
                } else {
                    EmptyView()
                }
            }
        }
        .flowingHeader()
    }
}

// MARK: - Additional Supporting Types


@available(iOS 18.0, *)
enum HeaderStyle: CaseIterable {
    case textOnly, withIcon, withImage, withCustom
}

@available(iOS 18.0, *)
struct MockArtwork: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let color: Color
    
    static let sampleArtworks = [
        MockArtwork(title: "Sunset Dreams", artist: "Digital Artist", color: .orange),
        MockArtwork(title: "Ocean Waves", artist: "Nature Photographer", color: .blue),
        MockArtwork(title: "Urban Jungle", artist: "Street Photographer", color: .green),
        MockArtwork(title: "Golden Hour", artist: "Landscape Artist", color: .yellow),
        MockArtwork(title: "Neon Nights", artist: "Urban Explorer", color: .purple),
        MockArtwork(title: "Mountain Peak", artist: "Adventure Photographer", color: .gray),
    ]
}

@available(iOS 18.0, *)
private struct ArtworkCard: View {
    let artwork: MockArtwork
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(artwork.color.opacity(0.7))
            .aspectRatio(0.8, contentMode: .fit)
            .overlay {
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(artwork.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(artwork.artist)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

@available(iOS 18.0, *)
private struct GradientCircle: View {
    let colors: [Color]
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
    }
}

@available(iOS 18.0, *)
private struct GalleryHeroImageView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.purple, .indigo, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 80)
            .overlay {
                ZStack {
                    // Abstract geometric shapes to look like a landscape photo
                    Circle()
                        .fill(.yellow)
                        .frame(width: 16, height: 16)
                        .offset(x: -20, y: -20)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 60))
                        path.addLine(to: CGPoint(x: 25, y: 40))
                        path.addLine(to: CGPoint(x: 50, y: 45))
                        path.addLine(to: CGPoint(x: 80, y: 35))
                        path.addLine(to: CGPoint(x: 80, y: 80))
                        path.addLine(to: CGPoint(x: 0, y: 80))
                        path.closeSubpath()
                    }
                    .fill(.green.opacity(0.7))
                    
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 70))
                        path.addLine(to: CGPoint(x: 30, y: 50))
                        path.addLine(to: CGPoint(x: 60, y: 55))
                        path.addLine(to: CGPoint(x: 80, y: 45))
                        path.addLine(to: CGPoint(x: 80, y: 80))
                        path.addLine(to: CGPoint(x: 0, y: 80))
                        path.closeSubpath()
                    }
                    .fill(.green.opacity(0.9))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

@available(iOS 18.0, *)
private enum GalleryImages {
    @MainActor
    static let heroImage: Image = {
        let renderer = ImageRenderer(
            content: GalleryHeroImageView()
        )
        renderer.scale = 3.0 // For high resolution
        return Image(uiImage: renderer.uiImage!)
    }()
}

@available(iOS 18.0, *)
private struct SampleContentRow: View {
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay {
                    Text("\(index + 1)")
                        .font(.caption.weight(.medium))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Sample Item \(index + 1)")
                    .font(.body.weight(.medium))
                Text("This is sample content for testing")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderNavigationExample: View {
    @State private var useVerticalLayout = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    FlowingHeaderView(
                        "Settings",
                        systemImage: "gearshape.fill",
                        subtitle: "Manage your preferences"
                    )
                    .tint(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    
                    VStack(spacing: 16) {
                        // Layout toggle
                        HStack {
                            Text("Layout Style")
                                .font(.headline)
                            Spacer()
                            Button(action: { useVerticalLayout.toggle() }) {
                                HStack {
                                    Image(systemName: useVerticalLayout ? "rectangle.stack" : "rectangle.2.swap")
                                    Text(useVerticalLayout ? "Vertical" : "Horizontal")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Navigation options
                        VStack(spacing: 12) {
                            NavigationLink(destination: DetailView(title: "Profile", icon: "person.circle")) {
                                SettingsRow(title: "Profile", subtitle: "Manage your account", icon: "person.circle", color: .blue)
                            }
                            
                            NavigationLink(destination: DetailView(title: "Notifications", icon: "bell")) {
                                SettingsRow(title: "Notifications", subtitle: "Configure alerts and sounds", icon: "bell", color: .orange)
                            }
                            
                            NavigationLink(destination: DetailView(title: "Privacy", icon: "lock.shield")) {
                                SettingsRow(title: "Privacy & Security", subtitle: "Control your data", icon: "lock.shield", color: .green)
                            }
                            
                            NavigationLink(destination: DetailView(title: "Appearance", icon: "paintbrush")) {
                                SettingsRow(title: "Appearance", subtitle: "Customize the look", icon: "paintbrush", color: .purple)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // More content for scrolling
                        ForEach(0..<20, id: \.self) { index in
                            SampleContentRow(index: index)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .flowingHeaderDestination("Settings", systemImage: "gearshape.fill")
            }
        }
        .flowingHeader()
        .flowingHeaderLayout(useVerticalLayout ? .vertical : .horizontal)
    }
}

@available(iOS 18.0, *)
private struct DetailView: View {
    let title: String
    let icon: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Add FlowingHeaderView for the detail page
                FlowingHeaderView(
                    title,
                    systemImage: icon,
                    subtitle: "Configure your \(title.lowercased()) settings"
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                
                // Sample content
                VStack(spacing: 16) {
                    ForEach(0..<10, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Text("\(index + 1)")
                                        .font(.caption2.weight(.medium))
                                }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(title) Option \(index + 1)")
                                    .font(.body.weight(.medium))
                                Text("Configure this setting")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: .constant(index % 2 == 0))
                                .labelsHidden()
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 20)
            }
        }
        .flowingHeaderDestination(title, systemImage: icon)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Preview

@available(iOS 18.0, *)
#Preview("Icon") {
    FlowingHeaderExample()
}

@available(iOS 18.0, *)
#Preview("Custom") {
    FlowingHeaderCustomViewExample()
}
@available(iOS 18.0, *)
#Preview("Image") {
    FlowingHeaderBundleImageExample()
}

@available(iOS 18.0, *)
#Preview("Text Only") {
    FlowingHeaderTextOnlyExample()
}

@available(iOS 18.0, *)
#Preview("Dynamic") {
    FlowingHeaderMultiStyleExample()
}

@available(iOS 18.0, *)
#Preview("Navigation") {
    FlowingHeaderNavigationExample()
}
