//
//  PortalPrivateExampleNoSheet.swift
//  Portal
//
//  Test if the shift issue occurs without using a sheet
//

import SwiftUI
import Portal
import PortalView
import PortalPrivate

public struct PortalPrivateExampleNoSheetView: View {
    @State private var selectedItem: Item? = nil
    @State private var items = Item.sampleItems

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
                                        .portalPrivate(id: item.id.uuidString)
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
                .portalPrivateTransition(item: $selectedItem)

                // Overlay instead of sheet
                if let item = selectedItem {
                    DetailOverlayView(item: item, selectedItem: $selectedItem)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .zIndex(100)
                }
            }
        }
        .environment(\.portalDebugOverlays, false)
    }
}

struct DetailOverlayView: View {
    let item: Item
    @Binding var selectedItem: Item?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PortalPrivateDestination(id: item.id.uuidString)
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
struct PortalPrivateExampleNoSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PortalPrivateExampleNoSheetView()
    }
}
#endif