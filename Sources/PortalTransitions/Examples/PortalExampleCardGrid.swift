//
//  PortalExampleCardGrid.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// Portal card grid example showing dynamic item parameter usage
public struct PortalExampleCardGrid: View {
    @State private var selectedCard: PortalExampleCard?
    @Namespace private var portalNamespace
    @State private var cards: [PortalExampleCard] = [
        PortalExampleCard(title: "SwiftUI", subtitle: "Declarative UI", color: .blue, icon: "swift"),
        PortalExampleCard(title: "Portal", subtitle: "Seamless Transitions", color: .purple, icon: "arrow.triangle.2.circlepath"),
        PortalExampleCard(title: "Animation", subtitle: "Smooth Motion", color: .green, icon: "waveform.path"),
        PortalExampleCard(title: "Design", subtitle: "Beautiful Interfaces", color: .orange, icon: "paintbrush.fill"),
        PortalExampleCard(title: "Code", subtitle: "Clean Architecture", color: .red, icon: "chevron.left.forwardslash.chevron.right"),
        PortalExampleCard(title: "iOS", subtitle: "Native Platform", color: .cyan, icon: "iphone"),
        PortalExampleCard(title: "Xcode", subtitle: "Development IDE", color: .indigo, icon: "hammer.fill"),
        PortalExampleCard(title: "TestFlight", subtitle: "Beta Testing", color: .mint, icon: "airplane"),
        PortalExampleCard(title: "Core Data", subtitle: "Data Persistence", color: .brown, icon: "cylinder.fill"),
        PortalExampleCard(title: "CloudKit", subtitle: "Cloud Sync", color: .teal, icon: "cloud.fill")
    ]

    private let randomCards: [PortalExampleCard] = [
        PortalExampleCard(title: "Xcode", subtitle: "Development IDE", color: .indigo, icon: "hammer.fill"),
        PortalExampleCard(title: "TestFlight", subtitle: "Beta Testing", color: .mint, icon: "airplane"),
        PortalExampleCard(title: "Core Data", subtitle: "Data Persistence", color: .brown, icon: "cylinder.fill"),
        PortalExampleCard(title: "CloudKit", subtitle: "Cloud Sync", color: .teal, icon: "cloud.fill"),
        PortalExampleCard(title: "Combine", subtitle: "Reactive Framework", color: .pink, icon: "link"),
        PortalExampleCard(title: "Metal", subtitle: "Graphics API", color: .yellow, icon: "cube.fill")
    ]

    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    public init() {}

    private func addRandomCard() {
        let availableCards = randomCards.filter { randomCard in
            !cards.contains { $0.title == randomCard.title }
        }

        if let newCard = availableCards.randomElement() {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cards.append(newCard)
            }
        }
    }

    public var body: some View {
        PortalContainer {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Explanation text
                        VStack(spacing: 12) {
                            Text("Item-Based Portal Transitions")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text("Portal automatically manages transitions using Identifiable items. Each card uses its unique ID for seamless animations between grid and detail views.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(cards) { card in
                                VStack(spacing: 12) {
                                    AnimatedItemLayerExample(item: card) { card in
                                        PortalExampleCardContent(card: card)
                                    }
                                    .frame(height: 120)
                                    .portal(item: card, as: .source, in: portalNamespace)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                )
                                .onTapGesture {
                                    selectedCard = card
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Portal Card Grid")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Add Card") {
                            addRandomCard()
                        }
                    }
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
            .sheet(item: $selectedCard) { card in
                PortalExampleCardDetail(card: card, namespace: portalNamespace)
            }

            .portalTransition(
                item: $selectedCard,
                in: portalNamespace,
                transition: .fade
            ) { card in
                AnimatedItemLayerExample(item: $selectedCard) { card in
                    PortalExampleCardContent(card: card)
                }
            }
        }
    }
}

/// Card model for the Portal example
public struct PortalExampleCard: Identifiable {
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
}

// MARK: - Shared Card Content

private struct PortalExampleCardContent: View {
    let card: PortalExampleCard

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(card.color.gradient)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: card.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)

                    Text(card.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            )
    }
}

// MARK: - Animated Item Layer Example

/// An example implementation of `AnimatedItemPortalLayer` for item-based portal transitions.
/// Provides the same bounce animation as `AnimatedLayer`, but works with `Identifiable` items.
///
/// Can be initialized with either:
/// - A non-optional item (for source/destination views)
/// - An optional item binding (for transition layers)
private struct AnimatedItemLayerExample<Item: Identifiable, Content: View>: AnimatedItemPortalLayer {
    let item: Item?
    var scale: CGFloat = 1.1
    @ViewBuilder let content: (Item) -> Content

    @State private var layerScale: CGFloat = 1

    /// Initialize with a non-optional item (for source/destination views)
    init(item: Item, scale: CGFloat = 1.1, @ViewBuilder content: @escaping (Item) -> Content) {
        self.item = item
        self.scale = scale
        self.content = content
    }

    /// Initialize with an optional item binding (for transition layers)
    init(item: Binding<Item?>, scale: CGFloat = 1.1, @ViewBuilder content: @escaping (Item) -> Content) {
        self.item = item.wrappedValue
        self.scale = scale
        self.content = content
    }

    func animatedContent(item: Item?, isActive: Bool) -> some View {
        Group {
            if let item {
                content(item)
                    .scaleEffect(layerScale)
            }
        }
        .onAppear {
            layerScale = 1
        }
        .onChange(of: isActive) { oldValue, newValue in
            handleActiveChange(oldValue: oldValue, newValue: newValue)
        }
    }

    private func handleActiveChange(oldValue: Bool, newValue: Bool) {
        if newValue {
            withAnimation(portalAnimationExample) {
                layerScale = scale
            }
            // Timing calculation: Trigger second bounce slightly before halfway point
            // The 0.2 delay is an animation design parameter for this specific bounce choreography,
            // NOT PortalConstants.animationDelay (which is for portal system timing, not animation design)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(portalAnimationExampleExtraBounce) {
                    layerScale = 1
                }
            }
        } else {
            // Same timing calculation for reverse animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(portalAnimationExampleExtraBounce) {
                    layerScale = 1
                }
            }
        }
    }
}

// MARK: - Card Detail View

private struct PortalExampleCardDetail: View {
    let card: PortalExampleCard
    let namespace: Namespace.ID
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Destination Card
                    AnimatedItemLayerExample(item: card) { card in
                        PortalExampleCardContent(card: card)
                    }
                    .frame(width: 240, height: 180)
                    .portal(item: card, as: .destination, in: namespace)
                        .padding(.top, 20)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(card.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(card.color)
                }
            }
        }
    }
}

#Preview("Card Grid") {
    PortalExampleCardGrid().portalTransitionDebugOverlays(false)
}

#Preview("Detail View") {
    @Previewable @Namespace var ns
    PortalExampleCardDetail(
        card: PortalExampleCard(title: "Portal", subtitle: "Seamless Transitions", color: .purple, icon: "arrow.triangle.2.circlepath"),
        namespace: ns
    )
}

#endif
