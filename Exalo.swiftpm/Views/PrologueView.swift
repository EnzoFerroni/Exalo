import SwiftUI

// Prologue - Introduction to the character and their world
struct PrologueView: View {
    @Bindable var gameState: GameState
    
    @State private var currentStep: Int = 0
    @State private var textOpacity: Double = 0
    @State private var characterOpacity: Double = 0
    @State private var canTap: Bool = false
    
    private let backgroundColor = Color(red: 0.98, green: 0.95, blue: 0.8)
    
    private let prologueSteps: [(text: String, subtext: String)] = [
        ("This is a story", "about someone you might know."),
        ("Someone who always tries", "to do everything right."),
        ("Someone who carries", "the weight of expectations."),
        ("Someone who forgets", "that it's okay to just... be."),
        ("This is a story", "about you. About me. About us.")
    ]
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            FloatingCirclesBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Character appears in later steps
                if currentStep >= 2 {
                    CharacterView(
                        expression: currentStep >= 4 ? .worried : .normal,
                        size: 100
                    )
                    .opacity(characterOpacity)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Narrative text
                VStack(spacing: 12) {
                    Text(prologueSteps[currentStep].text)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text(prologueSteps[currentStep].subtext)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Tap indicator - always present, just change opacity
                Text("tap to continue")
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.3))
                    .opacity(canTap ? 1 : 0)
                    .frame(height: 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateStep()
        }
        .onTapGesture {
            advanceStep()
        }
    }
    
    private func animateStep() {
        textOpacity = 0
        canTap = false
        
        withAnimation(.easeIn(duration: 0.6)) {
            textOpacity = 1
        }
        
        if currentStep >= 2 {
            withAnimation(.easeIn(duration: 0.5).delay(0.2)) {
                characterOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            canTap = true
        }
    }
    
    private func advanceStep() {
        guard canTap else { return }
        
        if currentStep < prologueSteps.count - 1 {
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentStep += 1
                animateStep()
            }
        } else {
            gameState.navigateTo(.morningScene)
        }
    }
}

#Preview {
    PrologueView(gameState: GameState())
}
