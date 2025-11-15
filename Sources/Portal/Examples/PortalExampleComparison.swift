//
//  PortalExampleComparison.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// Comparison example showing Portal vs native iOS transitions
/// Shows Portal vs native iOS transition features
@available(iOS 17, *)
public struct PortalExampleComparison: View {
    @State private var showPortalSheet = false
    @State private var showNativeSheet = false
    @State private var showZoomSheet = false
    @Namespace private var namespace

    public init() {}

    public var body: some View {
        PortalContainer {
            NavigationView {
                ScrollView {
                    VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("Compare Portal's cross-boundary transitions with native iOS behavior. Tap each card to see the difference.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        // MARK: Portal Example
                        VStack(spacing: 12) {
                            Text("Portal")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)

                            AnimatedLayer(portalID: "portalDemo") {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 28, weight: .semibold))
                                                .foregroundColor(.white)
                                            Text("Portal")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                        }
                                    )
                            }
                            .frame(width: 160, height: 120)
                            .portal(id: "portalDemo", .source)
                            .onTapGesture {
                                    showPortalSheet.toggle()
                            }

                            Text("Cross-boundary transitions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        // MARK: Native Example
                        VStack(spacing: 12) {
                            Text("Native")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)

                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 28, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("Native")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                )
                                .frame(width: 160, height: 120)
                                .onTapGesture {
                                    showNativeSheet.toggle()
                                }

                            Text("No cross-boundary support")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        // MARK: iOS 18 Zoom Example - Only show on iOS 18+
                        if #available(iOS 18.0, *) {
                            VStack(spacing: 12) {
                                Text("iOS 18 Zoom")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)

                                VStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Zoom")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .frame(width: 160, height: 120)
                                .matchedTransitionSource(id: "zoomDemo", in: namespace) { body in
                                    body
                                        .background(Color.green)
                                        .clipShape(.rect(cornerRadius: 16))
                                }
                                .onTapGesture {
                                    showZoomSheet.toggle()
                                }

                                Text("Zoom presentation style")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }

                    Spacer()
                    }
                    .padding()
                }
                .navigationTitle("Portal vs Native Comparison")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            }
            .sheet(isPresented: $showPortalSheet) {
                PortalExamplePortalComparisonSheet()
            }
            .sheet(isPresented: $showNativeSheet) {
                PortalExampleNativeComparisonSheet()
            }
            .sheet(isPresented: $showZoomSheet) {
                if #available(iOS 18.0, *) {
                    PortalExampleZoomComparisonSheet(namespace: namespace)
                        .navigationTransition(.zoom(sourceID: "zoomDemo", in: namespace))
                }
            }
            .portalTransition(
            id: "portalDemo",
            config: .init(animation: PortalAnimation(portalAnimationExample)),
            isActive: $showPortalSheet
        ) {
            AnimatedLayer(portalID: "portalDemo") {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Portal")
                                .font(.title3)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    )
            }
            }
        }
    }
}

@available(iOS 17, *)
private struct PortalExamplePortalComparisonSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Portal Destination
                    AnimatedLayer(portalID: "portalDemo") {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Portal")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            )
                    }
                    .frame(width: 280, height: 200)
                    .portal(id: "portalDemo", .destination)

                    Text("This element seamlessly transitioned from the main view using Portal. Portal enables cross-boundary transitions that aren't possible with standard SwiftUI.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .padding(.top, 20)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Portal Transition")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

@available(iOS 17, *)
private struct PortalExampleNativeComparisonSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: Native - No transition possible
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 50, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("No Transition")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        )
                        .frame(width: 280, height: 200)

                    Text("This element appeared without any transition because native SwiftUI cannot create cross-boundary transitions. The original element and this one exist in different view hierarchies.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .padding(.top, 20)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Native Transition")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

@available(iOS 18.0, *)
@available(iOS 17, *)
private struct PortalExampleZoomComparisonSheet: View {
    @Environment(\.dismiss) var dismiss
    let namespace: Namespace.ID

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: iOS 18 Zoom - Works with matchedGeometryEffect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Zoom Works!")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        )
                        .frame(width: 280, height: 200)

                    Text("iOS 18's zoom transition presents the sheet with a zoom animation that originates from the tapped element. It's a presentation style, not an element transition - the sheet zooms from the source element's position.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .padding(.top, 20)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("iOS 18 Zoom")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

#if os(iOS)
#Preview {
    if #available(iOS 17, *) {
        PortalExampleComparison()
    } else {
        Text("Requires iOS 17 or newer")
    }
}
#endif

#endif
