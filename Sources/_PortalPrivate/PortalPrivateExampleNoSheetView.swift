//
//  PortalPrivateExampleNoSheet.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import PortalTransitions


public struct PortalPrivateExampleNoSheetView: View {
    @State private var selectedItem: Item?
    @State private var items = Item.sampleItems
    @Namespace private var portalNamespace

    public init() {}

    public var body: some View {
        PortalContainer {
            ZStack {
                // Main content
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Testing without sheet - using overlay instead")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            LazyVGrid(columns: [
                                .init(),
                                .init(),
                                .init()
                            ], spacing: 16) {
                                ForEach(items) { item in
                                    CardView(item: item)
                                        .portalSourcePrivate(id: item.id.uuidString, in: portalNamespace)
                                        .onTapGesture {
                                            withAnimation(.smooth(duration: 0.45)) {
                                                selectedItem = item
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    .navigationTitle("No Sheet Test")
                }
                .portalPrivateTransition(item: $selectedItem, in: portalNamespace)

                // Overlay instead of sheet
                if let item = selectedItem {
                    DetailOverlayView(item: item, selectedItem: $selectedItem, namespace: portalNamespace)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .zIndex(100)
                }
            }
        }
        .portalTransitionDebugOverlays(false)
    }
}

struct DetailOverlayView: View {
    let item: Item
    @Binding var selectedItem: Item?
    let namespace: Namespace.ID

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PortalPrivateDestination(id: item.id.uuidString, in: namespace)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()

                Text("Overlay View (Not a Sheet)")
                    .font(.title)
                    .bold()

                Text("Testing if the shift still occurs without sheet presentation")
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        withAnimation(.smooth(duration: 0.45)) {
                            selectedItem = nil
                        }
                    }
                }
            }
        }
        .background(.regularMaterial)
    }
}

// MARK: - Preview

#if DEBUG
struct PortalPrivateExampleNoSheetViewPreviews: PreviewProvider {
    static var previews: some View {
        PortalPrivateExampleNoSheetView()
    }
}
#endif
