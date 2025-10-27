//
//  DebugOverlayIndicator.swift
//  PortalPortalHeader
//
//  Created by Aether, 2025.
//
//  Copyright © 2025 Aether. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// MARK: - Debug Overlay Label

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

// MARK: - Complete Debug Overlay

@available(iOS 18.0, *)
internal struct PortalHeaderDebugOverlay: View {
    let text: String
    let color: Color
    let components: PortalHeaderDebugOverlayComponent

    init(_ text: String, color: Color, showing components: PortalHeaderDebugOverlayComponent) {
        self.text = text
        self.color = color
        self.components = components
    }

    var body: some View {
        Group {
            if components.contains(.border) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 2)
                    .overlay(
                        Group {
                            if components.contains(.label) {
                                DebugOverlayIndicator(text, color: color)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                    .padding(5)
                            }
                        }
                    )
            }

            if components.contains(.label) && !components.contains(.border) {
                DebugOverlayIndicator(text, color: color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(5)
            }
        }
    }
}
