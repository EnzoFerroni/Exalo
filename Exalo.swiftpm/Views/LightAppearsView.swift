import SwiftUI

struct LightAppearsView: View {
    @Bindable var gameState: GameState
    
    @State private var step = 0
    @State private var lightOpacity = 0.0
    @State private var orbScale: CGFloat = 0
    @State private var orbPulse = false
    @State private var textOpacity = 0.0
    @State private var showCharacter = false
    @State private var expression: CharacterExpression = .sad
    @State private var canTap = false
    @State private var isTransitioning = false
    
    // Light orb dialogue
    private let orbMessages = ["Hey...", "It's okay.", "Let's try something.", "Just breathe with me."]
    private var safeStep: Int { min(step, orbMessages.count - 1) }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.dark.ignoresSafeArea()
                
                // Light gradient from orb
                RadialGradient(
                    colors: [AppColors.lightBlue.opacity(lightOpacity * 0.3), .clear],
                    center: UnitPoint(x: 0.3, y: 0.25),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.8
                )
                .ignoresSafeArea()
                
                // Light Orb - the guide
                LightOrbView(scale: orbScale, isPulsing: orbPulse, layout: layout)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.25)
                
                // Orb's message
                if step < orbMessages.count {
                    Text(orbMessages[safeStep])
                        .font(.system(size: layout.headline, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.lightBlue)
                        .opacity(textOpacity)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.42)
                }
                
                // Character
                if showCharacter {
                    CharacterView(expression: expression, size: layout.characterSmall)
                        .position(x: geo.size.width * 0.65, y: geo.size.height * 0.65)
                }
                
                // Tap indicator
                TapIndicator(isVisible: canTap && !isTransitioning, color: .white, layout: layout)
                    .position(x: geo.size.width / 2, y: layout.bottomY)
            }
            .contentShape(Rectangle())
            .onTapGesture { advance() }
        }
        .onAppear { startSequence() }
    }
    
    private func startSequence() {
        withAnimation(.easeIn(duration: 1.5)) { lightOpacity = 1; orbScale = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { orbPulse = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn(duration: 0.5)) { textOpacity = 1 }
            Haptics.light()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showCharacter = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { canTap = true }
    }
    
    private func advance() {
        guard canTap, !isTransitioning else { return }
        isTransitioning = true
        Haptics.light()
        
        if step < orbMessages.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) { textOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                step += 1
                if step >= 2 { withAnimation { expression = .hopeful } }
                withAnimation(.easeIn(duration: 0.4)) { textOpacity = 1 }
                isTransitioning = false
            }
        } else {
            gameState.navigateTo(.act3Breathe)
        }
    }
}

// MARK: - Light Orb View (shared component)
struct LightOrbView: View {
    var scale: CGFloat
    var isPulsing: Bool
    var layout: AppLayout
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColors.lightBlue.opacity(0.4), AppColors.lightBlue.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: layout.isIPad ? 80 : 60
                    )
                )
                .frame(width: layout.isIPad ? 160 : 120)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, AppColors.lightBlue],
                        center: .center,
                        startRadius: 0,
                        endRadius: layout.isIPad ? 30 : 22
                    )
                )
                .frame(width: layout.isIPad ? 60 : 45)
                .shadow(color: AppColors.lightBlue, radius: 15)
            
            Circle()
                .fill(.white)
                .frame(width: layout.isIPad ? 12 : 8)
                .offset(x: layout.isIPad ? -12 : -8, y: layout.isIPad ? -12 : -8)
                .opacity(isPulsing ? 0.8 : 0.5)
        }
        .scaleEffect(scale)
    }
}

#Preview { LightAppearsView(gameState: GameState()) }
