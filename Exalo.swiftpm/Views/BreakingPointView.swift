import SwiftUI

struct BreakingPointView: View {
    @Bindable var gameState: GameState
    
    @State private var darkness = 0.0
    @State private var scale: CGFloat = 1.0
    @State private var heartScale: CGFloat = 1.0
    @State private var textIndex = 0
    @State private var textOpacity = 0.0
    @State private var shake: CGFloat = 0
    @State private var heartbeatTimer: Timer?
    @State private var shakeTimer: Timer?
    
    private let texts = ["\"I just need to...\"", "\"I just...\"", "\"...\""]
    private var safeText: String { texts[min(textIndex, texts.count - 1)] }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.background.ignoresSafeArea()
                AppColors.dark.ignoresSafeArea().opacity(darkness)
                
                // Heartbeat circle
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: layout.isIPad ? 4 : 3)
                    .frame(width: layout.isIPad ? 280 : 200)
                    .scaleEffect(heartScale)
                    .position(x: geo.size.width / 2, y: layout.characterY)
                
                // Character - stays overwhelmed
                CharacterView(expression: .overwhelmed, size: layout.characterSmall, showWorryLines: true, showSweatDrop: true)
                    .scaleEffect(scale)
                    .offset(x: shake)
                    .position(x: geo.size.width / 2, y: layout.characterY)
                
                // Text
                Text(safeText)
                    .font(.system(size: layout.headline, weight: .medium, design: .rounded))
                    .foregroundColor(darkness > 0.5 ? .white.opacity(0.7) : AppColors.textPrimary.opacity(0.7))
                    .opacity(textOpacity)
                    .position(x: geo.size.width / 2, y: layout.textY)
            }
        }
        .onAppear { startSequence() }
        .onDisappear { stopTimers() }
    }
    
    private func stopTimers() {
        heartbeatTimer?.invalidate()
        shakeTimer?.invalidate()
        heartbeatTimer = nil
        shakeTimer = nil
    }
    
    private func startSequence() {
        // Heartbeat animation
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) { heartScale = 1.15 }
        withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) { shake = 2 }
        
        // Haptic heartbeat - strong pulsing
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { @Sendable _ in
            Task { @MainActor in
                Haptics.heavy()
            }
        }
        
        // Haptic shake - continuous vibration
        shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { @Sendable _ in
            Task { @MainActor in
                Haptics.medium()
            }
        }
        
        // Progressive darkness
        for i in 0..<texts.count {
            let delay = 1.0 + Double(i) * 1.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.2)) { textOpacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    textIndex = min(i, texts.count - 1)
                    withAnimation(.easeIn(duration: 1)) {
                        darkness = Double(i + 1) / Double(texts.count)
                        scale = 1.0 - CGFloat(i) * 0.1
                    }
                    withAnimation { textOpacity = 1 }
                }
            }
        }
        
        // Transition after sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            stopTimers()
            gameState.navigateTo(.act2Overwhelmed)
        }
    }
}

#Preview { BreakingPointView(gameState: GameState()) }