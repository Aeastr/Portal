//
//  NavigationExample.swift
//  Portal
//
//  Created by Aether on 21/04/2025.
//


#if DEBUG
import SwiftUI

private enum DemoSelection: Hashable {
    case red, purple
}


@available(iOS 16.0, *)
public struct Portal_NavigationExample: View {
    // MARK: – 1) Use an array for the stack
    @State private var path: [DemoSelection] = []
    @State private var useMatchingColors = true
    
    // MARK: – 2) Drive portal animations from `path`
    private var isShowingRed: Binding<Bool> {
        Binding(
            get: { path.contains(.red) },
            set: { new in
                if !new { path.removeAll(where: { $0 == .red }) }
            }
        )
    }
    private var isShowingPurple: Binding<Bool> {
        Binding(
            get: { path.contains(.purple) },
            set: { new in
                if !new { path.removeAll(where: { $0 == .purple }) }
            }
        )
    }
    
    // MARK: – 3) Gradients
    private let redGradient = [
        Color(red: 0.98, green: 0.36, blue: 0.35),
        Color(red: 0.92, green: 0.25, blue: 0.48),
    ]
    private let purpleGradient = [
        Color(red: 0.6, green: 0.4, blue: 0.9),
        Color(red: 0.4, green: 0.2, blue: 0.8),
    ]
    private let alt1 = [
        Color(red: 0.3, green: 0.8, blue: 0.5),
        Color(red: 0.1, green: 0.6, blue: 0.4),
    ]
    private let alt2 = [
        Color(red: 0.95, green: 0.6, blue: 0.2),
        Color(red: 0.9, green: 0.4, blue: 0.1),
    ]
    
    public init() {}
    
    public var body: some View {
        PortalContainer {
            NavigationStack(path: $path) {
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Tap a shape to navigate")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                        
                        HStack(spacing: 30) {
                            // RED source
                            VStack(spacing: 12) {
                                AnimatedLayer(id: "demo1") {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: .init(colors:
                                                                    useMatchingColors ? redGradient : alt1),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .frame(width: 100, height: 100)
                                .portalSource(id: "demo1")
                                .onTapGesture {
                                    withAnimation { path.append(.red) }
                                }
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                
                                Text("Red Shape")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            
                            // PURPLE source
                            VStack(spacing: 12) {
                                AnimatedLayer(id: "demo2") {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: .init(colors:
                                                                    useMatchingColors ? purpleGradient : alt2),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .frame(width: 100, height: 100)
                                .portalSource(id: "demo2")
                                .onTapGesture {
                                    withAnimation { path.append(.purple) }
                                }
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                
                                Text("Purple Shape")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 16)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Use matching colors", isOn: $useMatchingColors)
                                .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                            
                            Text(useMatchingColors
                                 ? "Colors match for smooth transitions"
                                 : "Different colors show transition breaks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationTitle("Navigation Portals")
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                // MARK: – 5) set up destinations
                .navigationDestination(for: DemoSelection.self) { sel in
                    switch sel {
                    case .red: DetailView(colorSet: useMatchingColors ? redGradient : alt1,
                                          id: "demo1")
                    case .purple: DetailView(colorSet: useMatchingColors ? purpleGradient : alt2,
                                             id: "demo2")
                    }
                }
                // MARK: – 6) portal transitions remain exactly the same
                .portalTransition(
                    id: "demo1",
                    isActive: isShowingRed,
                    animation: animationExample,
                    animationDuration: animationDuration
                ) {
                    AnimatedLayer(id: "demo1") {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: .init(colors:
                                                        useMatchingColors ? redGradient : alt1),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            } // NavigationStack
            
            .portalTransition(
                id: "demo2",
                isActive: isShowingPurple,
                animation: animationExample,
                animationDuration: animationDuration
            ) {
                AnimatedLayer(id: "demo2") {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: .init(colors:
                                                    useMatchingColors ? purpleGradient : alt2),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
        } // PortalContainer
    }
}

fileprivate struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    let colorSet: [Color]
    let id: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("\(id.capitalized) Expanded")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                AnimatedLayer(id: id) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: .init(colors: colorSet),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: 220, height: 220)
                .portalDestination(id: id)
                .onTapGesture {
                    withAnimation { dismiss() }
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Text("Tap to go back")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                Button(action: { withAnimation { dismiss() } }) {
                    Text("Dismiss")
                        .fontWeight(.semibold)
                        .frame(width: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
#endif
