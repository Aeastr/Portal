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
import Portal

/// PortalPrivate card grid example showing dynamic item parameter usage with view mirroring
public struct PortalPrivateExampleCardGrid: View {
    @State private var selectedCard: PortalExampleCard?
    @State private var cards: [PortalExampleCard] = [
        PortalExampleCard(title: "SwiftUI", subtitle: "Declarative UI", color: .blue, icon: "swift"),
        PortalExampleCard(title: "Portal", subtitle: "Seamless Transitions", color: .purple, icon: "arrow.triangle.2.circlepath"),
        PortalExampleCard(title: "Animation", subtitle: "Smooth Motion", color: .green, icon: "waveform.path"),
        PortalExampleCard(title: "Design", subtitle: "Beautiful Interfaces", color: .orange, icon: "paintbrush.fill"),
        PortalExampleCard(title: "Code", subtitle: "Clean Architecture", color: .red, icon: "chevron.left.forwardslash.chevron.right"),
        PortalExampleCard(title: "iOS", subtitle: "Native Platform", color: .cyan, icon: "iphone")
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
                                    AnimatedLayer(portalID: "\(card.id)") {
                                        Group {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(card.color.gradient)
                                        }
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
                                        .portalPrivate(item: card)
                                    }
                                    .frame(height: 120)
                                }
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
                PortalExampleCardDetail(card: card)
            }
            .portalPrivateTransition(
                item: $selectedCard
            )
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

private struct PortalExampleCardDetail: View {
    let card: PortalExampleCard
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Destination Card
                    PortalPrivateDestination(item: card)
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

#Preview("PortalPrivate Card Grid") {
    PortalPrivateExampleCardGrid()
}

#Preview("Detail View") {
    PortalExampleCardDetail(
        card: PortalExampleCard(title: "Portal", subtitle: "Seamless Transitions", color: .purple, icon: "arrow.triangle.2.circlepath")
    )
}

#endif
