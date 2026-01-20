import SwiftUI

// Morning Scene - Tasks start appearing, stress begins to build
struct MorningSceneView: View {
    @Bindable var gameState: GameState
    
    @State private var currentPhase: Int = 0
    @State private var tasks: [TaskItem] = []
    @State private var showCharacter: Bool = false
    @State private var characterExpression: CharacterExpression = .normal
    @State private var canTap: Bool = false
    @State private var textOpacity: Double = 0
    
    private let backgroundColor = Color(red: 0.98, green: 0.95, blue: 0.8)
    
    private let phases: [(thought: String, addTasks: Int)] = [
        ("A new day begins.", 0),
        ("\"I need to check my list...\"", 2),
        ("\"Just a few things to do.\"", 2),
        ("\"I can handle this.\"", 3),
        ("\"Maybe just a few more...\"", 4)
    ]
    
    private let taskTexts = [
        "Be productive", "Don't disappoint anyone", "Finish everything",
        "Be perfect", "Don't make mistakes", "Make everyone happy",
        "Work harder", "Do better", "Be enough", "Don't fail",
        "Meet expectations", "Prove yourself"
    ]
    
    var body: some View {
        ZStack {
            // Background that slightly changes with stress
            backgroundGradient
                .ignoresSafeArea()
            
            // Floating tasks
            ForEach(tasks) { task in
                TaskBubbleView(text: task.text, opacity: task.opacity)
                    .position(task.position)
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Character
                if showCharacter {
                    CharacterView(
                        expression: characterExpression,
                        size: 90,
                        showWorryLines: tasks.count > 6
                    )
                    .transition(.scale)
                }
                
                // Thought text
                Text(phases[currentPhase].thought)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Tap indicator - always present, just change opacity
                Text("tap to continue")
                    .font(.system(size: 12))
                    .foregroundColor(.black.opacity(0.3))
                    .opacity(canTap ? 1 : 0)
                    .frame(height: 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startScene()
        }
        .onTapGesture {
            advancePhase()
        }
    }
    
    private var backgroundGradient: some View {
        let stressAmount = Double(tasks.count) / 12.0
        return LinearGradient(
            colors: [
                backgroundColor,
                Color(red: 0.98 - stressAmount * 0.05, green: 0.95 - stressAmount * 0.08, blue: 0.8 - stressAmount * 0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func startScene() {
        withAnimation(.easeIn(duration: 0.5)) {
            showCharacter = true
            textOpacity = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            canTap = true
        }
    }
    
    private func advancePhase() {
        guard canTap else { return }
        canTap = false
        
        if currentPhase < phases.count - 1 {
            currentPhase += 1
            
            // Add tasks
            let tasksToAdd = phases[currentPhase].addTasks
            addTasks(count: tasksToAdd)
            
            // Update character expression based on task count
            updateCharacterExpression()
            
            // Animate text
            withAnimation(.easeOut(duration: 0.2)) {
                textOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    textOpacity = 1
                }
                canTap = true
            }
            
            gameState.increaseStress(by: 0.1)
        } else {
            gameState.navigateTo(.workScene)
        }
    }
    
    private func addTasks(count: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for i in 0..<count {
            let usedTexts = tasks.map { $0.text }
            let availableTexts = taskTexts.filter { !usedTexts.contains($0) }
            guard let text = availableTexts.randomElement() else { continue }
            
            let task = TaskItem(
                text: text,
                position: CGPoint(
                    x: CGFloat.random(in: 40...(screenWidth - 40)),
                    y: CGFloat.random(in: 100...(screenHeight - 250))
                ),
                opacity: 0
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    tasks.append(task)
                }
                
                // Fade in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            tasks[index].opacity = Double.random(in: 0.4...0.8)
                        }
                    }
                }
            }
        }
    }
    
    private func updateCharacterExpression() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if tasks.count > 8 {
                characterExpression = .worried
            } else if tasks.count > 4 {
                characterExpression = .questioning
            } else {
                characterExpression = .normal
            }
        }
    }
}

// Task item model
struct TaskItem: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var opacity: Double
}

// Task bubble view
struct TaskBubbleView: View {
    var text: String
    var opacity: Double
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
            .opacity(opacity)
    }
}

#Preview {
    MorningSceneView(gameState: GameState())
}
