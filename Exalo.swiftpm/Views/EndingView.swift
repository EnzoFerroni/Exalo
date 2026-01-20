import SwiftUI

// Ending screen - calm conclusion with message
struct EndingView: View {
    @Bindable var gameState: GameState
    
    @State private var showCharacter: Bool = false
    @State private var showMessage: Bool = false
    @State private var showButton: Bool = false
    @State private var backgroundOpacity: Double = 0
    
    private let calmBackground = Color(red: 0.85, green: 0.92, blue: 0.95)
    
    var body: some View {
        ZStack {
            // Calm gradient background
            LinearGradient(
                colors: [
                    calmBackground,
                    Color(red: 0.9, green: 0.95, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)
            
            // Soft floating circles
            FloatingCirclesEndingView()
                .opacity(backgroundOpacity)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Character feeling relieved
                if showCharacter {
                    CharacterView(
                        expression: .relieved,
                        size: 120,
                        showRelief: true
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Final message
                if showMessage {
                    VStack(spacing: 16) {
                        Text("\"Sometimes, we just need to stop\nand breathe.\"")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("Remember: it's okay to slow down.")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.top, 8)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                
                // Done button
                if showButton {
                    Button(action: {
                        gameState.resetGame()
                        gameState.navigateTo(.home)
                    }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.7))
                            )
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 60)
                }
            }
            .padding()
        }
        .onAppear {
            startEndingSequence()
        }
    }
    
    private func startEndingSequence() {
        // Fade in background
        withAnimation(.easeIn(duration: 1.0)) {
            backgroundOpacity = 1
        }
        
        // Show character
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showCharacter = true
            }
        }
        
        // Show message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn(duration: 0.6)) {
                showMessage = true
            }
        }
        
        // Show button
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 0.4)) {
                showButton = true
            }
        }
    }
}

// Soft floating circles for ending
struct FloatingCirclesEndingView: View {
    @State private var animate: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 150, height: 150)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                    .offset(y: animate ? -10 : 10)
                
                Circle()
                    .fill(Color(red: 0.8, green: 0.9, blue: 0.95).opacity(0.6))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.25)
                    .offset(y: animate ? 10 : -10)
                
                Circle()
                    .fill(Color(red: 0.9, green: 0.85, blue: 0.9).opacity(0.4))
                    .frame(width: 80, height: 80)
                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.7)
                    .offset(y: animate ? -8 : 8)
                
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 120, height: 120)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.75)
                    .offset(y: animate ? 12 : -12)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    EndingView(gameState: GameState())
}
