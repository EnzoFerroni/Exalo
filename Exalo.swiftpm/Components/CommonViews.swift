import SwiftUI

// MARK: - Layout Helper (HIG-compliant)
struct AppLayout {
    let isIPad: Bool
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    init(_ geo: GeometryProxy) {
        screenWidth = geo.size.width
        screenHeight = geo.size.height
        isIPad = min(screenWidth, screenHeight) > 600
    }
    
    // Character sizes
    var characterSize: CGFloat { isIPad ? 180 : 120 }
    var characterSmall: CGFloat { isIPad ? 150 : 100 }
    
    // Typography (HIG Dynamic Type)
    var largeTitle: CGFloat { isIPad ? 40 : 34 }
    var title1: CGFloat { isIPad ? 34 : 28 }
    var title2: CGFloat { isIPad ? 28 : 22 }
    var title3: CGFloat { isIPad ? 24 : 20 }
    var headline: CGFloat { isIPad ? 21 : 17 }
    var body: CGFloat { isIPad ? 21 : 17 }
    var subhead: CGFloat { isIPad ? 19 : 15 }
    var footnote: CGFloat { isIPad ? 17 : 13 }
    
    // Button sizes (min 44pt per HIG)
    var buttonWidth: CGFloat { isIPad ? 320 : 220 }
    var buttonHeight: CGFloat { isIPad ? 56 : 50 }
    
    // Spacing
    var padding: CGFloat { isIPad ? 60 : 24 }
    var spacing: CGFloat { isIPad ? 48 : 32 }
    var maxContentWidth: CGFloat { isIPad ? 600 : screenWidth - 48 }
    
    // Fixed positions
    var characterY: CGFloat { screenHeight * 0.42 }
    var textY: CGFloat { screenHeight * 0.62 }
    var bottomY: CGFloat { screenHeight - (isIPad ? 120 : 90) }
}

// MARK: - Colors
struct AppColors {
    // Backgrounds
    static let background = Color(red: 0.98, green: 0.95, blue: 0.9)
    static let dark = Color(red: 0.08, green: 0.09, blue: 0.14)
    static let calm = Color(red: 0.85, green: 0.92, blue: 0.95)
    static let lightBlue = Color(red: 0.6, green: 0.75, blue: 0.95)
    
    // Accent - bright yellow for backgrounds/pills
    static let accent = Color(red: 1.0, green: 0.85, blue: 0.3)
    // Accent text - darker gold for readable text on light backgrounds
    static let accentText = Color(red: 0.55, green: 0.35, blue: 0.0)
    
    // Text on light backgrounds
    static let textPrimary = Color.black
    static let textSecondary = Color.black.opacity(0.65)
    static let textTertiary = Color.black.opacity(0.4)
    
    // Text on dark backgrounds
    static let textOnDark = Color.white
    static let textOnDarkSecondary = Color.white.opacity(0.7)
}

// MARK: - Tap Indicator (larger for iPad)
struct TapIndicator: View {
    let isVisible: Bool
    var color: Color = .black
    var layout: AppLayout? = nil
    
    @State private var pulse = false
    
    var body: some View {
        let fontSize: CGFloat = layout?.isIPad == true ? 20 : 16
        
        VStack(spacing: 10) {
            Text("tap to continue")
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundColor(color.opacity(0.6))
            Circle()
                .fill(color.opacity(0.4))
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 1.4 : 1)
        }
        .frame(height: 60)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

// MARK: - Floating Background
struct FloatingCirclesBackground: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            let isIPad = min(geo.size.width, geo.size.height) > 600
            ZStack {
                Circle().fill(Color.blue.opacity(0.15))
                    .frame(width: isIPad ? 160 : 120)
                    .position(x: geo.size.width * 0.15, y: geo.size.height * 0.2)
                    .offset(y: animate ? -15 : 15)
                
                Circle().fill(Color.pink.opacity(0.12))
                    .frame(width: isIPad ? 120 : 90)
                    .position(x: geo.size.width * 0.85, y: geo.size.height * 0.35)
                    .offset(y: animate ? 12 : -12)
                
                Circle().fill(Color.yellow.opacity(0.2))
                    .frame(width: isIPad ? 100 : 70)
                    .position(x: geo.size.width * 0.25, y: geo.size.height * 0.75)
                    .offset(y: animate ? -10 : 10)
                
                Circle().fill(Color.green.opacity(0.1))
                    .frame(width: isIPad ? 140 : 100)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.8)
                    .offset(y: animate ? 8 : -8)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { animate = true }
        }
    }
}

// MARK: - Narrative Text Component (consistent styling)
struct NarrativeText: View {
    let main: String
    var sub: String = ""
    var layout: AppLayout
    var textColor: Color = AppColors.textPrimary
    var subColor: Color = AppColors.textSecondary
    
    var body: some View {
        VStack(spacing: layout.isIPad ? 16 : 12) {
            Text(main)
                .font(.system(size: layout.title2, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
            
            if !sub.isEmpty {
                Text(sub)
                    .font(.system(size: layout.body, design: .rounded))
                    .foregroundColor(subColor)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: layout.maxContentWidth)
        .padding(.horizontal, layout.padding)
    }
}
