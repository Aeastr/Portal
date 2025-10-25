//
//  Example.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// Basic FlowingHeader example with accessory and title flowing to nav bar
@available(iOS 18.0, *)
private struct Example: View {
    public init() {}

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView()

                LazyVStack(spacing: 12) {
                    ForEach(0..<20) { index in
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colors[index % colors.count].gradient)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Photo \(index + 1)")
                                    .font(.headline)
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .flowingHeaderDestination(displays: [.title, .accessory])
        }
        .flowingHeader(
            title: "Photos",
            subtitle: "My Collection",
            displays: [.title, .accessory]
        ) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
        }
    }
}

/// FlowingHeader example with title-only transition
@available(iOS 18.0, *)
public struct ExampleTitleOnly: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView()

                LazyVStack(spacing: 16) {
                    ForEach(0..<10) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item \(index + 1)")
                                .font(.headline)
                            Text("Description of item \(index + 1)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .flowingHeaderDestination(displays: [.title])
        }
        .flowingHeader(
            title: "Analytics",
            subtitle: "Business Dashboard",
            displays: [.title]
        ) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
        }
    }
}

/// FlowingHeader example with no accessory
@available(iOS 18.0, *)
public struct ExampleNoAccessory: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                FlowingHeaderView()

                LazyVStack(spacing: 12) {
                    ForEach(0..<15) { index in
                        Text("List item \(index + 1)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .flowingHeaderDestination()
        }
        .flowingHeader(
            title: "Settings",
            subtitle: "Configure your preferences"
        )
    }
}

@available(iOS 18.0, *)
#Preview("Title Only Transition") {
    ExampleTitleOnly()
}

@available(iOS 18.0, *)
#Preview("No Accessory") {
    ExampleNoAccessory()
}

@available(iOS 18.0, *)
#Preview("All") {
    Example()
}

#endif
