//
//  DebugOverlayIndicator.swift
//  PortalFlowingHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

internal struct DebugOverlayIndicator: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = .pink) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Text(text)
                    .font(.caption2)
                    .padding(.horizontal, 3)
                    .padding(6)
                    .glassEffect(.regular.tint(color.opacity(0.6)))
                    .foregroundStyle(.white)
            } else {
                Text(text)
                    .font(.caption2)
                    .padding(.horizontal, 3)
                    .padding(6)
                    .background(color.opacity(0.6))
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    .foregroundStyle(.white)
            }
        }
        .allowsHitTesting(false)
    }
}
