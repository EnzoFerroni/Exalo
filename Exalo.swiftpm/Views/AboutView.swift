import SwiftUI

struct AboutView: View {
    @Bindable var gameState: GameState
    
    private let backgroundColor = Color(red: 0.98, green: 0.95, blue: 0.8)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("About the Creator")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                            .frame(width: 100, height: 100)
                        
                        CharacterView(expression: .happy, size: 60)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Enzo Ferroni")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("20 years old • Developer")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Text("Apple Developer Academy | Mackenzie")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.black))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Exalo")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Exalo is a story-driven experience about dealing with the weight of anxiety and self-pressure. It shows how the constant need to be perfect can overwhelm us, and how sometimes we just need to stop and breathe.")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                        
                        Text("The goal is to make invisible feelings tangible, using your breath to find relief.")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 40)
                    
                    Button(action: {
                        Haptics.light()
                        gameState.navigateTo(.home)
                    }) {
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 150)
                            .padding(.vertical, 14)
                            .background(Capsule().stroke(Color.black, lineWidth: 2))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct TechBadge: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.black.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().stroke(Color.black.opacity(0.3), lineWidth: 1))
    }
}

#Preview { AboutView(gameState: GameState()) }