import SwiftUI

// Home screen with title, character and navigation buttons
struct HomeView: View {
    @Bindable var gameState: GameState
    
    @State private var titleAppeared: Bool = false
    @State private var characterAppeared: Bool = false
    @State private var buttonsAppeared: Bool = false
    
    private let backgroundColor = Color(red: 0.98, green: 0.95, blue: 0.8)
    private let accentYellow = Color(red: 1.0, green: 0.9, blue: 0.2)
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()
            
            FloatingCirclesBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title pill
                Text("EXALO")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(accentYellow)
                    )
                    .opacity(titleAppeared ? 1 : 0)
                    .offset(y: titleAppeared ? 0 : -20)
                
                Spacer()
                
                // Character
                CharacterView(expression: .normal, size: 120)
                    .opacity(characterAppeared ? 1 : 0)
                    .scaleEffect(characterAppeared ? 1 : 0.8)
                
                Spacer()
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 16) {
                    Button(action: {
                        gameState.navigateTo(.prologue)
                    }) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.85))
                            )
                    }
                    
                    Button(action: {
                        gameState.navigateTo(.about)
                    }) {
                        Text("About")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.85))
                            )
                    }
                }
                .opacity(buttonsAppeared ? 1 : 0)
                .offset(y: buttonsAppeared ? 0 : 30)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            animateEntrance()
        }
    }
    
    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.6)) {
            titleAppeared = true
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            characterAppeared = true
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            buttonsAppeared = true
        }
    }
}

#Preview {
    HomeView(gameState: GameState())
}
