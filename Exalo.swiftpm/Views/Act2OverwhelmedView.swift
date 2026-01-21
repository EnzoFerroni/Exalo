import SwiftUI

struct Act2OverwhelmedView: View {
    @Bindable var gameState: GameState
    
    @State private var darknessLevel = 0.95
    @State private var thoughts: [AnxiousThought] = []
    @State private var characterScale: CGFloat = 0.75
    @State private var shakeAmount: CGFloat = 0
    @State private var canContinue = false
    @State private var pulseAnimation = false
    @State private var shakeTimer: Timer?
    @State private var hapticTimer: Timer?
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.dark.ignoresSafeArea()
                
                // Anxious thoughts - red rectangles
                ForEach(thoughts) { thought in
                    RoundedRectangle(cornerRadius: layout.isIPad ? 6 : 4)
                        .stroke(Color.red.opacity(thought.opacity), lineWidth: layout.isIPad ? 3 : 2)
                        .frame(width: thought.width * (layout.isIPad ? 1.3 : 1), height: thought.height * (layout.isIPad ? 1.3 : 1))
                        .rotationEffect(.degrees(thought.rotation))
                        .position(thought.position)
                }
                
                // Character - stays overwhelmed
                CharacterView(
                    expression: .overwhelmed,
                    size: layout.characterSmall,
                    showWorryLines: true,
                    showSweatDrop: true
                )
                .scaleEffect(characterScale)
                .modifier(ShakeEffect(amount: shakeAmount))
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                
                // Tap indicator - fixed bottom
                VStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Text("tap to continue")
                            .font(.system(size: layout.footnote, design: .rounded))
                            .foregroundColor(AppColors.textOnDarkSecondary)
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                    }
                    .opacity(canContinue ? 1 : 0)
                    .frame(height: 60)
                    .padding(.bottom, layout.isIPad ? 60 : 50)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if canContinue {
                    Haptics.light()
                    stopTimers()
                    gameState.navigateTo(.lightAppears)
                }
            }
            .onAppear { startSequence(screenSize: geo.size, layout: layout) }
            .onDisappear { stopTimers() }
        }
    }
    
    private func stopTimers() {
        shakeTimer?.invalidate()
        hapticTimer?.invalidate()
        shakeTimer = nil
        hapticTimer = nil
    }
    
    private func startSequence(screenSize: CGSize, layout: AppLayout) {
        // Start shake animation
        withAnimation(.linear(duration: 0.06).repeatForever(autoreverses: true)) {
            shakeAmount = 4
        }
        
        // STRONG haptic feedback synced with shake - more intense!
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            Task { @MainActor in
                Haptics.heavy()
            }
        }
        
        // Add thoughts progressively
        addThoughts(count: 5, screenSize: screenSize, layout: layout, intensity: 0.6)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            addThoughts(count: 5, screenSize: screenSize, layout: layout, intensity: 0.8)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            addThoughts(count: 4, screenSize: screenSize, layout: layout, intensity: 1.0)
        }
        
        // Enable continue after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // Reduce haptic intensity when can continue
            hapticTimer?.invalidate()
            hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                Task { @MainActor in
                    Haptics.medium()
                }
            }
            
            withAnimation { canContinue = true }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { pulseAnimation = true }
        }
    }
    
    private func addThoughts(count: Int, screenSize: CGSize, layout: AppLayout, intensity: Double) {
        let margin: CGFloat = layout.isIPad ? 60 : 40
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                let thought = AnxiousThought(
                    width: CGFloat.random(in: 60...150),
                    height: CGFloat.random(in: 25...45),
                    position: CGPoint(
                        x: CGFloat.random(in: margin...(screenSize.width - margin)),
                        y: CGFloat.random(in: 100...(screenSize.height - 150))
                    ),
                    rotation: Double.random(in: -25...25),
                    opacity: Double.random(in: 0.4...0.8) * intensity
                )
                withAnimation(.easeIn(duration: 0.2)) { thoughts.append(thought) }
                Haptics.light()
            }
        }
    }
}

// MARK: - Models
struct AnxiousThought: Identifiable {
    let id = UUID()
    var width: CGFloat
    var height: CGFloat
    var position: CGPoint
    var rotation: Double
    var opacity: Double
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * (Bool.random() ? 1 : -1), y: 0))
    }
}

#Preview { Act2OverwhelmedView(gameState: GameState()) }
