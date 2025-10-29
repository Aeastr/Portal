//
//  PortalExampleStaticID.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// Portal static ID example showing code block transitions
public struct PortalExampleStaticID: View {
    @State private var showDetail = false

    public init() {}

    public var body: some View {
        PortalContainer {
            NavigationView {
                VStack(spacing: 90) {
                    VStack(spacing: 12) {
                        Text("Portal enables seamless transitions using static IDs too. Tap the code block to see it transition across sheet boundaries.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }


                    // MARK: Source Code Block
                    VStack(spacing: 32) {
                        AnimatedLayer(portalID: "codeBlock") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 12, height: 12)
                                    Circle()
                                        .fill(.yellow)
                                        .frame(width: 12, height: 12)
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 12, height: 12)
                                    Spacer()
                                    Text("Portal.swift")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(".portal(id: \"hero\", .source)")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.blue)
                                    Text(".PortalTransitions(")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.purple)
                                    Text("  id: \"hero\",")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.primary)
                                    Text("  isActive: $showDetail")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.primary)
                                    Text(")")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.purple)
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                        }
                        .frame(width: 280, height: 140)
                        .portal(id: "codeBlock", .source)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showDetail.toggle()
                            }
                        }

                        Text("Portal Code Block")
                            .font(.headline)
                            .fontWeight(.medium)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("Static ID Example")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
            .sheet(isPresented: $showDetail) {
                PortalExampleStaticIDDetail()
            }
            .PortalTransitions(
                id: "codeBlock",
                isActive: $showDetail,
                animation: .spring(response: 0.4, dampingFraction: 0.8)
            ) {
                AnimatedLayer(portalID: "codeBlock") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(.red)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(.yellow)
                                .frame(width: 12, height: 12)
                            Circle()
                                .fill(.green)
                                .frame(width: 12, height: 12)
                            Spacer()
                            Text("Portal.swift")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(".portal(id: \"hero\", .source)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.blue)
                            Text(".PortalTransitions(")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.purple)
                            Text("  id: \"hero\",")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                            Text("  isActive: $showDetail")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                            Text(")")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                }
            }
        }
    }
}

private struct PortalExampleStaticIDDetail: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // MARK: Destination Code Block
                    AnimatedLayer(portalID: "codeBlock") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 12, height: 12)
                                Circle()
                                    .fill(.yellow)
                                    .frame(width: 12, height: 12)
                                Circle()
                                    .fill(.green)
                                    .frame(width: 12, height: 12)
                                Spacer()
                                Text("Portal.swift")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(".portal(id: \"hero\", .source)")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.blue)
                                Text(".PortalTransitions(")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.purple)
                                Text("  id: \"hero\",")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("  isActive: $showDetail")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text(")")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.purple)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                    }
                    .portal(id: "codeBlock", .destination)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)


                        Text("This code block transitioned seamlessly from the main view.  Portal enables these cross-boundary transitions that aren't possible with standard SwiftUI.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle("Code Block Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

#Preview("Static ID Example") {
    PortalExampleStaticID()
}

#Preview("Static ID Example Detail") {
    PortalExampleStaticIDDetail()
}

#endif
