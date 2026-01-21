import SwiftUI

struct EndingView: View {
    @Bindable var gameState: GameState
    
    @State private var step = 0
    @State private var textOpacity = 0.0
    @State private var canTap = false
    @State private var isTransitioning = false
    
    // Messages including anxiety information
    private let messages: [(main: String, sub: String, isInfo: Bool)] = [
        ("Sometimes, we just need to stop.", "And breathe.", false),
        ("You are not alone.", "1 in 4 people experience anxiety.", true),
        ("It's okay to feel overwhelmed.", "What matters is how we respond.", true),
        ("Breathing helps regulate your nervous system.", "It's a simple but powerful tool.", true),
        ("Remember:", "It's okay to slow down.", false),
        ("Thank you for playing.", "Take care of yourself. 💙", false)
    ]
    
    private var safeStep: Int { min(step, messages.count - 1) }
    private var currentMessage: (main: String, sub: String, isInfo: Bool) { messages[safeStep] }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.calm.ignoresSafeArea()
                
                // Subtle floating circles
                FloatingCirclesBackground()
                    .opacity(0.3)
                
                VStack(spacing: layout.spacing) {
                    Spacer()
                    
                    // Character
                    CharacterView(expression: .relieved, size: layout.characterSize, showRelief: true)
                    
                    // Message card
                    VStack(spacing: layout.isIPad ? 16 : 12) {
                        if currentMessage.isInfo {
                            // Info badge
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: layout.isIPad ? 16 : 14))
                                Text("Did you know?")
                                    .font(.system(size: layout.footnote, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(AppColors.lightBlue)
                            .padding(.bottom, 4)
                        }
                        
                        Text(currentMessage.main)
                            .font(.system(size: layout.title2, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        if !currentMessage.sub.isEmpty {
                            Text(currentMessage.sub)
                                .font(.system(size: layout.body, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .opacity(textOpacity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, layout.isIPad ? 40 : 30)
                    .padding(.vertical, layout.isIPad ? 30 : 24)
                    .frame(maxWidth: layout.maxContentWidth)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(currentMessage.isInfo ? 0.9 : 0.7))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                    .padding(.horizontal, layout.padding)
                    
                    Spacer()
                    
                    // Navigation
                    if step >= messages.count - 1 && canTap {
                        Button(action: {
                            Haptics.success()
                            gameState.resetGame()
                            gameState.navigateTo(.home)
                        }) {
                            Text("Home")
                                .font(.system(size: layout.body, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: layout.buttonWidth, height: layout.buttonHeight)
                                .background(Capsule().fill(Color.black.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, layout.isIPad ? 80 : 60)
                    } else {
                        TapIndicator(isVisible: canTap && !isTransitioning, layout: layout)
                            .padding(.bottom, layout.isIPad ? 60 : 40)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { advance() }
        }
        .onAppear { animateStep() }
    }
    
    private func animateStep() {
        textOpacity = 0
        canTap = false
        
        withAnimation(.easeIn(duration: 0.5)) { textOpacity = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { canTap = true }
    }
    
    private func advance() {
        guard canTap, !isTransitioning, step < messages.count - 1 else { return }
        isTransitioning = true
        Haptics.light()
        
        withAnimation(.easeOut(duration: 0.2)) { textOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            step += 1
            isTransitioning = false
            animateStep()
        }
    }
}

#Preview { EndingView(gameState: GameState()) }
