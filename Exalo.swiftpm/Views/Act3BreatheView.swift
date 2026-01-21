import SwiftUI
import AVFoundation

struct Act3BreatheView: View {
    @Bindable var gameState: GameState
    
    // MARK: - State
    @State private var progress: CGFloat = 0
    @State private var isListening = false
    @State private var breathCount = 0
    @State private var showInstruction = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var textOpacity = 1.0
    @State private var circleScale: CGFloat = 1.0
    @State private var audioDetector: AudioBreathDetector?
    @State private var showCompletion = false
    @State private var orbPulse = false
    @State private var breathTimer: Timer?
    
    private let requiredBreaths = 3
    private let breathDuration: TimeInterval = 3.0
    
    // MARK: - Breath Phase
    private enum BreathPhase {
        case inhale, exhale
        var text: String { self == .inhale ? "Breathe in..." : "Breathe out..." }
        var nextPhase: BreathPhase { self == .inhale ? .exhale : .inhale }
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                // Background gradient - expands with progress
                backgroundGradient(geo: geo)
                
                // Light orb with speech bubble - positioned higher
                lightOrbSection(layout: layout, geo: geo)
                
                // Main content
                VStack(spacing: layout.spacing / 2) {
                    Spacer()
                    breathingCircle(layout: layout)
                    progressIndicators(layout: layout)
                    Spacer()
                    characterSection(layout: layout)
                }
                
                // Completion overlay
                if showCompletion {
                    completionOverlay(layout: layout)
                }
            }
        }
        .onAppear { startExercise() }
        .onDisappear { cleanup() }
    }
    
    // MARK: - View Components
    
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
                speechBubble(layout: layout)
                    .opacity(textOpacity)
            }
        }
        .position(x: layout.isIPad ? 120 : 85, y: geo.size.height * 0.12)
    }
    
    private func speechBubble(layout: AppLayout) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(breathPhase.text)
                .font(.system(size: layout.isIPad ? 18 : 15, weight: .semibold, design: .rounded))
            
            HStack(spacing: 6) {
                Image(systemName: "nose")
                Image(systemName: "arrow.right").font(.system(size: 10))
                Image(systemName: "mic.fill")
            }
            .font(.system(size: layout.isIPad ? 14 : 12))
            .foregroundColor(AppColors.textSecondary)
        }
        .foregroundColor(AppColors.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
    
    private func breathingCircle(layout: AppLayout) -> some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(RadialGradient(
                    colors: [AppColors.lightBlue.opacity(0.25), .clear],
                    center: .center,
                    startRadius: layout.isIPad ? 80 : 60,
                    endRadius: layout.isIPad ? 180 : 140
                ))
                .frame(width: layout.isIPad ? 360 : 280)
                .scaleEffect(circleScale)
            
            // Border circle
            Circle()
                .stroke(AppColors.lightBlue.opacity(0.5), lineWidth: layout.isIPad ? 4 : 3)
                .frame(width: layout.isIPad ? 200 : 150)
                .scaleEffect(circleScale)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(breathCount) / CGFloat(requiredBreaths))
                .stroke(AppColors.lightBlue, style: StrokeStyle(lineWidth: layout.isIPad ? 8 : 6, lineCap: .round))
                .frame(width: layout.isIPad ? 200 : 150)
                .rotationEffect(.degrees(-90))
            
            // Mic icon
            VStack(spacing: 8) {
                Image(systemName: isListening ? "mic.fill" : "mic")
                    .font(.system(size: layout.isIPad ? 50 : 38))
                    .foregroundColor(AppColors.lightBlue)
                
                if isListening {
                    Text("Listening...")
                        .font(.system(size: layout.isIPad ? 14 : 11, design: .rounded))
                        .foregroundColor(AppColors.lightBlue.opacity(0.7))
                }
            }
            .scaleEffect(circleScale * 0.9)
        }
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
            setupAudioDetector()
        }
    }
    
    private func startBreathingCycle() {
        // Start showing "Breathe in..." - circle expands
        withAnimation(.easeInOut(duration: breathDuration)) {
            circleScale = 1.2
        }
        
        // After first breath duration, start the cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
            animateToNextPhase()
        }
        
        // Timer for continuous breathing cycle (starts after first phase)
        breathTimer = Timer.scheduledTimer(withTimeInterval: breathDuration, repeats: true) { @Sendable _ in
            Task { @MainActor in
                animateToNextPhase()
            }
        }
    }
    
    private func animateToNextPhase() {
        // Fade out text
        withAnimation(.easeOut(duration: 0.15)) { textOpacity = 0 }
        
        // Change phase and fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            breathPhase = breathPhase.nextPhase
            withAnimation(.easeIn(duration: 0.15)) { textOpacity = 1 }
            
            // Circle animation based on new phase
            withAnimation(.easeInOut(duration: breathDuration - 0.2)) {
                circleScale = breathPhase == .inhale ? 1.2 : 1.0
            }
        }
    }
    
    private func setupAudioDetector() {
        audioDetector = AudioBreathDetector { handleBreathDetected() }
        audioDetector?.start()
        isListening = true
    }
    
    private func handleBreathDetected() {
        guard breathCount < requiredBreaths else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            breathCount += 1
            progress = CGFloat(breathCount) / CGFloat(requiredBreaths)
        }
        Haptics.success()
        
        if breathCount >= requiredBreaths {
            completeExercise()
        }
    }
    
    private func completeExercise() {
        cleanup()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.5)) { showCompletion = true }
        }
    }
    
    private func cleanup() {
        audioDetector?.stop()
        breathTimer?.invalidate()
        breathTimer = nil
        isListening = false
    }
}

// MARK: - Audio Detector
@MainActor
final class AudioBreathDetector {
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var onDetected: @MainActor () -> Void
    private var lastDetectionTime = Date.distantPast
    private let cooldownInterval: TimeInterval = 1.5
    private let threshold: Float = -15
    
    init(_ onDetected: @escaping @MainActor () -> Void) {
        self.onDetected = onDetected
    }
    
    func start() {
        let session = AVAudioSession.sharedInstance()
        
        AVAudioApplication.requestRecordPermission { granted in
            guard granted else { return }
            
            Task { @MainActor in
                self.setupRecorder(session: session)
            }
        }
    }
    
    private func setupRecorder(session: AVAudioSession) {
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("breath.m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1
            ]
            
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { @Sendable [weak self] _ in
                Task { @MainActor in
                    self?.checkAudioLevel()
                }
            }
        } catch {
            print("Audio setup error: \(error)")
        }
    }
    
    private func checkAudioLevel() {
        recorder?.updateMeters()
        let level = recorder?.averagePower(forChannel: 0) ?? -160
        let now = Date()
        
        if level > threshold && now.timeIntervalSince(lastDetectionTime) > cooldownInterval {
            lastDetectionTime = now
            onDetected()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        recorder = nil
    }
}

#Preview { Act3BreatheView(gameState: GameState()) }