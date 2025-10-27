//
//  FlowingHeaderExampleNoAccessory.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

#if DEBUG
import SwiftUI

/// FlowingHeader example with no accessory
@available(iOS 18.0, *)
public struct FlowingHeaderExampleNoAccessory: View {
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
#Preview("No Accessory") {
    FlowingHeaderExampleNoAccessory()
}

#endif
