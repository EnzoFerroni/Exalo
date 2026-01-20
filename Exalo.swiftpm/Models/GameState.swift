import SwiftUI

// Game screens enumeration - expanded narrative flow
enum GameScreen {
    case home
    case prologue           // Introduction to the character
    case morningScene       // Morning routine - tasks appearing
    case workScene          // Work pressure building
    case innerThoughts      // Internal struggle with puzzle
    case breakingPoint      // The moment before overwhelm
    case act2Overwhelmed    // Darkness takes over
    case lightAppears       // A glimmer of hope
    case act3Breathe        // Breathing exercise
    case ending             // Resolution and message
    case about
}

// Character expression types
enum CharacterExpression {
    case normal
    case worried
    case happy
    case questioning
    case sad
    case overwhelmed
    case relieved
    case exhausted
    case hopeful
}

// Observable game state
@Observable
class GameState {
    var currentScreen: GameScreen = .home
    var stressLevel: Float = 0.0  // 0.0 to 1.0
    var tasksCompleted: Int = 0
    var breathingProgress: Float = 0.0
    
    func navigateTo(_ screen: GameScreen) {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreen = screen
        }
    }
    
    func increaseStress(by amount: Float = 0.1) {
        stressLevel = min(1.0, stressLevel + amount)
    }
    
    func resetGame() {
        stressLevel = 0.0
        tasksCompleted = 0
        breathingProgress = 0.0
        currentScreen = .home
    }
}