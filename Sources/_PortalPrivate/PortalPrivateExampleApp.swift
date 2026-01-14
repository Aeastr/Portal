//
//  PortalPrivateExample.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import PortalTransitions


// MARK: - Example App

public struct PortalPrivateExampleApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            PortalPrivateExampleView()
        }
    }
}

// MARK: - Main Example View

public struct PortalPrivateExampleView: View {
    @State private var selectedItem: Item?
    @State private var items = Item.sampleItems
    @Namespace private var portalNamespace

    public init() {}

    public var body: some View {
        // Use PortalContainerPrivate instead of regular PortalContainer
        PortalContainer {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Tap a card to see it transition using portal view mirroring")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [
                            .init(),
                            .init(),
                            .init()
                        ], spacing: 16) {
                            ForEach(items) { item in
                                AnimatedLayer(portalID: item.id.uuidString, in: portalNamespace) {
                                    CardView(item: item)
                                        .portalSourcePrivate(id: item.id.uuidString, in: portalNamespace)
                                        .onTapGesture {
                                            withAnimation(.smooth) {
                                                selectedItem = item
                                            }
                                        }
                                }
                                .rotationEffect(.degrees(selectedItem == item ? 0 : 40))
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("PortalPrivate")
                .sheet(item: $selectedItem) { item in
                    DetailView(item: item, selectedItem: $selectedItem, namespace: portalNamespace)
                }
            }
            // Trigger the portal transition with AnimatedLayer wrapper
            .portalPrivateTransition(item: $selectedItem, in: portalNamespace)
        }
//        .portalTransitionDebugOverlays(false)
    }
}

// MARK: - Card View (Source)

struct CardView: View {
    let item: Item

    var body: some View {
        VStack(spacing: 8) {
            // Animated content to prove it's the same instance
            Image(systemName: item.symbol)
                .font(.system(size: 40))
                .foregroundColor(item.color)

            Text(item.name)
                .font(.headline)

            Text("ID: \(item.id.uuidString.prefix(8))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

// MARK: - Detail View (Destination)

struct DetailView: View {
    let item: Item
    @Binding var selectedItem: Item?
    let namespace: Namespace.ID

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Use PortalPrivateDestination to show the mirrored view
                PortalPrivateDestination(id: item.id.uuidString, in: namespace)
//                    .frame(width: 200, height: 200)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()

                Text("Detail View")
                    .font(.title)
                    .bold()

                Text("This is showing the exact same view instance as the source using portal view mirroring. Notice the animation continues seamlessly!")
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        withAnimation(.smooth) {
                            selectedItem = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Data Model

struct Item: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let symbol: String
    let color: Color

    static let sampleItems = [
        Item(name: "Star", symbol: "star.fill", color: .yellow),
        Item(name: "Heart", symbol: "heart.fill", color: .red),
        Item(name: "Cloud", symbol: "cloud.fill", color: .blue),
        Item(name: "Bolt", symbol: "bolt.fill", color: .orange),
        Item(name: "Leaf", symbol: "leaf.fill", color: .green),
        Item(name: "Moon", symbol: "moon.fill", color: .purple)
    ]
}

// MARK: - Preview

#if DEBUG
struct PortalPrivateExampleViewPreviews: PreviewProvider {
    static var previews: some View {
        PortalPrivateExampleView()
    }
}
#endif
