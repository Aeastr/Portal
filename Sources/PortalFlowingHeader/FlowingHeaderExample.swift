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
    
    private let tags = ["All", "Nature", "Architecture", "Street", "Portrait"]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Flowing header with system image
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
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                        ForEach(filteredPhotos) { photo in
                            PhotoGridItem(photo: photo)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Photos")
        }
        .flowingHeader("Photos")
    }
    
    private var filteredPhotos: [MockPhoto] {
        selectedTag == "All" ? photos : photos.filter { $0.category == selectedTag }
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderCustomViewExample: View {
    @State private var user = MockUser.sampleUser
    @State private var stats = MockStats.sampleStats
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with custom view
                    FlowingHeaderView(user.name, subtitle: user.bio) {
                        UserAvatar(user: user, size: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    
                    // Stats section
                    StatsSection(stats: stats)
                        .padding(.horizontal, 24)
                    
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
            .flowingHeaderDestination(user.name) {
                UserAvatar(user: user, size: 32)
            }
        }
        .flowingHeader(user.name, customView: UserAvatar(user: user, size: 32))
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
                LazyVStack(spacing: 24) {
                    // Simple text-only header
                    FlowingHeaderView("Settings", subtitle: "Manage your preferences")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    
                    SettingsSection(title: "General") {
                        SettingsRow(title: "Notifications", subtitle: "Manage alerts", icon: "bell", color: .orange)
                        SettingsRow(title: "Privacy", subtitle: "Security settings", icon: "lock", color: .blue)
                        SettingsRow(title: "Account", subtitle: "Profile settings", icon: "person", color: .green)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Settings")
        }
        .flowingHeader("Settings")
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderBundleImageExample: View {
    @State private var artworks = MockArtwork.sampleArtworks
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header with bundle image (simulated with system image for demo)
                    FlowingHeaderView("Gallery", systemImage: "photo.on.rectangle.angled", subtitle: "Your art collection")
                        .tint(.indigo)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(artworks) { artwork in
                            ArtworkCard(artwork: artwork)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Gallery")
        }
        .flowingHeader("Gallery")
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderMultiStyleExample: View {
    @State private var selectedStyle: HeaderStyle = .textOnly
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Dynamic header that changes based on selection
                    Group {
                        switch selectedStyle {
                        case .textOnly:
                            FlowingHeaderView("Dynamic Header", subtitle: "Text only style")
                        case .withIcon:
                            FlowingHeaderView("Dynamic Header", systemImage: "sparkles", subtitle: "With system icon")
                                .tint(.pink)
                        case .withCustom:
                            FlowingHeaderView("Dynamic Header", subtitle: "With custom view") {
                                GradientCircle(colors: [.purple, .pink])
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .animation(.smooth(duration: 0.3), value: selectedStyle)
                    
                    // Style picker
                    Picker("Header Style", selection: $selectedStyle) {
                        Text("Text Only").tag(HeaderStyle.textOnly)
                        Text("With Icon").tag(HeaderStyle.withIcon)
                        Text("Custom View").tag(HeaderStyle.withCustom)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    
                    // Sample content
                    ForEach(0..<10) { index in
                        SampleContentRow(index: index)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Dynamic Header") {
                if selectedStyle == .withCustom {
                    GradientCircle(colors: [.purple, .pink])
                        .frame(width: 32, height: 32)
                }
            }
        }
        .flowingHeader("Dynamic Header", customView: selectedStyle == .withCustom ? AnyView(GradientCircle(colors: [.purple, .pink]).frame(width: 32, height: 32)) : AnyView(EmptyView()))
    }
}

// MARK: - Additional Supporting Types

@available(iOS 18.0, *)
enum HeaderStyle: CaseIterable {
    case textOnly, withIcon, withCustom
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

// MARK: - Preview

@available(iOS 18.0, *)
#Preview("Photo Gallery") {
    FlowingHeaderExample()
        .preferredColorScheme(.dark)
}

@available(iOS 18.0, *)
#Preview("User Profile") {
    FlowingHeaderCustomViewExample()
        .preferredColorScheme(.light)
}

@available(iOS 18.0, *)
#Preview("Text Only") {
    FlowingHeaderTextOnlyExample()
        .preferredColorScheme(.light)
}

@available(iOS 18.0, *)
#Preview("Bundle Image") {
    FlowingHeaderBundleImageExample()
        .preferredColorScheme(.dark)
}

@available(iOS 18.0, *)
#Preview("Multi Style") {
    FlowingHeaderMultiStyleExample()
        .preferredColorScheme(.light)
}

@available(iOS 18.0, *)
public struct FlowingHeaderFlowingIconExample: View {
    @State private var messages = MockMessage.sampleMessages
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with flowing system image
                    FlowingHeaderView(
                        "Messages",
                        systemImage: "message.circle.fill",
                        subtitle: "\(messages.count) conversations"
                    )
                    .tint(.green)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    
                    ForEach(messages) { message in
                        MessageRow(message: message)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Messages", systemImage: "message.circle.fill")
        }
        .flowingHeader("Messages", systemImage: "message.circle.fill")
    }
}

@available(iOS 18.0, *)
struct MockMessage: Identifiable {
    let id = UUID()
    let sender: String
    let preview: String
    let time: String
    let isUnread: Bool
    
    static let sampleMessages = [
        MockMessage(sender: "Alice Johnson", preview: "Hey! How's the project going?", time: "2m", isUnread: true),
        MockMessage(sender: "Work Team", preview: "Meeting tomorrow at 10am", time: "15m", isUnread: true),
        MockMessage(sender: "Mom", preview: "Don't forget dinner this Sunday", time: "1h", isUnread: false),
        MockMessage(sender: "Bob Smith", preview: "Thanks for the help earlier!", time: "3h", isUnread: false),
        MockMessage(sender: "App Updates", preview: "Your app has been updated", time: "1d", isUnread: false),
        MockMessage(sender: "Sarah Wilson", preview: "Looking forward to the weekend trip", time: "2d", isUnread: false),
    ]
}

@available(iOS 18.0, *)
private struct MessageRow: View {
    let message: MockMessage
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(message.isUnread ? .blue : .gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(String(message.sender.prefix(1)))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.sender)
                        .font(.body.weight(message.isUnread ? .semibold : .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(message.time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(message.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            if message.isUnread {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

@available(iOS 18.0, *)
#Preview("Flowing Icon") {
    FlowingHeaderFlowingIconExample()
        .preferredColorScheme(.light)
}


