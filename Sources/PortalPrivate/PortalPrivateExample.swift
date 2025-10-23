//
//  PortalPrivateExample.swift
//  Portal
//
//  Example demonstrating PortalPrivate usage with _UIPortalView
//

import SwiftUI
import Portal
import PortalView
import PortalPrivate

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
    @State private var selectedItem: Item? = nil
    @State private var items = Item.sampleItems

    public init() {}

    public var body: some View {
        // Use PortalContainerPrivate instead of regular PortalContainer
        PortalContainerPrivate {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {

                        Text("Tap a card to see it transition using _UIPortalView")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [
                            .init(),
                            .init(),
                            .init()
                        ], spacing: 16) {
                            ForEach(items) { item in
                                CardView(item: item)
                                    // Only define the view once!
                                    .portalPrivate(id: item.id.uuidString)
                                    .onTapGesture {
                                        selectedItem = item
                                    }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("PortalPrivate")
                .sheet(item: $selectedItem) { item in
                    DetailView(item: item, selectedItem: $selectedItem)
                }
            }
            // Trigger the portal transition for the selected item
            .portalPrivateTransition(item: $selectedItem)
        }
        .environment(\.portalDebugOverlays, true)
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Use PortalPrivateDestination to show the mirrored view
                PortalPrivateDestination(id: item.id.uuidString)
                    .frame(width: 200, height: 200)
                    .background(Color.gray.opacity(0.1), in: .rect(cornerRadius: 20))
                    .padding()

                Text("Detail View")
                    .font(.title)
                    .bold()

                Text("This is showing the exact same view instance as the source using _UIPortalView. Notice the animation continues seamlessly!")
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedItem = nil
                    }
                }
            }
        }
    }
}

// MARK: - Data Model

struct Item: Identifiable {
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
        Item(name: "Moon", symbol: "moon.fill", color: .purple),
    ]
}

// MARK: - Preview

#if DEBUG
struct PortalPrivateExampleView_Previews: PreviewProvider {
    static var previews: some View {
        PortalPrivateExampleView()
    }
}
#endif
