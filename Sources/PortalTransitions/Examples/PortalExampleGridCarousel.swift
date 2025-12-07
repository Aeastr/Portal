//
//  PortalExampleGridCarousel.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// Portal grid-to-carousel example demonstrating a grid that opens into a horizontally paging carousel
public struct PortalExampleGridCarousel: View {
    @State private var selectedItem: CarouselItem?
    @State private var portalItem: CarouselItem?
    @State private var items: [CarouselItem] = CarouselItem.sampleItems

    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 3)

    public init() {}

    public var body: some View {
        PortalContainer {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Explanation text
                        VStack(spacing: 12) {
                            Text("Tap any item to open a fullscreen carousel. Swipe horizontally to browse between items while maintaining the portal connection.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)

                        // Grid of items
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(items) { item in
                                AnimatedCarouselLayer(item: item) { item in
                                    GridItemView(item: item)
                                }
                                .portal(item: item, .source)
                                .onTapGesture {
                                    portalItem = item
                                    selectedItem = item
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
                .navigationTitle("Grid to Carousel")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
            .fullScreenCover(item: $selectedItem) { item in
                CarouselDetailView(
                    items: items,
                    initialItem: item,
                    portalItem: $portalItem
                )
            }
            .portalTransition(
                item: $portalItem,
                animation: .smooth(duration: 0.25),
                transition: .fade
            ) { item in
                AnimatedCarouselLayer(item: item) { item in
                    GridItemView(item: item)
                }
            }
        }
    }
}

// MARK: - Carousel Item Model

/// Model representing an item in the grid/carousel
public struct CarouselItem: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let color: Color
    public let icon: String

    public init(title: String, subtitle: String, color: Color, icon: String) {
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: CarouselItem, rhs: CarouselItem) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated(unsafe) static let sampleItems: [CarouselItem] = [
        CarouselItem(title: "Photos", subtitle: "Your memories", color: .orange, icon: "photo.fill"),
        CarouselItem(title: "Music", subtitle: "Listen now", color: .pink, icon: "music.note"),
        CarouselItem(title: "Videos", subtitle: "Watch later", color: .red, icon: "play.fill"),
        CarouselItem(title: "Books", subtitle: "Read more", color: .brown, icon: "book.fill"),
        CarouselItem(title: "Podcasts", subtitle: "New episodes", color: .purple, icon: "mic.fill"),
        CarouselItem(title: "News", subtitle: "Stay informed", color: .blue, icon: "newspaper.fill"),
        CarouselItem(title: "Weather", subtitle: "Forecast", color: .cyan, icon: "cloud.sun.fill"),
        CarouselItem(title: "Fitness", subtitle: "Stay active", color: .green, icon: "figure.run"),
        CarouselItem(title: "Calendar", subtitle: "Events", color: .red, icon: "calendar"),
        CarouselItem(title: "Notes", subtitle: "Quick thoughts", color: .yellow, icon: "note.text"),
        CarouselItem(title: "Maps", subtitle: "Navigate", color: .green, icon: "map.fill"),
        CarouselItem(title: "Mail", subtitle: "Inbox", color: .blue, icon: "envelope.fill")
    ]
}

// MARK: - Grid Item View

/// View for displaying an item in the grid
private struct GridItemView: View {
    let item: CarouselItem

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(item.color.gradient)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: item.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)

                    Text(item.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            )
    }
}

// MARK: - Animated Carousel Layer

/// An item-based animated layer for the carousel example.
/// Provides a subtle scale animation during portal transitions.
private struct AnimatedCarouselLayer<Item: Identifiable, Content: View>: View {
    let item: Item?
    var scale: CGFloat = 1.08
    @ViewBuilder let content: (Item) -> Content

    @State private var layerScale: CGFloat = 1

    var body: some View {
        Group {
            if let item {
                content(item)
                    .scaleEffect(layerScale)
            }
        }
        .onAppear {
            layerScale = 1
        }
    }
}

// MARK: - Carousel Detail View

/// Fullscreen carousel view that pages horizontally through items
private struct CarouselDetailView: View {
    let items: [CarouselItem]
    let initialItem: CarouselItem
    @Binding var portalItem: CarouselItem?

    @State private var currentIndex: Int = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(CrossModel.self) private var portalModel

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        CarouselPageView(
                            item: item,
                            isSelected: item.id == portalItem?.id
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .ignoresSafeArea()

                // Close button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            portalItem = items[currentIndex]
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                portalItem = nil
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.white, .black.opacity(0.3))
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            // Set initial index based on selected item
            if let index = items.firstIndex(where: { $0.id == initialItem.id }) {
                currentIndex = index
            }
        }
        .onChange(of: currentIndex) { oldIndex, newIndex in
            let oldItem = items[oldIndex]
            let newItem = items[newIndex]
            portalModel.transferActivePortal(from: oldItem.id, to: newItem.id)
            portalItem = newItem
        }
    }
}

// MARK: - Carousel Page View

/// Individual page in the carousel
private struct CarouselPageView: View {
    let item: CarouselItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Main content card - portal destination
            AnimatedCarouselLayer(item: item) { item in
                GridItemView(item: item)
            }
            .portal(item: item, .destination)

            // Info below the card
            VStack(spacing: 8) {
                Text(item.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(item.subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview("Grid Carousel") {
    PortalExampleGridCarousel()
        .portalTransitionDebugOverlays(true)
}

#endif
