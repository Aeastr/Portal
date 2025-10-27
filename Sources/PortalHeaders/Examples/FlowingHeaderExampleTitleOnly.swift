//
//  PortalHeaderExampleTitleOnly.swift
//  PortalPortalHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// PortalHeader example with title-only transition
@available(iOS 18.0, *)
public struct PortalHeaderExampleTitleOnly: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                PortalHeaderView()

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
            .portalHeaderDestination()
        }
        .portalHeader(
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

@available(iOS 18.0, *)
#Preview("Title Only Transition") {
    PortalHeaderExampleTitleOnly()
}

#endif
