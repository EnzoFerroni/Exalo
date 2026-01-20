import SwiftUI

// Act 2 - Character gets overwhelmed by dark thoughts
struct Act2OverwhelmedView: View {
    @Bindable var gameState: GameState
    
    @State private var darknessLevel: Double = 0
    @State private var thoughts: [AnxiousThought] = []
    @State private var characterScale: CGFloat = 1.0
    @State private var shakeAmount: CGFloat = 0
    @State private var canContinue: Bool = false
    @State private var pulseAnimation: Bool = false
    
    private let darkColor = Color(red: 0.08, green: 0.09, blue: 0.14)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.98, green: 0.95, blue: 0.8).ignoresSafeArea()
                darkColor.ignoresSafeArea().opacity(darknessLevel)
                
                // Anxious thoughts
                ForEach(thoughts) { thought in
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.red.opacity(thought.opacity), lineWidth: 2)
                        .frame(width: thought.width, height: thought.height)
                        .rotationEffect(.degrees(thought.rotation))
                        .position(thought.position)
                }
                
                // Fixed layout - title at top
                VStack {
                    Text("Act 2")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(darknessLevel > 0.5 ? .white.opacity(0.5) : .black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Capsule().stroke(darknessLevel > 0.5 ? Color.red.opacity(0.5) : Color.black, lineWidth: 2))
                    
                    Spacer()
                }
                .padding(.top, 50)
                
                // Character - fixed in center
                CharacterView(
                    expression: darknessLevel > 0.7 ? .overwhelmed : .worried,
                    size: 100,
                    showWorryLines: true,
                    showSweatDrop: darknessLevel > 0.3
                )
                .scaleEffect(characterScale)
                .modifier(ShakeEffect(amount: shakeAmount))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Tap indicator - fixed at bottom with constant frame
                VStack {
                    Spacer()
                    
                    // Always reserve space, just change opacity
                    VStack(spacing: 8) {
                        Text("Tap to continue")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 1.0)
                    }
                    .opacity(canContinue ? 1 : 0)
                    .frame(height: 50)
                    .padding(.bottom, 50)
                }
            }
            .onAppear { startSequence(screenSize: geometry.size) }
            .onTapGesture {
                if canContinue { gameState.navigateTo(.lightAppears) }
            }
        }
    }
    
    private func startSequence(screenSize: CGSize) {
        withAnimation(.easeIn(duration: 2.0)) { darknessLevel = 0.4 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            addThoughts(count: 3, screenSize: screenSize, intensity: 0.4)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 1.5)) {
                darknessLevel = 0.7
                characterScale = 0.9
            }
            addThoughts(count: 4, screenSize: screenSize, intensity: 0.6)
            withAnimation(.linear(duration: 0.08).repeatForever(autoreverses: true)) { shakeAmount = 3 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeIn(duration: 1.5)) {
                darknessLevel = 0.95
                characterScale = 0.75
            }
            addThoughts(count: 5, screenSize: screenSize, intensity: 0.8)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            withAnimation(.easeIn(duration: 0.5)) { canContinue = true }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { pulseAnimation = true }
        }
    }
    
    private func addThoughts(count: Int, screenSize: CGSize, intensity: Double) {
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                let thought = AnxiousThought(
                    width: CGFloat.random(in: 60...180),
                    height: CGFloat.random(in: 25...50),
                    position: CGPoint(
                        x: CGFloat.random(in: 40...(screenSize.width - 40)),
                        y: CGFloat.random(in: 120...(screenSize.height - 150))
                    ),
                    rotation: Double.random(in: -20...20),
                    opacity: Double.random(in: 0.3...0.7) * intensity
                )
                withAnimation(.easeIn(duration: 0.3)) { thoughts.append(thought) }
            }
        }
    }
}

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

#Preview {
    Act2OverwhelmedView(gameState: GameState())
}