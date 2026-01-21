import SwiftUI

struct MorningSceneView: View {
    @Bindable var gameState: GameState
    
    @State private var step = 0
    @State private var textOpacity = 0.0
    @State private var canTap = false
    @State private var isTransitioning = false
    @State private var expression: CharacterExpression = .normal
    @State private var sunProgress: CGFloat = 0
    @State private var floatingThoughts: [FloatingThought] = []
    
    // Natural narrative flow
    private let steps: [(main: String, sub: String, expr: CharacterExpression, thought: String?)] = [
        ("The sun rises.", "A new day begins.", .normal, nil),
        ("And so do the expectations...", "", .normal, "Be productive"),
        ("", "", .worried, "Don't disappoint anyone"),
        ("", "", .worried, "Be perfect"),
        ("", "", .sad, "Don't make mistakes"),
        ("Am I enough?", "", .sad, "Be enough"),
        ("The thoughts keep coming...", "", .overwhelmed, nil)
    ]
    
    private var safeStep: Int { min(step, steps.count - 1) }
    private var currentStep: (main: String, sub: String, expr: CharacterExpression, thought: String?) { steps[safeStep] }
    
    // Sunrise gradient based on progress
    private var bgGradient: LinearGradient {
        let sunriseProgress = min(sunProgress, 0.5) * 2
        let stressProgress = max(0, sunProgress - 0.5) * 2
        
        return LinearGradient(
            colors: [
                Color(red: 0.98 - stressProgress * 0.1, green: 0.92 - stressProgress * 0.12, blue: 0.85 - stressProgress * 0.05),
                Color(red: 1.0, green: 0.95 - sunriseProgress * 0.1, blue: 0.88 - sunriseProgress * 0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                bgGradient.ignoresSafeArea().animation(.easeInOut(duration: 0.8), value: sunProgress)
                
                // Sun rising animation
                SunView(progress: sunProgress, layout: layout)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.15)
                
                // Floating thoughts - appear naturally
                ForEach(floatingThoughts) { thought in
                    ThoughtCloudView(text: thought.text, layout: layout)
                        .position(thought.position)
                        .opacity(thought.opacity)
                        .transition(.scale.combined(with: .opacity))
                }
                
                VStack(spacing: layout.spacing / 2) {
                    Spacer()
                    
                    CharacterView(
                        expression: expression,
                        size: layout.characterSmall,
                        showWorryLines: step >= 4,
                        showSweatDrop: step >= 5
                    )
                    
                    // Only show text when there is text
                    if !currentStep.main.isEmpty {
                        NarrativeText(main: currentStep.main, sub: currentStep.sub, layout: layout)
                            .opacity(textOpacity)
                    } else {
                        // Show the thought appearing message
                        Text("tap to continue")
                            .font(.system(size: layout.footnote, design: .rounded))
                            .foregroundColor(AppColors.textTertiary)
                            .opacity(canTap ? 0.6 : 0)
                    }
                    
                    Spacer()
                    
                    TapIndicator(isVisible: canTap && !isTransitioning && !currentStep.main.isEmpty, layout: layout)
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
        
        withAnimation(.easeInOut(duration: 0.3)) { expression = currentStep.expr }
        withAnimation(.easeIn(duration: 0.4)) { textOpacity = 1 }
        
        // Update sun progress
        withAnimation(.easeInOut(duration: 0.6)) {
            sunProgress = CGFloat(step) / CGFloat(steps.count - 1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { canTap = true }
    }
    
    private func advance(in geo: GeometryProxy) {
        guard canTap, !isTransitioning else { return }
        isTransitioning = true
        Haptics.light()
        
        // Add floating thought if this step has one
        if let thought = currentStep.thought {
            addFloatingThought(text: thought, in: geo)
            Haptics.medium()
        }
        
        if step < steps.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) { textOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                step += 1
                gameState.increaseStress(by: 0.1)
                isTransitioning = false
                animateStep()
            }
        } else {
            gameState.navigateTo(.workScene)
        }
    }
    
    // Fixed positions for thoughts to avoid overlap
    private func getThoughtPosition(index: Int, in geo: GeometryProxy) -> CGPoint {
        let positions: [(xRatio: CGFloat, yRatio: CGFloat)] = [
            (0.2, 0.12),   // Top left
            (0.8, 0.15),   // Top right
            (0.15, 0.28),  // Mid left
            (0.85, 0.30),  // Mid right
            (0.5, 0.08),   // Top center
        ]
        let pos = positions[index % positions.count]
        return CGPoint(x: geo.size.width * pos.xRatio, y: geo.size.height * pos.yRatio)
    }
    
    private func addFloatingThought(text: String, in geo: GeometryProxy) {
        let thought = FloatingThought(
            text: text,
            position: getThoughtPosition(index: floatingThoughts.count, in: geo),
            opacity: 0.85
        )
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            floatingThoughts.append(thought)
        }
    }
}

// MARK: - Sun View
struct SunView: View {
    var progress: CGFloat
    var layout: AppLayout
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.9, blue: 0.6),
                        Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.5),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: layout.isIPad ? 100 : 70
                )
            )
            .frame(width: layout.isIPad ? 200 : 140, height: layout.isIPad ? 200 : 140)
            .opacity(0.3 + progress * 0.5)
            .offset(y: (1 - progress) * 50)
    }
}

// MARK: - Thought Cloud View
struct ThoughtCloudView: View {
    var text: String
    var layout: AppLayout
    
    @State private var float = false
    
    var body: some View {
        Text("\"\(text)\"")
            .font(.system(size: layout.isIPad ? 16 : 13, weight: .medium, design: .rounded))
            .foregroundColor(AppColors.textSecondary)
            .padding(.horizontal, layout.isIPad ? 16 : 12)
            .padding(.vertical, layout.isIPad ? 10 : 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
            .offset(y: float ? -5 : 5)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { float = true }
            }
    }
}

// MARK: - Floating Thought Model
struct FloatingThought: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var opacity: Double
}

#Preview { MorningSceneView(gameState: GameState()) }
