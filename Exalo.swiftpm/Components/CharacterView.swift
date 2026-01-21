import SwiftUI

enum CharacterExpression { case normal, happy, worried, sad, questioning, overwhelmed, relieved, exhausted, hopeful }

struct CharacterView: View {
    var expression: CharacterExpression = .normal
    var size: CGFloat = 100
    var showWorryLines = false
    var showSweatDrop = false
    var showRelief = false
    
    @State private var bounce = false
    @State private var breathe = false
    
    private let bodyColor = Color(red: 0.98, green: 0.94, blue: 0.82)
    private let cheekColor = Color(red: 0.95, green: 0.75, blue: 0.75)
    
    var body: some View {
        ZStack {
            if showRelief {
                Circle()
                    .fill(RadialGradient(colors: [.yellow.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: size * 0.6))
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(breathe ? 1.1 : 1.0)
            }
            
            // Body
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(bodyColor)
                .frame(width: size * 0.65, height: size * 0.65)
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(.black, lineWidth: 2))
                .rotationEffect(.degrees(45))
            
            // Cheeks
            HStack(spacing: size * 0.28) {
                Ellipse().fill(cheekColor.opacity(expression == .happy || showRelief ? 0.7 : 0.5)).frame(width: size * 0.12, height: size * 0.08)
                Ellipse().fill(cheekColor.opacity(expression == .happy || showRelief ? 0.7 : 0.5)).frame(width: size * 0.12, height: size * 0.08)
            }.offset(y: size * 0.06)
            
            // Eyes
            HStack(spacing: size * 0.14) {
                EyeView(expression: expression, size: size * 0.09, isLeft: true)
                EyeView(expression: expression, size: size * 0.09, isLeft: false)
            }.offset(y: -size * 0.02)
            
            // Mouth
            MouthView(expression: expression, size: size).offset(y: size * 0.12)
            
            if showSweatDrop { SweatDrop(size: size).offset(x: size * 0.30, y: -size * 0.22) }
            if showWorryLines { WorryLines(size: size) }
        }
        .frame(width: size, height: size)
        .scaleEffect(bounce ? 1.02 : 1.0)
        .onAppear {
            if expression == .happy { withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bounce = true } }
            if showRelief { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { breathe = true } }
        }
    }
}

// MARK: - Mouth
struct MouthView: View {
    var expression: CharacterExpression
    var size: CGFloat
    
    var body: some View {
        switch expression {
        case .normal:
            RoundedRectangle(cornerRadius: 1).fill(.black).frame(width: size * 0.06, height: size * 0.02)
        case .happy, .relieved:
            SmilePath().stroke(.black, lineWidth: 2).frame(width: size * 0.12, height: size * 0.06)
        case .worried, .overwhelmed:
            WavyPath().stroke(.black, lineWidth: 2).frame(width: size * 0.12, height: size * 0.04)
        case .sad, .exhausted:
            SmilePath().stroke(.black, lineWidth: 2).frame(width: size * 0.10, height: size * 0.05).rotationEffect(.degrees(180))
        case .questioning, .hopeful:
            Circle().stroke(.black, lineWidth: 2).frame(width: size * 0.05, height: size * 0.05)
        }
    }
}

struct SmilePath: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addQuadCurve(to: CGPoint(x: r.width, y: 0), control: CGPoint(x: r.width / 2, y: r.height * 1.5))
        return p
    }
}

struct WavyPath: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: r.height / 2))
        p.addQuadCurve(to: CGPoint(x: r.width / 2, y: r.height / 2), control: CGPoint(x: r.width / 4, y: 0))
        p.addQuadCurve(to: CGPoint(x: r.width, y: r.height / 2), control: CGPoint(x: r.width * 3 / 4, y: r.height))
        return p
    }
}

// MARK: - Eye
struct EyeView: View {
    var expression: CharacterExpression
    var size: CGFloat
    var isLeft: Bool
    
    var body: some View {
        switch expression {
        case .normal: Circle().fill(.black).frame(width: size, height: size)
        case .happy: HappyEye().stroke(.black, lineWidth: 2.5).frame(width: size * 1.2, height: size * 0.6)
        case .worried:
            VStack(spacing: 1) {
                Rectangle().fill(.black).frame(width: size * 1.4, height: 2).rotationEffect(.degrees(isLeft ? 18 : -18))
                Circle().fill(.black).frame(width: size, height: size)
            }
        case .sad, .exhausted:
            VStack(spacing: 1) {
                Rectangle().fill(.black).frame(width: size * 1.3, height: 2).rotationEffect(.degrees(isLeft ? -12 : 12))
                Circle().fill(.black).frame(width: size * 0.9, height: size * 0.9)
            }
        case .questioning: Circle().fill(.black).frame(width: isLeft ? size : size * 1.2, height: isLeft ? size : size * 1.2)
        case .overwhelmed: SpiralEye().stroke(.black, lineWidth: 1.5).frame(width: size * 1.1, height: size * 1.1)
        case .relieved: RelievedEye().stroke(.black, lineWidth: 2.5).frame(width: size * 1.2, height: size * 0.5)
        case .hopeful:
            ZStack {
                Circle().fill(.black).frame(width: size, height: size)
                Circle().fill(.white.opacity(0.6)).frame(width: size * 0.3, height: size * 0.3).offset(x: isLeft ? -1 : 1, y: -size * 0.2)
            }
        }
    }
}

struct HappyEye: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); p.move(to: CGPoint(x: 0, y: r.height))
        p.addQuadCurve(to: CGPoint(x: r.width, y: r.height), control: CGPoint(x: r.width / 2, y: 0)); return p
    }
}

struct SpiralEye: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); let c = CGPoint(x: r.midX, y: r.midY); var rad: CGFloat = 2; var ang: CGFloat = 0
        p.move(to: CGPoint(x: c.x + rad, y: c.y))
        for _ in 0..<15 { ang += .pi / 3; rad += 0.7; p.addLine(to: CGPoint(x: c.x + rad * cos(ang), y: c.y + rad * sin(ang))) }
        return p
    }
}

struct RelievedEye: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); p.move(to: CGPoint(x: 0, y: r.height * 0.3))
        p.addQuadCurve(to: CGPoint(x: r.width, y: r.height * 0.3), control: CGPoint(x: r.width / 2, y: r.height)); return p
    }
}

// MARK: - Sweat & Worry
struct SweatDrop: View {
    var size: CGFloat
    @State private var animate = false
    
    var body: some View {
        DropShape()
            .fill(LinearGradient(colors: [.blue.opacity(0.25), .blue.opacity(0.45)], startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.07, height: size * 0.11)
            .offset(y: animate ? 3 : 0)
            .onAppear { withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { animate = true } }
    }
}

struct DropShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); p.move(to: CGPoint(x: r.midX, y: 0))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.height), control: CGPoint(x: r.width + 3, y: r.height * 0.6))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: 0), control: CGPoint(x: -3, y: r.height * 0.6)); return p
    }
}

struct WorryLines: View {
    var size: CGFloat
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: size * 0.55) {
            VStack(spacing: 3) { ForEach(0..<3, id: \.self) { i in Rectangle().fill(.black.opacity(0.5)).frame(width: 5, height: 1.5).offset(x: CGFloat(i - 1) * 2) } }.opacity(animate ? 1 : 0.3)
            Spacer()
            VStack(spacing: 3) { ForEach(0..<3, id: \.self) { i in Rectangle().fill(.black.opacity(0.5)).frame(width: 5, height: 1.5).offset(x: CGFloat(1 - i) * 2) } }.opacity(animate ? 1 : 0.3)
        }
        .frame(width: size * 0.85).offset(y: -size * 0.02)
        .onAppear { withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { animate = true } }
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
            CharacterView(expression: .hopeful, size: 80)
        }
    }
}