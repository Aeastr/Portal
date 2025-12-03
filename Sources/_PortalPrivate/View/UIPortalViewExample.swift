//
//  UIPortalViewExample.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//
#if DEBUG
import SwiftUI

struct UIPortalViewExample: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var sourceContainer: SourceViewContainer<AnyView>?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("This demo shows UIKit's portal view, a private API that displays the same view instance in multiple locations. The Source and Portal views share identical UUIDs and animations because they're literally the same UIView - the portal is just a window into the source.")
                        .font(.body)
                }

                Section {
                    animatedContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } header: {
                    Text("Standalone SwiftUI View")
                } footer: {
                    Text("New instance created each render")
                }

                Section {
                    if let container = sourceContainer {
                        SourceViewRepresentable(
                            container: container,
                            content: AnyView(animatedContent)
                        )
                    }
                } header: {
                    Text("Source View")
                } footer: {
                    Text("UIHostingController - the real view instance")
                }

                Section {
                    if let container = sourceContainer {
                        PortalView(
                            source: container,
                            hidesSource: false,
                            matchesPosition: false
                        )
                    }
                } header: {
                    Text("Portal View")
                } footer: {
                    Text("Portal view showing the same instance")
                }
            }
            .listStyle(.insetGrouped)
            .contentMargins(.top, 0, for: .scrollContent)
            .safeAreaPadding(.bottom, 40)
            .navigationTitle("UIPortalView Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        withAnimation(.spring(response: 0.6)) {
                            rotation += 45
                        }
                    } label: {
                        Label("Rotate", systemImage: "rotate.right")
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.6)) {
                            scale = scale == 1.0 ? 1.5 : 1.0
                        }
                    } label: {
                        Label("Scale", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                }
            }
        }
        .onAppear {
            if sourceContainer == nil {
                sourceContainer = SourceViewContainer(content: AnyView(animatedContent))
            }
        }
    }

    var animatedContent: some View {
        AnimatedContentView(rotation: rotation, scale: scale)
    }
}

struct AnimatedContentView: View {
    let rotation: Double
    let scale: CGFloat
    private let id = UUID()
    private let symbolColor = Color(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1)
    )
    private let symbolName = [
        "globe", "star.fill", "heart.fill", "flame.fill",
        "bolt.fill", "leaf.fill", "cloud.fill", "moon.fill",
        "sun.max.fill", "sparkles"
    ].randomElement() ?? "globe"

    var body: some View {
        VStack {
            Image(systemName: symbolName)
                .imageScale(.large)
                .font(.system(size: 50))
                .foregroundStyle(symbolColor)
            Text("\(id)")
                .font(.caption)
                .monospaced()
                .fontWeight(.semibold)
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
    }
}

#Preview {
    UIPortalViewExample()
}
#endif
