import SwiftUI

// Light Appears - A moment of hope before breathing exercise
struct LightAppearsView: View {
    @Bindable var gameState: GameState
    
    @State private var lightOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var showCharacter: Bool = false
    @State private var characterExpression: CharacterExpression = .sad
    @State private var canTap: Bool = false
    
    private let darkColor = Color(red: 0.08, green: 0.09, blue: 0.14)
    private let lightBlue = Color(red: 0.6, green: 0.75, blue: 0.95)
    
    var body: some View {
        ZStack {
            // Dark background
            darkColor
                .ignoresSafeArea()
            
            // Light from above
            VStack {
                RadialGradient(
                    colors: [lightBlue.opacity(lightOpacity * 0.4), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 400
                )
                .frame(height: 500)
                
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Character looking up at light
                if showCharacter {
                    CharacterView(
                        expression: characterExpression,
                        size: 90
                    )
                    .transition(.opacity)
                }
                
                // Hopeful text
                VStack(spacing: 12) {
                    Text("\"What if...\"")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\"What if I just stopped for a moment?\"")
                        .font(.system(size: 18))
                        .foregroundColor(lightBlue.opacity(0.9))
                }
                .opacity(textOpacity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Tap indicator - always present, just change opacity
                Text("tap to continue")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
                    .opacity(canTap ? 1 : 0)
                    .frame(height: 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startLightSequence()
        }
        .onTapGesture {
            if canTap {
                gameState.navigateTo(.act3Breathe)
            }
        }
    }
    
    private func startLightSequence() {
        // Light fades in
        withAnimation(.easeIn(duration: 2.0)) {
            lightOpacity = 1
        }
        
        // Character appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                showCharacter = true
            }
        }
        
        // Text fades in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeIn(duration: 0.6)) {
                textOpacity = 1
            }
        }
        
        // Character expression changes to hopeful
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                characterExpression = .hopeful
            }
        }
        
        // Allow tap
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            canTap = true
        }
    }
}

#Preview {
    LightAppearsView(gameState: GameState())
}
