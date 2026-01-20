import SwiftUI

// Inner Thoughts - The internal struggle becomes visible
struct InnerThoughtsView: View {
    @Bindable var gameState: GameState
    
    @State private var currentStep: Int = 0
    @State private var textOpacity: Double = 0
    @State private var thoughtBubbles: [ThoughtBubble] = []
    @State private var characterExpression: CharacterExpression = .worried
    @State private var showQuestionMark: Bool = false
    @State private var canTap: Bool = false
    
    private let backgroundColor = Color(red: 0.94, green: 0.90, blue: 0.82)
    
    private let innerSteps: [(main: String, sub: String, showBubbles: Bool)] = [
        ("The thoughts won't stop.", "", false),
        ("\"What if I fail?\"", "", true),
        ("\"Everyone is counting on me.\"", "", true),
        ("\"I can't let them down.\"", "", true),
        ("\"What if I'm not good enough?\"", "", true),
        ("\"I need to organize everything.\"", "Maybe if I just...", true),
        ("\"Where do I even start?\"", "", true)
    ]
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            // Floating thought bubbles
            ForEach(thoughtBubbles) { bubble in
                ThoughtBubbleItem(bubble: bubble)
            }
            
            VStack(spacing: 20) {
                Spacer()
                
                // Question marks appearing
                if showQuestionMark {
                    Text("?")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.black.opacity(0.6))
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Character
                CharacterView(
                    expression: characterExpression,
                    size: 90,
                    showWorryLines: currentStep >= 2,
                    showSweatDrop: currentStep >= 4
                )
                
                // Main thought
                VStack(spacing: 8) {
                    Text(innerSteps[currentStep].main)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    if !innerSteps[currentStep].sub.isEmpty {
                        Text(innerSteps[currentStep].sub)
                            .font(.system(size: 16))
                            .foregroundColor(.black.opacity(0.5))
                    }
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
        
        withAnimation(.easeIn(duration: 0.5)) {
            textOpacity = 1
        }
        
        // Add thought bubble for certain steps
        if innerSteps[currentStep].showBubbles {
            addThoughtBubble()
        }
        
        // Update character expression
        updateExpression()
        
        // Show question mark on later steps
        if currentStep >= 5 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showQuestionMark = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            canTap = true
        }
    }
    
    private func updateExpression() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentStep >= 5 {
                characterExpression = .overwhelmed
            } else if currentStep >= 3 {
                characterExpression = .sad
            } else if currentStep >= 1 {
                characterExpression = .worried
            }
        }
    }
    
    private func addThoughtBubble() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let bubble = ThoughtBubble(
            text: ["?", "...", "!", "..."].randomElement()!,
            position: CGPoint(
                x: CGFloat.random(in: 60...(screenWidth - 60)),
                y: CGFloat.random(in: 100...(screenHeight * 0.35))
            )
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            thoughtBubbles.append(bubble)
        }
        
        // Limit bubbles
        if thoughtBubbles.count > 8 {
            withAnimation {
                thoughtBubbles.removeFirst()
            }
        }
    }
    
    private func advanceStep() {
        guard canTap else { return }
        
        if currentStep < innerSteps.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) {
                textOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentStep += 1
                gameState.increaseStress(by: 0.1)
                animateStep()
            }
        } else {
            gameState.navigateTo(.breakingPoint)
        }
    }
}

// Thought bubble model
struct ThoughtBubble: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
}

// Thought bubble item view
struct ThoughtBubbleItem: View {
    var bubble: ThoughtBubble
    
    @State private var opacity: Double = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Text(bubble.text)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.black.opacity(0.4))
            .position(bubble.position)
            .offset(y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 0.6
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    yOffset = -10
                }
            }
    }
}

#Preview {
    InnerThoughtsView(gameState: GameState())
}
