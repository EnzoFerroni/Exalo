// Testar vibracao ao arrastar um objeto pesado

import SwiftUI

struct HapticDragView: View {
    
    @State private var position = CGPoint(x: 200, y: 400)
    @State private var weight: Double = 0.7
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack {
                Text("Arraste o Bloco Pesado")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.top, 60)
                
                Spacer()
                
                HStack {
                    Text("Peso:")
                    Slider(value: $weight, in: 0.1...1.0)
                    Text("\(Int(weight * 100))kg")
                }
                .foregroundColor(.white)
                .padding()
            }
            
            // Bloco pesado
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray)
                .frame(width: 100, height: 100)
                .shadow(radius: isDragging ? 20 : 10)
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .overlay(
                    Text("\(Int(weight * 100))kg")
                        .foregroundColor(.white)
                        .font(.headline)
                )
                .position(position)
                .animation(.spring(), value: isDragging)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isDragging {
                                isDragging = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            
                            // Peso cria resistencia
                            let resistance = weight * 0.5
                            let moveX = value.velocity.width * 0.01 * (1 - resistance)
                            let moveY = value.velocity.height * 0.01 * (1 - resistance)
                            
                            position.x += moveX
                            position.y += moveY
                            
                            // Vibracao baseada na velocidade
                            let speed = abs(moveX) + abs(moveY)
                            if speed > 3 {
                                let intensity = min(speed / 30, 1.0)
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: intensity)
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                )
        }
    }
}

#Preview {
    HapticDragView()
}
