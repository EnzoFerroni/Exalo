import SwiftUI

// Exalo character - cute rounded square with expressive face
struct CharacterView: View {
    var expression: CharacterExpression = .normal
    var size: CGFloat = 100
    var showWorryLines: Bool = false
    var showSweatDrop: Bool = false
    var showRelief: Bool = false
    
    @State private var bounceAnimation: Bool = false
    @State private var breatheAnimation: Bool = false
    
    private let bodyColor = Color(red: 0.98, green: 0.94, blue: 0.82)
    private let cheekColor = Color(red: 0.95, green: 0.75, blue: 0.75)
    
    var body: some View {
        ZStack {
            if showRelief {
                Circle()
                    .fill(RadialGradient(colors: [Color.yellow.opacity(0.3), Color.clear], center: .center, startRadius: 0, endRadius: size * 0.6))
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(breatheAnimation ? 1.1 : 1.0)
            }
            
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(bodyColor)
                .frame(width: size * 0.65, height: size * 0.65)
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(Color.black, lineWidth: 2))
                .rotationEffect(.degrees(45))
            
            // Cheeks
            HStack(spacing: size * 0.28) {
                Ellipse().fill(cheekColor.opacity(expression == .happy || showRelief ? 0.7 : 0.6)).frame(width: size * 0.12, height: size * 0.08)
                Ellipse().fill(cheekColor.opacity(expression == .happy || showRelief ? 0.7 : 0.6)).frame(width: size * 0.12, height: size * 0.08)
            }
            .offset(y: size * 0.06)
            
            // Eyes
            HStack(spacing: size * 0.14) {
                EyeView(expression: expression, size: size * 0.09, isLeftEye: true)
                EyeView(expression: expression, size: size * 0.09, isLeftEye: false)
            }
            .offset(y: -size * 0.02)
            
            // Mouth
            MouthView(expression: expression, size: size)
                .offset(y: size * 0.12)
            
            if showSweatDrop {
                SweatDropView(size: size).offset(x: size * 0.30, y: -size * 0.22)
            }
            
            if showWorryLines {
                WorryLinesView(size: size)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(bounceAnimation ? 1.02 : 1.0)
        .onAppear {
            if expression == .happy {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bounceAnimation = true }
            }
            if showRelief {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { breatheAnimation = true }
            }
        }
    }
}

// MARK: - Mouth View
struct MouthView: View {
    var expression: CharacterExpression
    var size: CGFloat
    
    var body: some View {
        Group {
            switch expression {
            case .normal:
                // Small neutral line
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.black)
                    .frame(width: size * 0.06, height: size * 0.02)
            case .happy, .relieved:
                // Happy smile
                HappyMouthShape()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: size * 0.12, height: size * 0.06)
            case .worried:
                // Wavy worried mouth
                WavyMouthShape()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: size * 0.10, height: size * 0.04)
            case .sad, .exhausted:
                // Sad frown
                SadMouthShape()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: size * 0.10, height: size * 0.05)
            case .questioning, .hopeful:
                // Small "o" mouth
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: size * 0.05, height: size * 0.05)
            case .overwhelmed:
                // Stressed wavy mouth
                WavyMouthShape()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: size * 0.14, height: size * 0.05)
            }
        }
    }
}

struct HappyMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 0), control: CGPoint(x: rect.width / 2, y: rect.height * 1.5))
        return path
    }
}

struct WavyMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addQuadCurve(to: CGPoint(x: rect.width / 2, y: rect.height / 2), control: CGPoint(x: rect.width / 4, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height / 2), control: CGPoint(x: rect.width * 3 / 4, y: rect.height))
        return path
    }
}

struct SadMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 0), control: CGPoint(x: rect.width / 2, y: rect.height * 1.5))
        return path
    }
}

// MARK: - Eye View
struct EyeView: View {
    var expression: CharacterExpression
    var size: CGFloat
    var isLeftEye: Bool
    
    var body: some View {
        ZStack {
            switch expression {
            case .normal:
                Circle().fill(Color.black).frame(width: size, height: size)
            case .happy:
                HappyEyeShape().stroke(Color.black, lineWidth: 2.5).frame(width: size * 1.2, height: size * 0.6)
            case .worried:
                VStack(spacing: 1) {
                    Rectangle().fill(Color.black).frame(width: size * 1.4, height: 2).rotationEffect(.degrees(isLeftEye ? 18 : -18))
                    Circle().fill(Color.black).frame(width: size, height: size)
                }
            case .sad:
                VStack(spacing: 1) {
                    Rectangle().fill(Color.black).frame(width: size * 1.3, height: 2).rotationEffect(.degrees(isLeftEye ? -12 : 12))
                    Circle().fill(Color.black).frame(width: size * 0.9, height: size * 0.9)
                }
            case .questioning:
                Circle().fill(Color.black).frame(width: isLeftEye ? size : size * 1.2, height: isLeftEye ? size : size * 1.2)
            case .overwhelmed:
                SpiralEyeShape().stroke(Color.black, lineWidth: 1.5).frame(width: size * 1.1, height: size * 1.1)
            case .relieved:
                RelievedEyeShape().stroke(Color.black, lineWidth: 2.5).frame(width: size * 1.2, height: size * 0.5)
            case .exhausted:
                VStack(spacing: 0) {
                    Rectangle().fill(Color.black).frame(width: size * 1.2, height: 2)
                    Circle().fill(Color.black).frame(width: size * 0.8, height: size * 0.8)
                }
            case .hopeful:
                ZStack {
                    Circle().fill(Color.black).frame(width: size, height: size)
                    Circle().fill(Color.white.opacity(0.6)).frame(width: size * 0.3, height: size * 0.3).offset(x: isLeftEye ? -1 : 1, y: -size * 0.2)
                }
            }
        }
    }
}

struct HappyEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height), control: CGPoint(x: rect.width / 2, y: 0))
        return path
    }
}

struct SpiralEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var radius: CGFloat = 2
        var angle: CGFloat = 0
        path.move(to: CGPoint(x: center.x + radius, y: center.y))
        for _ in 0..<15 {
            angle += .pi / 3
            radius += 0.7
            path.addLine(to: CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle)))
        }
        return path
    }
}

struct RelievedEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.3))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height * 0.3), control: CGPoint(x: rect.width / 2, y: rect.height))
        return path
    }
}

// MARK: - Sweat Drop
struct SweatDropView: View {
    var size: CGFloat
    @State private var animate: Bool = false
    
    var body: some View {
        SweatDropShape()
            .fill(LinearGradient(colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.45)], startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.07, height: size * 0.11)
            .offset(y: animate ? 3 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { animate = true }
            }
    }
}

struct SweatDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.height), control: CGPoint(x: rect.width + 3, y: rect.height * 0.6))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: 0), control: CGPoint(x: -3, y: rect.height * 0.6))
        return path
    }
}

// MARK: - Worry Lines
struct WorryLinesView: View {
    var size: CGFloat
    @State private var isAnimating: Bool = false
    
    var body: some View {
        HStack(spacing: size * 0.55) {
            VStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Rectangle().fill(Color.black.opacity(0.5)).frame(width: 5, height: 1.5).offset(x: CGFloat(i - 1) * 2)
                }
            }.opacity(isAnimating ? 1 : 0.3)
            Spacer()
            VStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Rectangle().fill(Color.black.opacity(0.5)).frame(width: 5, height: 1.5).offset(x: CGFloat(1 - i) * 2)
                }
            }.opacity(isAnimating ? 1 : 0.3)
        }
        .frame(width: size * 0.85)
        .offset(y: -size * 0.02)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { isAnimating = true }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 30) {
            CharacterView(expression: .normal, size: 80)
            CharacterView(expression: .happy, size: 80)
            CharacterView(expression: .worried, size: 80, showWorryLines: true, showSweatDrop: true)
        }
        HStack(spacing: 30) {
            CharacterView(expression: .overwhelmed, size: 80)
            CharacterView(expression: .relieved, size: 80, showRelief: true)
            CharacterView(expression: .sad, size: 80)
        }
    }
    .padding()
}