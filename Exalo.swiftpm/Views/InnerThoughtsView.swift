import SwiftUI

struct InnerThoughtsView: View {
    @Bindable var gameState: GameState
    
    @State private var step = 0
    @State private var textOpacity = 0.0
    @State private var canTap = false
    @State private var isTransitioning = false
    @State private var expression: CharacterExpression = .sad
    @State private var thoughtBubbles: [ThoughtBubble] = []
    
    // Condensed thoughts
    private let steps: [(main: String, sub: String)] = [
        ("The thoughts won't stop.", ""),
        ("\"What if I fail?\"", ""),
        ("\"What if I'm not good enough?\"", ""),
        ("It's getting harder to think...", "")
    ]
    
    private var safeStep: Int { min(step, steps.count - 1) }
    private var currentStep: (main: String, sub: String) { steps[safeStep] }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                // Muted, stressed background
                Color(red: 0.92 - CGFloat(step) * 0.03, green: 0.88 - CGFloat(step) * 0.05, blue: 0.80)
                    .ignoresSafeArea()
                
                // Thought bubbles floating
                ForEach(thoughtBubbles) { bubble in
                    Text(bubble.text)
                        .font(.system(size: layout.isIPad ? 32 : 24, weight: .bold))
                        .foregroundColor(AppColors.textTertiary)
                        .position(bubble.position)
                }
                
                VStack(spacing: layout.spacing / 2) {
                    Spacer()
                    
                    CharacterView(
                        expression: expression,
                        size: layout.characterSmall,
                        showWorryLines: true,
                        showSweatDrop: step >= 2
                    )
                    
                    NarrativeText(main: currentStep.main, sub: currentStep.sub, layout: layout)
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    TapIndicator(isVisible: canTap && !isTransitioning, layout: layout)
                        .padding(.bottom, layout.isIPad ? 60 : 40)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { advance(in: geo) }
        }
        .onAppear { animateStep() }
    }
    
    private func animateStep() {
        textOpacity = 0
        canTap = false
        
        withAnimation(.easeInOut(duration: 0.3)) {
            expression = step >= 2 ? .overwhelmed : .sad
        }
        
        withAnimation(.easeIn(duration: 0.4)) { textOpacity = 1 }
        
        // Add thought bubble
        if step >= 1 { addThoughtBubble() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { canTap = true }
    }
    
    private func addThoughtBubble() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let symbols = ["?", "...", "!", "?!"]
        
        let bubble = ThoughtBubble(
            text: symbols[min(step - 1, symbols.count - 1)],
            position: CGPoint(
                x: CGFloat.random(in: 60...(screenWidth - 60)),
                y: CGFloat.random(in: 80...(screenHeight * 0.35))
            )
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            thoughtBubbles.append(bubble)
        }
        Haptics.light()
    }
    
    private func advance(in geo: GeometryProxy) {
        guard canTap, !isTransitioning else { return }
        isTransitioning = true
        Haptics.medium()
        
        if step < steps.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) { textOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                step += 1
                gameState.increaseStress(by: 0.15)
                isTransitioning = false
                animateStep()
            }
        } else {
            gameState.navigateTo(.breakingPoint)
        }
    }
}

// MARK: - Thought Bubble
struct ThoughtBubble: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
}

#Preview { InnerThoughtsView(gameState: GameState()) }
