import SwiftUI

struct PrologueView: View {
    @Bindable var gameState: GameState
    
    @State private var step = 0
    @State private var textOpacity = 0.0
    @State private var charOpacity = 0.0
    @State private var canTap = false
    @State private var isTransitioning = false
    @State private var showName = false
    
    // Condensed narrative
    private let steps: [(main: String, sub: String)] = [
        ("This is a story", "about someone you might know."),
        ("Someone who carries", "the weight of expectations."),
        ("Meet", ""),
        ("This could be", "your story too.")
    ]
    
    private var safeStep: Int { min(step, steps.count - 1) }
    private var currentStep: (main: String, sub: String) { steps[safeStep] }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.background.ignoresSafeArea()
                FloatingCirclesBackground()
                
                VStack(spacing: layout.spacing) {
                    Spacer()
                    
                    // Character appears from step 1
                    if step >= 1 {
                        VStack(spacing: layout.isIPad ? 16 : 10) {
                            CharacterView(
                                expression: step == 2 ? .happy : .worried,
                                size: step >= 2 ? layout.characterSize : layout.characterSmall
                            )
                            .opacity(charOpacity)
                            
                            // Name with better color - using primary text on accent pill
                            if showName {
                                Text("Exalo")
                                    .font(.system(size: layout.title2, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(AppColors.accent))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    
                    // Narrative text
                    NarrativeText(main: currentStep.main, sub: currentStep.sub, layout: layout)
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    // Tap indicator
                    VStack {
                        if step == 2 && !showName {
                            Text("Tap to meet them")
                                .font(.system(size: layout.footnote, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            TapIndicator(isVisible: canTap && !isTransitioning, layout: layout)
                        }
                    }
                    .frame(height: 60)
                    .padding(.bottom, layout.isIPad ? 60 : 40)
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
        if step >= 1 { withAnimation(.easeIn(duration: 0.4).delay(0.2)) { charOpacity = 1 } }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { canTap = true }
    }
    
    private func advance() {
        guard canTap, !isTransitioning else { return }
        isTransitioning = true
        Haptics.medium()
        
        // Reveal character name
        if step == 2 && !showName {
            Haptics.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showName = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { goToNextStep() }
            return
        }
        
        goToNextStep()
    }
    
    private func goToNextStep() {
        if step < steps.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) { textOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                step += 1
                isTransitioning = false
                animateStep()
            }
        } else {
            gameState.navigateTo(.morningScene)
        }
    }
}

#Preview { PrologueView(gameState: GameState()) }
