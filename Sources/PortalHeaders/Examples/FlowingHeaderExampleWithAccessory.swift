//
//  PortalHeaderExampleWithAccessory.swift
//  PortalHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// Basic PortalHeader example with accessory and title flowing to nav bar
@available(iOS 18.0, *)
public struct PortalHeaderExampleWithAccessory: View {
    public init() {}

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    public var body: some View {
        NavigationStack {
            ScrollView {
                PortalHeaderView()

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
            .portalHeaderDestination()
        }
        .portalHeader(
            title: "Photos",
            subtitle: "My Collection"
        ) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
        }
    }
}

@available(iOS 18.0, *)
#Preview("With Accessory") {
    PortalHeaderExampleWithAccessory()
}

#endif
