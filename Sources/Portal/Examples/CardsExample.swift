#if DEBUG

let animationDuration: TimeInterval = 0.4
let animationExample: Animation = Animation.smooth(duration: animationDuration, extraBounce: 0.25)
let animationExampleExtraBounce: Animation = Animation.smooth(duration: animationDuration, extraBounce: 0.4)


import SwiftUI

struct CardInfo: Identifiable {
    let id = UUID() // Conforms to Identifiable!
    let title: String
    let gradientColors: [Color]
    let startPoint: UnitPoint = .topLeading
    let endPoint: UnitPoint = .bottomTrailing
}

struct CardDetailView: View {
    let card: CardInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // MARK: Destination View
            
            AnimatedGradient(item: card) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: card.gradientColors),
                            startPoint: card.startPoint,
                            endPoint: card.endPoint
                        )
                    )
            }
                .frame(width: 240, height: 240)
                .portalDestination(item: card)
                .padding(.top, 30)

            Text(card.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)

            Text("This gradient card showcases the portal transition effect when moving between views.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Close")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

public struct Portal_CardsExample: View {
    let cardData: [CardInfo] = [
        CardInfo(
            title: "Sunset",
            gradientColors: [
                Color(red: 0.98, green: 0.36, blue: 0.35),
                Color(red: 0.92, green: 0.25, blue: 0.48)
            ]
        ),
        CardInfo(
            title: "Ocean",
            gradientColors: [
                Color(red: 0.1, green: 0.6, blue: 0.8),
                Color(red: 0.2, green: 0.3, blue: 0.9)
            ]
        ),
        CardInfo(
            title: "Forest",
            gradientColors: [
                Color(red: 0.3, green: 0.8, blue: 0.5),
                Color(red: 0.1, green: 0.6, blue: 0.4)
            ]
        ),
        CardInfo(
            title: "Lavender",
            gradientColors: [
                Color(red: 0.6, green: 0.4, blue: 0.9),
                Color(red: 0.4, green: 0.2, blue: 0.8)
            ]
        ),
        CardInfo(
            title: "Amber",
            gradientColors: [
                Color(red: 0.95, green: 0.6, blue: 0.2),
                Color(red: 0.9, green: 0.4, blue: 0.1)
            ]
        ),
        CardInfo(
            title: "Rose",
            gradientColors: [
                Color(red: 0.9, green: 0.3, blue: 0.7),
                Color(red: 0.7, green: 0.1, blue: 0.5)
            ]
        ),
    ]

    // State to hold the currently selected card for the sheet/transition
    @State private var selectedCard: CardInfo? = nil

    // Grid layout configuration
    let columns: [GridItem] = Array(
        repeating: .init(.flexible()),
        count: 2 // Adjust number of columns as needed
    )
    
    public init() {}

    public var body: some View {
        // MARK: Wrap in Portal Container
        PortalContainer{
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Tap a gradient card to see portal transition")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(cardData) { card in
                                VStack(spacing: 12) {
                                    // MARK: Source View
                                    AnimatedGradient(item: card) {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: card.gradientColors),
                                                    startPoint: card.startPoint,
                                                    endPoint: card.endPoint
                                                )
                                            )
                                    }
                                        .frame(height: 120)
                                        .portalSource(item: card)

                                    Text(card.title)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                .padding(.bottom, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                // Set the selected card on tap to trigger sheet/transition
                                .onTapGesture {
                                    selectedCard = card
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                .sheet(item: $selectedCard) { card in
                    CardDetailView(card: card)
                }
                .portalTransition(
                    item: $selectedCard, // Driven by the optional Identifiable item
                    animation: animationExample,
                    animationDuration: animationDuration
                ) { card in
                    AnimatedGradient(item: card) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: card.gradientColors),
                                    startPoint: card.startPoint,
                                    endPoint: card.endPoint
                                )
                            )
                    }
                }
               
            }
            .navigationTitle("Gradient Cards")
        }
    }
}

struct AnimatedGradient<Content: View>: View {
    @EnvironmentObject private var portalModel: CrossModel
    public var item: CardInfo?
    @ViewBuilder let content: () -> Content
    
    @State private var layerScale: CGFloat = 1
    
    private var key: String? {
        guard let value = item else { return nil }
        return "\(value.id)"
    }
    
    var body: some View {
        let idx = portalModel.info.firstIndex(where: { $0.infoID == key })
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
//                    // 1) bump up
//                    withAnimation(animationExample) {
//                        layerScale = 1.25
//                    }
                    // 2) bounce back down
                    DispatchQueue.main.asyncAfter(deadline: .now() + (animationDuration / 2) - 0.1) {
                        withAnimation(animationExampleExtraBounce) {
                            layerScale = 1
                        }
                    }
                }
            }
    }
}
#endif
