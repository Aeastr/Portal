#if DEBUG
import SwiftUI


/// A demo view to showcase Sheet Portal transitions
public struct Portal_SheetExample: View {
    @State private var showDetailRed = false
    @State private var showDetailPurple = false
    @State private var useMatchingColors = true
    
    // Different gradient sets
    private let redGradient = [
        Color(red: 0.98, green: 0.36, blue: 0.35),
        Color(red: 0.92, green: 0.25, blue: 0.48)
    ]
    private let purpleGradient = [
        Color(red: 0.6, green: 0.4, blue: 0.9),
        Color(red: 0.4, green: 0.2, blue: 0.8)
    ]
    private let alternateGradient1 = [
        Color(red: 0.3, green: 0.8, blue: 0.5),
        Color(red: 0.1, green: 0.6, blue: 0.4)
    ]
    private let alternateGradient2 = [
        Color(red: 0.95, green: 0.6, blue: 0.2),
        Color(red: 0.9, green: 0.4, blue: 0.1)
    ]
    
    public init() {}
    
    public var body: some View {
        // MARK: Wrap in PortalContainer
        PortalContainer{
            NavigationView {
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("This demo shows how multiple portal transitions can work simultaneously.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                            
                            Text("Tap either shape to expand it")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            
                            // Two squares side by side
                            HStack(spacing: 30) {
                                VStack(spacing: 12) {
                                    // MARK: Red Rectangle Source
                                    AnimatedLayer(id: "redRect") {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: redGradient),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    .frame(width: 100, height: 100)
                                    .portalSource(id: "redRect")
                                    .onTapGesture { withAnimation { showDetailRed.toggle() } }
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    
                                    Text("Portal 1")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(spacing: 12) {
                                    // MARK: Purple Rectangle Source
                                    AnimatedLayer(id: "purpleRect") {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: purpleGradient),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    .frame(width: 100, height: 100)
                                    .portalSource(id: "purpleRect")
                                    .onTapGesture { withAnimation { showDetailPurple.toggle() } }
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    
                                    Text("Portal 2")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 100) // Space for the toggle control
                    }
                    .safeAreaInset(edge: .bottom, content: {
                        // Toggle for matching/different colors
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $useMatchingColors) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Use matching colors for all elements")
                                        .fontWeight(.medium)
                                    Text(
                                        useMatchingColors
                                        ? "All elements have the same appearance for smooth transitions"
                                        : "Elements have different colors to show how transitions can break"
                                    )
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                        }
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                                .ignoresSafeArea()
                        }
                    })
                    
                    // MARK: Red Rectangle Sheet
                    .sheet(isPresented: $showDetailRed) {
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Red Square Expanded")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 16)
                                
                                Spacer().frame(height: 30)
                                
                                // MARK: Red Rectangle Destination
                                AnimatedLayer(id: "redRect") {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: redGradient),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .frame(width: 220, height: 220)
                                .portalDestination(id: "redRect")
                                .onTapGesture { withAnimation { showDetailRed.toggle() } }
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                Spacer().frame(height: 30)
                                
                                Text("Tap to collapse")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 40)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                    
                    // MARK: Purple Rectangle Sheet
                    .sheet(isPresented: $showDetailPurple) {
                        ScrollView {
                            VStack(spacing: 24) {
                                Text("Purple Square Expanded")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 16)
                                
                                Spacer().frame(height: 30)
                                
                                // MARK: Purple Rectangle Destination
                                AnimatedLayer(id: "purpleRect") {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: purpleGradient),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .frame(width: 220, height: 220)
                                .portalDestination(id: "purpleRect")
                                .onTapGesture { withAnimation { showDetailPurple.toggle() } }
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                Spacer().frame(height: 30)
                                
                                Text("Tap to collapse")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 40)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                    
                    // Transition for first square (red)
                    .portalTransition(
                        id: "redRect",
                        isActive: $showDetailRed,
                        animation: animationExample,
                        animationDuration: animationDuration
                    ) {
                        AnimatedLayer(id: "redRect") {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: useMatchingColors ? redGradient : alternateGradient1),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    
                    // Transition for second square (purple)
                    .portalTransition(
                        id: "purpleRect",
                        isActive: $showDetailPurple,
                        animation: animationExample,
                        animationDuration: animationDuration
                    ) {
                        AnimatedLayer(id: "purpleRect") {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: useMatchingColors ? purpleGradient : alternateGradient2),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
                .navigationTitle("Portal Transition Demo")
            }
        }
    }
}

struct AnimatedLayer<Content: View>: View {
    @EnvironmentObject private var portalModel: CrossModel
    let id: String
    @ViewBuilder let content: () -> Content
    
    @State private var layerScale: CGFloat = 1
    
    var body: some View {
        let idx = portalModel.info.firstIndex { $0.infoID == id }
        let isActive = idx.flatMap { portalModel.info[$0].animateView } ?? false
        
        content()
            .scaleEffect(layerScale)
            .onAppear {
                // Ensure scale is correct on appear
                layerScale = 1
            }
            .onChangeCompat(of: isActive) { newValue in
                if newValue {
                    // 1) bump up
                    withAnimation(animationExample) {
                        layerScale = 1.25
                    }
                    // 2) bounce back down
                    DispatchQueue.main.asyncAfter(deadline: .now() + (animationDuration / 2) - 0.1) {
                        withAnimation(animationExampleExtraBounce) {
                            layerScale = 1
                        }
                    }
                } else {
                    // Reset scale when not active
                    withAnimation {
                        layerScale = 1
                    }
                }
            }
            .overlay(
                Group {
                    if idx == nil {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                    }
                }
            )
    }
}

#endif
