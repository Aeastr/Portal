//
//  PortalExampleMultiItem.swift
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
/// Portal multi-item example showing coordinated transitions for multiple elements
@available(iOS 17, *)
public struct PortalExampleMultiItem: View {
    @State private var selectedPhotos: [MultiItemPhoto] = []
    @State private var allPhotos: [MultiItemPhoto] = MultiItemPhoto.samplePhotos

    public init() {}

    public var body: some View {
        PortalContainer {
            NavigationView {
                VStack(spacing: 20) {
                    // Explanation section
                    VStack(alignment: .center, spacing: 12) {
                        Text("Tap 'Select Photos' to see multiple elements transition together to the detail view. This demonstrates coordinated portal animations where multiple items move simultaneously with a staggered delay effect.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Photo grid - Sources
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(allPhotos) { photo in
                            AnimatedLayer(portalID: photo.id.uuidString, scale: 1.15) {
                                PhotoThumbnailView(photo: photo)
                                    .portalPrivate(item: photo, groupID: "photoStack")
                            }
                            .frame(height: 160)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .navigationTitle("Multi-Item Portal Transitions")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        // Select button
                        Button("Select Photos") {
                            selectedPhotos = Array(allPhotos.prefix(4))
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!selectedPhotos.isEmpty)
                    }
                }
            }
            .sheet(isPresented: .constant(!selectedPhotos.isEmpty)) {
                MultiItemDetailView(photos: selectedPhotos) {
                    selectedPhotos.removeAll()
                }
            }
            .portalPrivateTransition(
                items: $selectedPhotos,
                groupID: "photoStack"
            )
        }
    }
}

/// Detail view showing the coordinated destination views
struct MultiItemDetailView: View {
    let photos: [MultiItemPhoto]
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(photos) { photo in
                        PortalPrivateDestination(id: photo.id.uuidString)
                    }
                }
                .padding()
            }
            .navigationTitle("Selected Photos")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

/// Individual photo view - MUST be identical for source and destination
struct PhotoView: View {
    let photo: MultiItemPhoto

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(photo.color)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: photo.systemImage)
                        .font(.title2)
                        .foregroundColor(.white)

                    Text(photo.title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            )
    }
}

/// Wrapper for thumbnail (source) - adds frame constraints
struct PhotoThumbnailView: View {
    let photo: MultiItemPhoto

    var body: some View {
        PhotoView(photo: photo)
    }
}

/// Wrapper for detail (destination) - adds different frame constraints
struct PhotoDetailView: View {
    let photo: MultiItemPhoto

    var body: some View {
        PhotoView(photo: photo)
            .aspectRatio(3 / 4, contentMode: .fit)
    }
}

/// Sample data model for multi-item photo examples
struct MultiItemPhoto: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: Color
    let systemImage: String

    static let samplePhotos: [MultiItemPhoto] = [
        MultiItemPhoto(
            title: "Mountain Peak",
            description: "Breathtaking summit views",
            color: .blue,
            systemImage: "mountain.2.fill"
        ),
        MultiItemPhoto(
            title: "Ocean Waves",
            description: "Peaceful coastal scenes",
            color: .cyan,
            systemImage: "water.waves"
        ),
        MultiItemPhoto(
            title: "Forest Trail",
            description: "Winding woodland paths",
            color: .green,
            systemImage: "tree.fill"
        ),
        MultiItemPhoto(
            title: "Desert Sunset",
            description: "Golden hour wilderness",
            color: .orange,
            systemImage: "sun.max.fill"
        ),
        MultiItemPhoto(
            title: "City Lights",
            description: "Urban nighttime landscape",
            color: .purple,
            systemImage: "building.2.fill"
        ),
        MultiItemPhoto(
            title: "Starry Sky",
            description: "Infinite celestial beauty",
            color: .indigo,
            systemImage: "sparkles"
        )
    ]
}

#Preview{
    PortalExampleMultiItem()
}
#endif
