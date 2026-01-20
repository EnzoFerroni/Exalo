import SwiftUI

// Work Scene - Pressure intensifies, tasks multiply faster
struct WorkSceneView: View {
    @Bindable var gameState: GameState
    
    @State private var currentPhase: Int = 0
    @State private var tasks: [WorkTask] = []
    @State private var completedCount: Int = 0
    @State private var showCharacter: Bool = true
    @State private var characterExpression: CharacterExpression = .worried
    @State private var characterScale: CGFloat = 1.0
    @State private var showInstruction: Bool = false
    @State private var textOpacity: Double = 1
    @State private var spawnTimer: Timer?
    
    private let stressedBackground = Color(red: 0.95, green: 0.90, blue: 0.78)
    
    private let thoughts: [String] = [
        "\"I can do this. I have to.\"",
        "\"Almost there... just a little more.\"",
        "\"Why does it never end?\"",
        "\"I'm trying so hard...\"",
        "\"It's never enough, is it?\""
    ]
    
    var body: some View {
        ZStack {
            // Stressed background
            stressedBackground
                .ignoresSafeArea()
            
            // Floating work tasks to tap
            ForEach(tasks) { task in
                WorkTaskView(task: task) {
                    completeTask(task)
                }
            }
            
            VStack {
                // Phase text at top
                Text(thoughts[min(currentPhase, thoughts.count - 1)])
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .padding(.top, 60)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Character in center, shrinking under pressure
                CharacterView(
                    expression: characterExpression,
                    size: 80,
                    showWorryLines: true,
                    showSweatDrop: currentPhase >= 2
                )
                .scaleEffect(characterScale)
                
                Spacer()
                
                // Instruction
                if showInstruction {
                    VStack(spacing: 8) {
                        Text("Tap the tasks to complete them")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.5))
                        
                        Text("Completed: \(completedCount)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startWorkScene()
        }
        .onDisappear {
            spawnTimer?.invalidate()
        }
    }
    
    private func startWorkScene() {
        showInstruction = true
        
        // Start spawning tasks
        spawnInitialTasks()
        
        // Tasks spawn faster over time
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            spawnTask()
            checkPhaseProgress()
        }
        
        // Auto-advance after enough time
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            transitionToNext()
        }
    }
    
    private func spawnInitialTasks() {
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                spawnTask()
            }
        }
    }
    
    private func spawnTask() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let task = WorkTask(
            position: CGPoint(
                x: CGFloat.random(in: 60...(screenWidth - 60)),
                y: CGFloat.random(in: 120...(screenHeight - 180))
            ),
            color: [Color.blue.opacity(0.6), Color.pink.opacity(0.6), Color.orange.opacity(0.5)].randomElement()!
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            tasks.append(task)
        }
        
        // Increase pressure feeling
        if tasks.count > 6 {
            withAnimation(.easeIn(duration: 0.3)) {
                characterScale = max(0.7, characterScale - 0.03)
                characterExpression = tasks.count > 10 ? .overwhelmed : .worried
            }
        }
        
        gameState.increaseStress(by: 0.05)
    }
    
    private func completeTask(_ task: WorkTask) {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            tasks.removeAll { $0.id == task.id }
        }
        
        completedCount += 1
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Spawn more tasks faster as you complete them (endless cycle feeling)
        if completedCount % 2 == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                spawnTask()
                spawnTask()
            }
        }
    }
    
    private func checkPhaseProgress() {
        let newPhase = min(completedCount / 3, thoughts.count - 1)
        if newPhase != currentPhase {
            withAnimation(.easeOut(duration: 0.2)) {
                textOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentPhase = newPhase
                withAnimation(.easeIn(duration: 0.3)) {
                    textOpacity = 1
                }
            }
        }
    }
    
    private func transitionToNext() {
        spawnTimer?.invalidate()
        gameState.navigateTo(.innerThoughts)
    }
}

// Work task model
struct WorkTask: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
}

// Tappable work task view
struct WorkTaskView: View {
    var task: WorkTask
    var onTap: () -> Void
    
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(task.color)
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(task.position)
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.15)) {
                    scale = 1.3
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onTap()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1
                    opacity = 1
                }
            }
    }
}

#Preview {
    WorkSceneView(gameState: GameState())
}
