import SwiftUI
import AVFoundation

// Act 3 - Breathing exercise with microphone detection
struct Act3BreatheView: View {
    @Bindable var gameState: GameState
    
    @State private var showLight: Bool = false
    @State private var breathingProgress: CGFloat = 0
    @State private var isListening: Bool = false
    @State private var breathCount: Int = 0
    @State private var showInstruction: Bool = false
    @State private var circleScale: CGFloat = 1.0
    @State private var audioDetector: AudioBreathDetector?
    @State private var showCompletion: Bool = false
    
    private let darkColor = Color(red: 0.08, green: 0.09, blue: 0.14)
    private let lightBlue = Color(red: 0.4, green: 0.6, blue: 0.9)
    
    private let requiredBreaths = 3
    
    var body: some View {
        ZStack {
            // Dark background
            darkColor
                .ignoresSafeArea()
            
            // Light rays when breathing
            if showLight {
                LightRaysView(intensity: breathingProgress)
            }
            
            // Floating calm bubbles
            CalmBubblesView(progress: breathingProgress)
            
            VStack(spacing: 30) {
                // Act title
                Text("Act 3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .stroke(lightBlue.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.top, 40)
                
                Spacer()
                
                // Breathing circle with microphone icon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [lightBlue.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 60,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(circleScale)
                    
                    // Main circle
                    Circle()
                        .stroke(lightBlue.opacity(0.6), lineWidth: 4)
                        .frame(width: 150, height: 150)
                        .scaleEffect(circleScale)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: CGFloat(breathCount) / CGFloat(requiredBreaths))
                        .stroke(lightBlue, lineWidth: 6)
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    // Microphone icon
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.system(size: 50))
                        .foregroundColor(lightBlue)
                        .scaleEffect(circleScale)
                }
                
                // Instruction text
                VStack(spacing: 12) {
                    if showInstruction {
                        Text("BREATHE...")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(lightBlue)
                            .opacity(isListening ? 1 : 0.5)
                        
                        Text("Blow gently into the microphone")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        // Breath counter
                        HStack(spacing: 8) {
                            ForEach(0..<requiredBreaths, id: \.self) { index in
                                Circle()
                                    .fill(index < breathCount ? lightBlue : lightBlue.opacity(0.3))
                                    .frame(width: 12, height: 12)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .frame(height: 100)
                
                Spacer()
                
                // Character at bottom
                CharacterView(
                    expression: breathCount >= requiredBreaths ? .relieved : (breathCount > 0 ? .happy : .sad),
                    size: 80,
                    showRelief: breathCount >= requiredBreaths
                )
                .padding(.bottom, 50)
            }
            
            // Completion overlay
            if showCompletion {
                CompletionView(onContinue: {
                    gameState.navigateTo(.ending)
                })
                .transition(.opacity)
            }
        }
        .onAppear {
            startBreathingExercise()
        }
        .onDisappear {
            audioDetector?.stopListening()
        }
    }
    
    private func startBreathingExercise() {
        // Show light gradually
        withAnimation(.easeIn(duration: 1.5)) {
            showLight = true
        }
        
        // Show instruction
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showInstruction = true
            }
            
            // Start breathing animation
            startBreathingAnimation()
            
            // Start audio detection
            setupAudioDetection()
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            circleScale = 1.15
        }
    }
    
    private func setupAudioDetection() {
        audioDetector = AudioBreathDetector { detected in
            if detected {
                handleBreathDetected()
            }
        }
        audioDetector?.startListening()
        isListening = true
    }
    
    private func handleBreathDetected() {
        guard breathCount < requiredBreaths else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            breathCount += 1
            breathingProgress = CGFloat(breathCount) / CGFloat(requiredBreaths)
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Check completion
        if breathCount >= requiredBreaths {
            completeExercise()
        }
    }
    
    private func completeExercise() {
        audioDetector?.stopListening()
        isListening = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                showCompletion = true
            }
        }
    }
}

// Light rays effect
struct LightRaysView: View {
    var intensity: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Central light
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.1 * Double(intensity)),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6
                )
                
                // Light rays
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.05), Color.clear],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 20, height: geometry.size.height * 0.4)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .opacity(Double(intensity) * 0.5)
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
        }
    }
}

// Calm floating bubbles
struct CalmBubblesView: View {
    var progress: CGFloat
    
    @State private var bubbles: [CalmBubble] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(Color(red: 0.5, green: 0.7, blue: 0.9).opacity(bubble.opacity))
                        .frame(width: bubble.size, height: bubble.size)
                        .position(bubble.position)
                }
            }
        }
        .onAppear {
            generateBubbles()
        }
        .onChange(of: progress) { _, newValue in
            if newValue > 0 {
                addBubble()
            }
        }
    }
    
    private func generateBubbles() {
        for _ in 0..<5 {
            addBubble()
        }
    }
    
    private func addBubble() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let bubble = CalmBubble(
            size: CGFloat.random(in: 20...60),
            position: CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight)
            ),
            opacity: Double.random(in: 0.1...0.3)
        )
        
        withAnimation(.easeInOut(duration: 2.0)) {
            bubbles.append(bubble)
        }
        
        if bubbles.count > 12 {
            bubbles.removeFirst()
        }
    }
}

struct CalmBubble: Identifiable {
    let id = UUID()
    var size: CGFloat
    var position: CGPoint
    var opacity: Double
}

// Completion view
struct CompletionView: View {
    var onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                CharacterView(expression: .relieved, size: 100, showRelief: true)
                
                Text("\"Sometimes, we just need to stop\nand breathe.\"")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button(action: onContinue) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.top, 20)
            }
            .padding(40)
        }
    }
}

// Audio breath detector using AVFoundation
@MainActor
final class AudioBreathDetector: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var onBreathDetected: @MainActor (Bool) -> Void
    private var lastBreathTime: Date = Date()
    private let minimumBreathInterval: TimeInterval = 1.5
    
    init(onBreathDetected: @escaping @MainActor (Bool) -> Void) {
        self.onBreathDetected = onBreathDetected
    }
    
    func startListening() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]
            
            let url = URL(fileURLWithPath: "/dev/null")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            // Check audio levels periodically
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.checkAudioLevel()
                }
            }
        } catch {
            print("Audio setup failed: \(error)")
        }
    }
    
    func stopListening() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    private func checkAudioLevel() {
        audioRecorder?.updateMeters()
        
        guard let level = audioRecorder?.averagePower(forChannel: 0) else { return }
        
        // Breath detected if level is above threshold
        // -20 dB is a reasonable threshold for breath/blow detection
        let threshold: Float = -20
        
        if level > threshold {
            let now = Date()
            if now.timeIntervalSince(lastBreathTime) >= minimumBreathInterval {
                lastBreathTime = now
                onBreathDetected(true)
            }
        }
    }
}

#Preview {
    Act3BreatheView(gameState: GameState())
}
