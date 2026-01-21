import SwiftUI
import AVFoundation

struct Act3BreatheView: View {
    @Bindable var gameState: GameState
    
    @State private var progress: CGFloat = 0
    @State private var isListening = false
    @State private var breathCount = 0
    @State private var showInstruction = false
    @State private var breatheIn = true
    @State private var circleScale: CGFloat = 1.0
    @State private var audioDetector: AudioBreathDetector?
    @State private var showCompletion = false
    @State private var orbPulse = false
    @State private var breathTimer: Timer?
    
    private let requiredBreaths = 3
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                // Natural radial gradient
                RadialGradient(
                    stops: [
                        .init(color: AppColors.calm, location: 0),
                        .init(color: AppColors.calm.opacity(0.8), location: progress * 0.4),
                        .init(color: AppColors.dark.opacity(1.0 - progress * 0.7), location: 0.5 + progress * 0.3),
                        .init(color: AppColors.dark, location: 1)
                    ],
                    center: UnitPoint(x: 0.5, y: 0.2),
                    startRadius: 0,
                    endRadius: geo.size.height * (0.3 + progress * 0.7)
                )
                .ignoresSafeArea()
                .animation(.easeOut(duration: 1), value: progress)
                
                // Light orb guide (uses shared component from LightAppearsView)
                LightOrbView(scale: 0.7, isPulsing: orbPulse, layout: layout)
                    .position(x: geo.size.width * 0.2, y: geo.size.height * 0.15)
                    .opacity(0.8)
                
                VStack(spacing: layout.spacing / 2) {
                    Spacer()
                    
                    // Breathing instruction
                    if showInstruction && !showCompletion {
                        VStack(spacing: layout.isIPad ? 16 : 12) {
                            HStack(spacing: 12) {
                                Image(systemName: breatheIn ? "arrow.down" : "arrow.up")
                                    .font(.system(size: layout.isIPad ? 24 : 18, weight: .medium))
                                Text(breatheIn ? "Breathe in..." : "Breathe out...")
                                    .font(.system(size: layout.headline, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppColors.lightBlue)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "nose")
                                Text("→")
                                Image(systemName: "mic.fill")
                            }
                            .font(.system(size: layout.isIPad ? 18 : 14))
                            .foregroundColor(.white.opacity(0.6))
                            
                            Text("Inhale through nose, exhale into microphone")
                                .font(.system(size: layout.footnote, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.bottom, 20)
                    }
                    
                    // Main breathing circle
                    ZStack {
                        Circle()
                            .fill(RadialGradient(colors: [AppColors.lightBlue.opacity(0.25), .clear], center: .center, startRadius: layout.isIPad ? 80 : 60, endRadius: layout.isIPad ? 180 : 140))
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
                    
                    // Progress indicators
                    HStack(spacing: layout.isIPad ? 16 : 12) {
                        ForEach(0..<requiredBreaths, id: \.self) { i in
                            Circle()
                                .fill(i < breathCount ? AppColors.lightBlue : AppColors.lightBlue.opacity(0.3))
                                .frame(width: layout.isIPad ? 18 : 14)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Character
                    CharacterView(
                        expression: breathCount >= requiredBreaths ? .relieved : (breathCount > 0 ? .happy : .sad),
                        size: layout.characterSmall * 0.85,
                        showRelief: breathCount >= requiredBreaths
                    )
                    .padding(.bottom, layout.isIPad ? 60 : 40)
                }
                
                // Completion overlay
                if showCompletion {
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
            }
        }
        .onAppear { startExercise() }
        .onDisappear { 
            audioDetector?.stop()
            breathTimer?.invalidate()
        }
    }
    
    private func startExercise() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { orbPulse = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showInstruction = true }
            startBreathingAnimation()
            audioDetector = AudioBreathDetector { handleBreath() }
            audioDetector?.start()
            isListening = true
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3.8)) { circleScale = 1.2; breatheIn = false }
        
        breathTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 3.8)) {
                    breatheIn.toggle()
                    circleScale = breatheIn ? 1.0 : 1.2
                }
            }
        }
    }
    
    private func handleBreath() {
        guard breathCount < requiredBreaths else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            breathCount += 1
            progress = CGFloat(breathCount) / CGFloat(requiredBreaths)
        }
        Haptics.success()
        
        if breathCount >= requiredBreaths {
            audioDetector?.stop()
            breathTimer?.invalidate()
            isListening = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.5)) { showCompletion = true }
            }
        }
    }
}

// MARK: - Audio Detector
@MainActor
final class AudioBreathDetector {
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var onDetected: @MainActor () -> Void
    private var lastTime = Date()
    
    init(_ onDetected: @escaping @MainActor () -> Void) { self.onDetected = onDetected }
    
    func start() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]
            recorder = try AVAudioRecorder(url: URL(fileURLWithPath: "/dev/null"), settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.check() }
            }
        } catch { print("Audio error: \(error)") }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        recorder = nil
    }
    
    private func check() {
        recorder?.updateMeters()
        guard let level = recorder?.averagePower(forChannel: 0), level > -20 else { return }
        let now = Date()
        if now.timeIntervalSince(lastTime) >= 2.0 {
            lastTime = now
            onDetected()
        }
    }
}

#Preview { Act3BreatheView(gameState: GameState()) }
