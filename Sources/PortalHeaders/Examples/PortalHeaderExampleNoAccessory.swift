//
//  PortalHeaderExampleNoAccessory.swift
//  Portal
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// PortalHeader example with no accessory
@available(iOS 18.0, *)
public struct PortalHeaderExampleNoAccessory: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                PortalHeaderView()

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
            .portalHeaderDestination()
        }
        .portalHeader(
            title: "Settings",
            subtitle: "Configure your preferences"
        )
    }
}

@available(iOS 18.0, *)
#Preview("No Accessory") {
    PortalHeaderExampleNoAccessory()
}

#endif
