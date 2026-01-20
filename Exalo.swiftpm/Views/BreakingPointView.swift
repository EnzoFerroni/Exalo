import SwiftUI

// Breaking Point - The moment everything becomes too much
struct BreakingPointView: View {
    @Bindable var gameState: GameState
    
    @State private var darknessOpacity: Double = 0
    @State private var characterScale: CGFloat = 1.0
    @State private var heartbeatScale: CGFloat = 1.0
    @State private var showText: Bool = false
    @State private var currentTextIndex: Int = 0
    @State private var textOpacity: Double = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var showHeartbeat: Bool = false
    
    private let lightBackground = Color(red: 0.94, green: 0.90, blue: 0.82)
    private let darkBackground = Color(red: 0.08, green: 0.09, blue: 0.14)
    
    private let breakingTexts: [String] = [
        "\"I just need to...\"",
        "\"I just...\"",
        "\"I...\"",
        "\"...\""
    ]
    
    var body: some View {
        ZStack {
            // Background transitioning from light to dark
            lightBackground
                .ignoresSafeArea()
            
            darkBackground
                .ignoresSafeArea()
                .opacity(darknessOpacity)
            
            // Heartbeat circle
            if showHeartbeat {
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 3)
                    .frame(width: 200, height: 200)
                    .scaleEffect(heartbeatScale)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Character shrinking and shaking
                CharacterView(
                    expression: .overwhelmed,
                    size: 90,
                    showWorryLines: true,
                    showSweatDrop: true
                )
                .scaleEffect(characterScale)
                .offset(x: shakeOffset)
                
                // Breaking text
                if showText {
                    Text(breakingTexts[currentTextIndex])
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(darknessOpacity > 0.5 ? .white.opacity(0.7) : .black.opacity(0.7))
                        .opacity(textOpacity)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startBreakingSequence()
        }
    }
    
    private func startBreakingSequence() {
        // Phase 1: Show heartbeat
        showHeartbeat = true
        startHeartbeat()
        
        // Phase 2: Start shaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startShaking()
        }
        
        // Phase 3: Show texts with increasing darkness
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showText = true
            showBreakingTexts()
        }
    }
    
    private func startHeartbeat() {
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
            heartbeatScale = 1.15
        }
        
        // Speed up heartbeat over time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
                heartbeatScale = 1.2
            }
        }
    }
    
    private func startShaking() {
        withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
            shakeOffset = 2
        }
    }
    
    private func showBreakingTexts() {
        let interval: Double = 1.5
        
        for i in 0..<breakingTexts.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                // Fade out previous
                withAnimation(.easeOut(duration: 0.2)) {
                    textOpacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentTextIndex = i
                    
                    // Fade in new
                    withAnimation(.easeIn(duration: 0.3)) {
                        textOpacity = 1
                    }
                    
                    // Increase darkness
                    withAnimation(.easeIn(duration: 1.0)) {
                        darknessOpacity = Double(i + 1) / Double(breakingTexts.count)
                    }
                    
                    // Shrink character
                    withAnimation(.easeIn(duration: 0.5)) {
                        characterScale = 1.0 - (CGFloat(i) * 0.1)
                    }
                }
            }
        }
        
        // Transition to overwhelmed after all texts
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(breakingTexts.count) * interval + 0.5) {
            gameState.navigateTo(.act2Overwhelmed)
        }
    }
}

#Preview {
    BreakingPointView(gameState: GameState())
}
