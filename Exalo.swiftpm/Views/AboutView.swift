import SwiftUI

struct AboutView: View {
    @Bindable var gameState: GameState
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                AppColors.background.ignoresSafeArea()
                FloatingCirclesBackground()
                
                ScrollView {
                    VStack(spacing: layout.isIPad ? 28 : 22) {
                        Text("About the Creator")
                            .font(.system(size: layout.title2, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, layout.isIPad ? 50 : 40)
                        
                        ZStack {
                            Circle()
                                .stroke(AppColors.textPrimary, lineWidth: 2)
                                .frame(width: layout.isIPad ? 120 : 100, height: layout.isIPad ? 120 : 100)
                            
                            CharacterView(expression: .happy, size: layout.isIPad ? 70 : 60)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Enzo Ferroni")
                                .font(.system(size: layout.headline, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("20 years old • Developer")
                                .font(.system(size: layout.footnote, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text("Apple Developer Academy | Mackenzie")
                            .font(.system(size: layout.caption, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.black))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Exalo")
                                .font(.system(size: layout.body, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Exalo is a story-driven experience about dealing with the weight of anxiety and self-pressure. It shows how the constant need to be perfect can overwhelm us, and how sometimes we just need to stop and breathe.")
                                .font(.system(size: layout.footnote, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                            
                            Text("The goal is to make invisible feelings tangible, using your breath to find relief.")
                                .font(.system(size: layout.footnote, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: layout.maxContentWidth)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.7))
                        )
                        .padding(.horizontal, layout.padding)
                        
                        Spacer(minLength: 30)
                        
                        Button(action: {
                            Haptics.light()
                            gameState.navigateTo(.home)
                        }) {
                            Text("Back")
                                .font(.system(size: layout.body, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: layout.buttonWidth, height: layout.buttonHeight)
                                .background(Capsule().fill(Color.black.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, layout.isIPad ? 60 : 40)
                    }
                }
            }
        }
    }
}

#Preview { AboutView(gameState: GameState()) }