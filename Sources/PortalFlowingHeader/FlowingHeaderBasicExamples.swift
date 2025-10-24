//
//  FlowingHeaderBasicExamples.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Basic FlowingHeader example with system image, title, and subtitle
@available(iOS 18.0, *)
public struct FlowingHeaderExample: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView(
                    "Photos",
                    systemImage: "photo.on.rectangle.angled",
                    subtitle: "My Collection"
                )

                LazyVStack(spacing: 12) {
                    ForEach(Self.samplePhotos) { photo in
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(photo.color.gradient)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(photo.name)
                                    .font(.headline)
                                Text(photo.category)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .flowingHeaderDestination("Photos", systemImage: "photo.on.rectangle.angled")
        }
        .flowingHeader("Photos", systemImage: "photo.on.rectangle.angled")
    }
}

/// FlowingHeader example with custom view component
@available(iOS 18.0, *)
public struct FlowingHeaderCustomViewExample: View {
    public init() {}

    @ViewBuilder
    private var profileAvatar: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)

            Image(systemName: FlowingHeaderExample.sampleUser.avatar)
                .font(.system(size: 32))
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private var compactAvatar: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)

            Image(systemName: FlowingHeaderExample.sampleUser.avatar)
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView(FlowingHeaderExample.sampleUser.name, subtitle: FlowingHeaderExample.sampleUser.username) {
                    profileAvatar
                }

                VStack(alignment: .leading, spacing: 24) {
                    Text(FlowingHeaderExample.sampleUser.bio)
                        .font(.body)
                        .padding(.horizontal)

                    HStack(spacing: 40) {
                        VStack {
                            Text("\(FlowingHeaderExample.sampleUser.posts)")
                                .font(.title2.bold())
                            Text("Posts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(FlowingHeaderExample.sampleUser.followers)")
                                .font(.title2.bold())
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(FlowingHeaderExample.sampleUser.following)")
                                .font(.title2.bold())
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 2) {
                        ForEach(FlowingHeaderExample.samplePhotos.prefix(18)) { photo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(photo.color.gradient)
                                .aspectRatio(1, contentMode: .fill)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .flowingHeaderDestination(FlowingHeaderExample.sampleUser.name) {
                compactAvatar
            }
        }
        .flowingHeader(FlowingHeaderExample.sampleUser.name, customView: AnyView(compactAvatar))
    }
}

/// FlowingHeader example with text-only header (no image or custom view)
@available(iOS 18.0, *)
public struct FlowingHeaderTextOnlyExample: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView("Analytics", subtitle: "Business Intelligence Dashboard")

                LazyVStack(spacing: 16) {
                    ForEach(FlowingHeaderExample.sampleStats, id: \.title) { stat in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stat.title)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(stat.value)
                                    .font(.title2.bold())

                                Text(stat.change)
                                    .font(.caption)
                                    .foregroundColor(stat.color)
                            }

                            Spacer()

                            RoundedRectangle(cornerRadius: 8)
                                .fill(stat.color.opacity(0.2))
                                .frame(width: 60, height: 40)
                                .overlay {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(stat.color)
                                }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .flowingHeaderDestination("Analytics")
        }
        .flowingHeader("Analytics")
    }
}

/// FlowingHeader example using bundled image assets
@available(iOS 18.0, *)
public struct FlowingHeaderBundleImageExample: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView(
                    "Art Gallery",
                    image: Image(systemName: "paintbrush.pointed.fill"),
                    subtitle: "Digital Collection"
                )

                LazyVStack(spacing: 16) {
                    ForEach(FlowingHeaderExample.sampleArtwork) { artwork in
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(artwork.color.gradient)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: "paintbrush.pointed.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(artwork.title)
                                    .font(.headline)

                                Text("by \(artwork.artist)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(artwork.year)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button {
                                // Action
                            } label: {
                                Image(systemName: "heart")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .flowingHeaderDestination("Art Gallery", image: Image(systemName: "paintbrush.pointed.fill"))
        }
        .flowingHeader("Art Gallery", image: Image(systemName: "paintbrush.pointed.fill"))
    }
}

#if DEBUG
@available(iOS 18.0, *)
#Preview("Basic Example") {
    FlowingHeaderExample()
}

@available(iOS 18.0, *)
#Preview("Custom View") {
    FlowingHeaderCustomViewExample()
}

@available(iOS 18.0, *)
#Preview("Text Only") {
    FlowingHeaderTextOnlyExample()
}

@available(iOS 18.0, *)
#Preview("Bundle Image") {
    FlowingHeaderBundleImageExample()
}
#endif
