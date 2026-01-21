import SwiftUI

struct WorkSceneView: View {
    @Bindable var gameState: GameState
    
    @State private var phase = 0 // 0: intro, 1: interactive, 2: outro
    @State private var textOpacity = 0.0
    @State private var canTap = false
    @State private var isTransitioning = false
    @State private var thoughts: [DraggableThought] = []
    @State private var showHint = true
    @State private var draggedCount = 0
    @State private var characterShake: CGFloat = 0
    
    private let thoughtTexts = ["Failure", "Not enough", "Disappointment", "Imperfect", "Behind", "Worthless"]
    
    var body: some View {
        GeometryReader { geo in
            let layout = AppLayout(geo)
            
            ZStack {
                // Stressed background
                Color(red: 0.95, green: 0.88, blue: 0.78).ignoresSafeArea()
                
                // Draggable thoughts - behind character
                ForEach($thoughts) { $thought in
                    DraggableThoughtView(
                        thought: $thought,
                        layout: layout,
                        onDragEnded: { handleDragEnded(thought: thought, in: geo) }
                    )
                }
                .zIndex(0)
                
                // Character at center-top area - in front of thoughts
                CharacterView(
                    expression: draggedCount > 2 ? .overwhelmed : .worried,
                    size: layout.characterSmall,
                    showWorryLines: draggedCount > 1,
                    showSweatDrop: draggedCount > 2
                )
                .offset(x: characterShake)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.35)
                .zIndex(1)
                
                // Intro/Outro text - at bottom, below character
                if phase != 1 {
                    VStack {
                        Spacer()
                        
                        NarrativeText(
                            main: phase == 0 ? "The thoughts keep growing." : "No matter how hard you try...",
                            sub: phase == 0 ? "Try to push them away." : "They always come back.",
                            layout: layout
                        )
                        .opacity(textOpacity)
                        .padding(.bottom, layout.isIPad ? 30 : 20)
                        
                        TapIndicator(isVisible: canTap && !isTransitioning, layout: layout)
                            .padding(.bottom, layout.isIPad ? 60 : 40)
                    }
                    .zIndex(2)
                    .allowsHitTesting(false)
                }
                
                // Hint for interactive phase - at bottom
                if phase == 1 && showHint {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: layout.isIPad ? 24 : 18))
                            Text("Drag thoughts away from Exalo")
                                .font(.system(size: layout.footnote, design: .rounded))
                        }
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 4)
                        )
                        .padding(.bottom, layout.isIPad ? 80 : 60)
                    }
                    .transition(.opacity)
                    .zIndex(2)
                    .allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { advance(in: geo) }
            .onAppear { startScene(in: geo, layout: layout) }
        }
    }
    
    private func startScene(in geo: GeometryProxy, layout: AppLayout) {
        withAnimation(.easeIn(duration: 0.5)) { textOpacity = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { canTap = true }
    }
    
    private func advance(in geo: GeometryProxy) {
        guard canTap, !isTransitioning else { return }
        
        if phase == 0 {
            // Move to interactive phase
            isTransitioning = true
            Haptics.medium()
            
            withAnimation(.easeOut(duration: 0.3)) { textOpacity = 0 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                phase = 1
                spawnThoughts(in: geo)
                isTransitioning = false
            }
        } else if phase == 2 {
            // Move to next scene
            Haptics.light()
            gameState.navigateTo(.innerThoughts)
        }
    }
    
    private func spawnThoughts(in geo: GeometryProxy) {
        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.35)

        for (i, text) in thoughtTexts.enumerated() {
            let angle = (Double(i) / Double(thoughtTexts.count)) * 2 * .pi
            let radius: CGFloat = geo.size.width < 500 ? 100 : 150

            let offsetX = CGFloat(cos(angle)) * radius
            let offsetY = CGFloat(sin(angle)) * radius

            let thought = DraggableThought(
                text: text,
                position: CGPoint(
                    x: center.x + offsetX,
                    y: center.y + offsetY
                ),
                homePosition: CGPoint(
                    x: center.x + offsetX,
                    y: center.y + offsetY
                )
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    thoughts.append(thought)
                }
                Haptics.light()
            }
        }
    }
    
    private func handleDragEnded(thought: DraggableThought, in geo: GeometryProxy) {
        draggedCount += 1
        showHint = false
        
        guard let index = thoughts.firstIndex(where: { $0.id == thought.id }) else { return }
        
        // First 2 attempts: thought leaves screen (success feeling)
        if draggedCount <= 2 {
            Haptics.success()
            
            // Move thought off screen
            let offScreenX = thought.position.x < geo.size.width / 2 ? -100 : geo.size.width + 100
            withAnimation(.easeOut(duration: 0.3)) {
                thoughts[index].position = CGPoint(x: offScreenX, y: thought.position.y)
            }
            
            // But it comes back after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    thoughts[index].position = thoughts[index].homePosition
                }
                Haptics.warning()
            }
        } else {
            // After 2 attempts: thoughts resist more strongly, return immediately
            Haptics.error()
            
            // Start character shake
            withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
                characterShake = 3
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                thoughts[index].position = thoughts[index].homePosition
            }
        }
        
        // After enough attempts, move to outro
        if draggedCount >= 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    phase = 2
                    textOpacity = 1
                    characterShake = 0
                }
                canTap = true
            }
        }
    }
}

// MARK: - Draggable Thought Model
struct DraggableThought: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var homePosition: CGPoint
}

// MARK: - Draggable Thought View
struct DraggableThoughtView: View {
    @Binding var thought: DraggableThought
    var layout: AppLayout
    var onDragEnded: () -> Void
    
    @State private var isDragging = false
    
    var body: some View {
        Text(thought.text)
            .font(.system(size: layout.isIPad ? 15 : 12, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, layout.isIPad ? 16 : 12)
            .padding(.vertical, layout.isIPad ? 10 : 8)
            .background(
                Capsule()
                    .fill(Color.red.opacity(isDragging ? 0.9 : 0.7))
                    .shadow(color: .red.opacity(0.3), radius: isDragging ? 8 : 4)
            )
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .position(thought.position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        thought.position = value.location
                    }
                    .onEnded { _ in
                        isDragging = false
                        onDragEnded()
                    }
            )
            .animation(.spring(response: 0.3), value: isDragging)
    }
}

#Preview { WorkSceneView(gameState: GameState()) }