import SwiftUI

struct HomeView: View {
    @Bindable var gameState: GameState
    
    @State private var showTitle = false
    @State private var showCharacter = false
    @State private var showButtons = false
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.background.ignoresSafeArea()
                FloatingCirclesBackground()
                
                VStack(spacing: layout.spacing) {
                    Spacer()
                    
                    // Title pill - bright yellow background
                    Text("EXALO")
                        .font(.system(size: layout.title3, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, layout.isIPad ? 40 : 30)
                        .padding(.vertical, layout.isIPad ? 14 : 10)
                        .background(Capsule().fill(AppColors.accent))
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : -20)
                    
                    Spacer()
                    
                    CharacterView(expression: .happy, size: layout.characterSize)
                        .opacity(showCharacter ? 1 : 0)
                        .scaleEffect(showCharacter ? 1 : 0.8)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: layout.isIPad ? 20 : 16) {
                        Button(action: {
                            Haptics.light()
                            gameState.navigateTo(.prologue)
                        }) {
                            Text("Start")
                                .font(.system(size: layout.body, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: layout.buttonWidth, height: layout.buttonHeight)
                                .background(Capsule().fill(Color.black.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            Haptics.light()
                            gameState.navigateTo(.about)
                        }) {
                            Text("About")
                                .font(.system(size: layout.body, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: layout.buttonWidth, height: layout.buttonHeight)
                                .background(Capsule().fill(Color.black.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                    }
                    .opacity(showButtons ? 1 : 0)
                    .offset(y: showButtons ? 0 : 30)
                    
                    Spacer().frame(height: layout.isIPad ? 80 : 60)
                }
            }
        }
        .onAppear { animate() }
    }
    
    private func animate() {
        withAnimation(.easeOut(duration: 0.5)) { showTitle = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.15)) { showCharacter = true }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) { showButtons = true }
    }
}

#Preview { HomeView(gameState: GameState()) }
