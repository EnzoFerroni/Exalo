import SwiftUI

// Thought bubble component for narrative scenes
struct ThoughtBubbleView: View {
    var text: String
    var showQuestionMark: Bool = false
    
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            if showQuestionMark {
                Text("?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1 : 0.5)
            }
            
            if !text.isEmpty {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                isVisible = true
            }
        }
    }
}

// Floating circles for background effect
struct FloatingCirclesBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Large circles
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.2)
                
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 180, height: 180)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
                
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 120, height: 120)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.7)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.98, green: 0.95, blue: 0.8)
            .ignoresSafeArea()
        
        FloatingCirclesBackground()
        
        ThoughtBubbleView(text: "I need to organize everything.", showQuestionMark: true)
    }
}
