import SwiftUI

struct EndingView: View {
    @Bindable var gameState: GameState
    
    @State private var showContent = false
    @State private var showCards = false
    @State private var showButton = false
    
    // Impactful info cards about anxiety with better explanations
    private let infoCards: [(icon: String, title: String, message: String, color: Color)] = [
        ("person.3.fill", "You're Not Alone", "Over 300 million people worldwide live with anxiety. It's one of the most common mental health experiences — and it's okay to talk about it.", Color(red: 0.5, green: 0.7, blue: 0.9)),
        ("heart.fill", "Your Feelings Matter", "Anxiety isn't weakness — it's your mind trying to protect you. Acknowledging your feelings is the first step toward understanding them.", Color(red: 0.9, green: 0.6, blue: 0.6)),
        ("wind", "Breathing Changes Everything", "When you breathe deeply, you activate your parasympathetic nervous system, telling your body: 'I am safe.' This simple act can transform a moment of panic into peace.", Color(red: 0.6, green: 0.85, blue: 0.65))
    ]
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.calm.ignoresSafeArea()
                FloatingCirclesBackground().opacity(0.3)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: layout.isIPad ? 28 : 22) {
                        Spacer(minLength: layout.isIPad ? 40 : 30)
                        
                        // Character
                        CharacterView(expression: .relieved, size: layout.characterSmall * 0.85, showRelief: true)
                            .opacity(showContent ? 1 : 0)
                            .scaleEffect(showContent ? 1 : 0.8)
                        
                        // Main message
                        VStack(spacing: 8) {
                            Text("Remember:")
                                .font(.system(size: layout.body, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("It's okay to slow down.")
                                .font(.system(size: layout.title3, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .opacity(showContent ? 1 : 0)
                        .multilineTextAlignment(.center)
                        
                        // Three info cards stacked
                        VStack(spacing: layout.isIPad ? 16 : 12) {
                            ForEach(0..<infoCards.count, id: \.self) { i in
                                EndingInfoCard(card: infoCards[i], layout: layout, delay: Double(i) * 0.15)
                                    .opacity(showCards ? 1 : 0)
                                    .offset(y: showCards ? 0 : 20)
                            }
                        }
                        .padding(.horizontal, layout.padding)
                        
                        // Final inspiring message
                        VStack(spacing: 6) {
                            Text("\"You just took the first step.\"")
                                .font(.system(size: layout.body, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .italic()
                            
                            Text("Take care of yourself. 💙")
                                .font(.system(size: layout.headline, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .opacity(showCards ? 1 : 0)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        
                        // Try Again button
                        Button(action: {
                            Haptics.success()
                            gameState.resetGame()
                            gameState.navigateTo(.home)
                        }) {
                            Text("Try Again")
                                .font(.system(size: layout.body, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: layout.buttonWidth, height: layout.buttonHeight)
                                .background(Capsule().fill(Color.black.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                        .opacity(showButton ? 1 : 0)
                        .padding(.top, 12)
                        .padding(.bottom, layout.isIPad ? 50 : 40)
                    }
                }
            }
        }
        .onAppear { animateIn() }
    }
    
    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) { showContent = true }
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) { showCards = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.8)) { showButton = true }
    }
}

// MARK: - Ending Info Card
struct EndingInfoCard: View {
    let card: (icon: String, title: String, message: String, color: Color)
    let layout: AppLayout
    var delay: Double = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: layout.isIPad ? 16 : 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(card.color.opacity(0.25))
                    .frame(width: layout.isIPad ? 50 : 44, height: layout.isIPad ? 50 : 44)
                
                Image(systemName: card.icon)
                    .font(.system(size: layout.isIPad ? 22 : 18))
                    .foregroundColor(card.color)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(size: layout.body, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(card.message)
                    .font(.system(size: layout.footnote, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(layout.isIPad ? 18 : 16)
        .frame(maxWidth: layout.maxContentWidth)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.92))
                .shadow(color: card.color.opacity(0.15), radius: 8, y: 4)
        )
    }
}

#Preview { EndingView(gameState: GameState()) }