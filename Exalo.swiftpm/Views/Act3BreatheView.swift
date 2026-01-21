import SwiftUI

struct Act3BreatheView: View {
    @Bindable var gameState: GameState
    
    @State private var progress: CGFloat = 0
    @State private var breathCount = 0
    @State private var showInstruction = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var textOpacity = 1.0
    @State private var circleScale: CGFloat = 1.0
    @State private var showCompletion = false
    @State private var orbPulse = false
    @State private var breathTimer: Timer?
    
    private let requiredBreaths = 3
    private let breathDuration: TimeInterval = 3.0
    
    private enum BreathPhase {
        case inhale, exhale
        var text: String { self == .inhale ? "Breathe in..." : "Breathe out..." }
    }
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                backgroundGradient(geo: geo)
                lightOrbSection(layout: layout, geo: geo)
                
                VStack(spacing: layout.spacing / 2) {
                    Spacer()
                    breathingCircle(layout: layout)
                    progressIndicators(layout: layout)
                    Spacer()
                    characterSection(layout: layout)
                }
                
                if showCompletion { completionOverlay(layout: layout) }
            }
        }
        .onAppear { startExercise() }
        .onDisappear { cleanup() }
    }
    
    // MARK: - Views
    
    private func backgroundGradient(geo: GeometryProxy) -> some View {
        RadialGradient(
            stops: [
                .init(color: AppColors.calm, location: 0),
                .init(color: AppColors.calm.opacity(0.8), location: progress * 0.4),
                .init(color: AppColors.dark.opacity(1.0 - progress * 0.7), location: 0.5 + progress * 0.3),
                .init(color: AppColors.dark, location: 1)
            ],
            center: UnitPoint(x: 0.5, y: 0.15),
            startRadius: 0,
            endRadius: geo.size.height * (0.3 + progress * 0.7)
        )
        .ignoresSafeArea()
        .animation(.easeOut(duration: 1), value: progress)
    }
    
    private func lightOrbSection(layout: AppLayout, geo: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LightOrbView(scale: 0.6, isPulsing: orbPulse, layout: layout)
            
            if showInstruction && !showCompletion {
                VStack(alignment: .leading, spacing: 6) {
                    Text(breathPhase.text)
                        .font(.system(size: layout.isIPad ? 18 : 15, weight: .semibold, design: .rounded))
                    
                    if breathPhase == .exhale {
                        HStack(spacing: 6) {
                            Text("Now tap")
                            Image(systemName: "hand.tap.fill")
                        }
                        .font(.system(size: layout.isIPad ? 14 : 12))
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                )
                .opacity(textOpacity)
            }
        }
        .position(x: layout.isIPad ? 120 : 85, y: geo.size.height * 0.12)
    }
    
    private func breathingCircle(layout: AppLayout) -> some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [AppColors.lightBlue.opacity(0.25), .clear],
                    center: .center,
                    startRadius: layout.isIPad ? 80 : 60,
                    endRadius: layout.isIPad ? 180 : 140
                ))
                .frame(width: layout.isIPad ? 360 : 280)
                .scaleEffect(circleScale)
            
            Circle()
                .stroke(AppColors.lightBlue.opacity(0.5), lineWidth: layout.isIPad ? 4 : 3)
                .frame(width: layout.isIPad ? 200 : 150)
                .scaleEffect(circleScale)
            
            Circle()
                .trim(from: 0, to: CGFloat(breathCount) / CGFloat(requiredBreaths))
                .stroke(AppColors.lightBlue, style: StrokeStyle(lineWidth: layout.isIPad ? 8 : 6, lineCap: .round))
                .frame(width: layout.isIPad ? 200 : 150)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 8) {
                Image(systemName: "wind")
                    .font(.system(size: layout.isIPad ? 50 : 38))
                    .foregroundColor(AppColors.lightBlue)
                
                Text("Tap to breathe")
                    .font(.system(size: layout.isIPad ? 14 : 11, design: .rounded))
                    .foregroundColor(AppColors.lightBlue.opacity(0.7))
            }
            .scaleEffect(circleScale * 0.9)
        }
        .contentShape(Circle())
        .onTapGesture { handleBreathTap() }
    }
    
    private func progressIndicators(layout: AppLayout) -> some View {
        HStack(spacing: layout.isIPad ? 16 : 12) {
            ForEach(0..<requiredBreaths, id: \.self) { i in
                Circle()
                    .fill(i < breathCount ? AppColors.lightBlue : AppColors.lightBlue.opacity(0.3))
                    .frame(width: layout.isIPad ? 18 : 14)
            }
        }
        .padding(.top, 20)
    }
    
    private func characterSection(layout: AppLayout) -> some View {
        CharacterView(
            expression: breathCount >= requiredBreaths ? .relieved : (breathCount > 0 ? .happy : .sad),
            size: layout.characterSmall * 0.85,
            showRelief: breathCount >= requiredBreaths
        )
        .padding(.bottom, layout.isIPad ? 60 : 40)
    }
    
    private func completionOverlay(layout: AppLayout) -> some View {
        ZStack {
            AppColors.calm.ignoresSafeArea()
            
            VStack(spacing: layout.isIPad ? 30 : 24) {
                CharacterView(expression: .relieved, size: layout.characterSize, showRelief: true)
                
                Text("\"You did it.\"")
                    .font(.system(size: layout.title3, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Button(action: {
                    Haptics.success()
                    gameState.navigateTo(.ending)
                }) {
                    Text("Continue")
                        .font(.system(size: layout.body, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: layout.buttonWidth, height: layout.buttonHeight)
                        .background(Capsule().fill(AppColors.lightBlue))
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Logic
    
    private func startExercise() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            orbPulse = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showInstruction = true }
            startBreathingCycle()
        }
    }
    
    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breathDuration)) {
            circleScale = 1.2
        }
        
        // Single timer - starts after first inhale completes
        breathTimer = Timer.scheduledTimer(withTimeInterval: breathDuration, repeats: true) { _ in
            DispatchQueue.main.async { animateToNextPhase() }
        }
    }
    
    private func animateToNextPhase() {
        withAnimation(.easeOut(duration: 0.15)) { textOpacity = 0 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            breathPhase = breathPhase == .inhale ? .exhale : .inhale
            withAnimation(.easeIn(duration: 0.15)) { textOpacity = 1 }
            withAnimation(.easeInOut(duration: breathDuration - 0.2)) {
                circleScale = breathPhase == .inhale ? 1.2 : 1.0
            }
        }
    }
    
    private func handleBreathTap() {
        guard breathCount < requiredBreaths else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            breathCount += 1
            progress = CGFloat(breathCount) / CGFloat(requiredBreaths)
        }
        Haptics.success()
        
        if breathCount >= requiredBreaths { completeExercise() }
    }
    
    private func completeExercise() {
        cleanup()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.5)) { showCompletion = true }
        }
    }
    
    private func cleanup() {
        breathTimer?.invalidate()
        breathTimer = nil
    }
}

#Preview { Act3BreatheView(gameState: GameState()) }
