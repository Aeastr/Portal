//
//  FlowingHeaderAdvancedExamples.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Advanced FlowingHeader example demonstrating multiple header styles
@available(iOS 18.0, *)
public struct FlowingHeaderMultiStyleExample: View {
    public init() {}

    @State private var currentStyle: FlowingHeaderExample.HeaderStyle = .standard

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header style selector
                    Picker("Header Style", selection: $currentStyle) {
                        Text("Standard").tag(FlowingHeaderExample.HeaderStyle.standard)
                        Text("Compact").tag(FlowingHeaderExample.HeaderStyle.compact)
                        Text("Minimal").tag(FlowingHeaderExample.HeaderStyle.minimal)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    // Dynamic header based on selected style
                    switch currentStyle {
                    case .standard:
                        FlowingHeaderView(
                            "Settings",
                            systemImage: "gearshape.fill",
                            subtitle: "Configure your experience"
                        )
                    case .compact:
                        FlowingHeaderView(
                            "Settings",
                            systemImage: "gearshape.fill",
                            subtitle: ""
                        )
                    case .minimal:
                        FlowingHeaderView("Settings", subtitle: "")
                    }

                    settingsContent
                }
            }
            .navigationDestination(for: String.self) { _ in
                Text("Detail View")
                    .navigationTitle("Detail")
            }
            .flowingHeaderDestination("Settings", systemImage: currentStyle != .minimal ? "gearshape.fill" : nil)
        }
        .flowingHeader("Settings", systemImage: currentStyle != .minimal ? "gearshape.fill" : nil)
    }

    @ViewBuilder
    private var settingsContent: some View {
        LazyVStack(spacing: 0) {
            settingGroup("Appearance") {
                settingRow("Theme", value: "Dark", icon: "paintbrush")
                settingRow("Text Size", value: "Medium", icon: "textformat.size")
                settingRow("Accent Color", value: "Blue", icon: "circle.fill")
            }

            settingGroup("Notifications") {
                settingRow("Push Notifications", value: "On", icon: "bell")
                settingRow("Email Updates", value: "Weekly", icon: "envelope")
                settingRow("Sound", value: "Enabled", icon: "speaker.2")
            }

            settingGroup("Privacy") {
                settingRow("Location Services", value: "When Using", icon: "location")
                settingRow("Analytics", value: "Off", icon: "chart.bar")
                settingRow("Crash Reports", value: "On", icon: "exclamationmark.triangle")
            }

            settingGroup("About") {
                settingRow("Version", value: "1.0.0", icon: "info.circle")
                settingRow("Build", value: "100", icon: "hammer")
                settingRow("Support", value: "Contact", icon: "questionmark.circle")
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func settingGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.leading, 16)
                .padding(.top, 20)

            VStack(spacing: 1) {
                content()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }

    @ViewBuilder
    private func settingRow(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)
                .font(.body)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap
        }
    }
}

/// Advanced navigation example with FlowingHeader
@available(iOS 18.0, *)
public struct FlowingHeaderNavigationExample: View {
    public init() {}

    @State private var selectedTab = 0
    @State private var searchText = ""

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScrollView {
                    FlowingHeaderView(
                        "Gallery",
                        systemImage: "photo.stack",
                        subtitle: "Your memories"
                    )

                    searchBar
                    photoGrid
                }
                .environment(\.flowingHeaderLayout, .horizontal)
                .flowingHeaderDestination("Gallery", systemImage: "photo.stack")
            }
            .flowingHeader("Gallery", systemImage: "photo.stack")
            .tabItem {
                Image(systemName: "photo.stack")
                Text("Gallery")
            }
            .tag(0)

            NavigationStack {
                ScrollView {
                    FlowingHeaderView(
                        "Profile",
                        systemImage: "person.crop.circle",
                        subtitle: FlowingHeaderExample.sampleUser.username
                    )

                    profileContent
                }
                .environment(\.flowingHeaderLayout, .vertical)
                .flowingHeaderDestination("Profile", systemImage: "person.crop.circle")
            }
            .flowingHeader("Profile", systemImage: "person.crop.circle")
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(1)
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search photos...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var photoGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
            ForEach(filteredPhotos) { photo in
                NavigationLink(value: photo.id) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(photo.color.gradient)
                        .aspectRatio(1, contentMode: .fill)
                        .overlay {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text(photo.category)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .clipped()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .navigationDestination(for: UUID.self) { photoId in
            photoDetail(for: photoId)
        }
    }

    @ViewBuilder
    private var profileContent: some View {
        VStack(spacing: 24) {
            // Profile stats
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(FlowingHeaderExample.sampleUser.posts)")
                        .font(.title2.bold())
                    Text("Posts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(FlowingHeaderExample.sampleUser.followers)")
                        .font(.title2.bold())
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(FlowingHeaderExample.sampleUser.following)")
                        .font(.title2.bold())
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // Bio
            Text(FlowingHeaderExample.sampleUser.bio)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Action buttons
            HStack(spacing: 12) {
                Button("Edit Profile") {
                    // Action
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 8))

                Button("Share Profile") {
                    // Action
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 8))
            }

            // Recent photos
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 3), spacing: 1) {
                ForEach(FlowingHeaderExample.samplePhotos.prefix(12)) { photo in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(photo.color.gradient)
                        .aspectRatio(1, contentMode: .fill)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                        .clipped()
                }
            }
            .padding(.horizontal)
        }
    }

    private var filteredPhotos: [FlowingHeaderExample.MockPhoto] {
        if searchText.isEmpty {
            return FlowingHeaderExample.samplePhotos
        } else {
            return FlowingHeaderExample.samplePhotos.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @ViewBuilder
    private func photoDetail(for photoId: UUID) -> some View {
        if let photo = FlowingHeaderExample.samplePhotos.first(where: { $0.id == photoId }) {
            ScrollView {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(photo.color.gradient)
                        .aspectRatio(4 / 3, contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(photo.name)
                            .font(.title.bold())

                        Text(photo.category)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("This is a beautiful example of \(photo.category.lowercased()) photography. The composition and color palette work together to create a compelling visual narrative.")
                            .font(.body)
                            .lineLimit(nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(photo.name)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#if DEBUG
@available(iOS 18.0, *)
#Preview("Multi-Style") {
    FlowingHeaderMultiStyleExample()
}

@available(iOS 18.0, *)
#Preview("Navigation") {
    FlowingHeaderNavigationExample()
}
#endif
