import SwiftUI

// Game screens enumeration - expanded narrative flow
enum GameScreen {
    case home, prologue, morningScene, workScene, innerThoughts
    case breakingPoint, act2Overwhelmed, lightAppears, act3Breathe, ending, about
}

// Observable game state
@Observable
class GameState {
    var currentScreen: GameScreen = .home
    var stressLevel: Float = 0
    var breathingProgress: Float = 0
    
    func navigateTo(_ screen: GameScreen) {
        withAnimation(.easeInOut(duration: 0.5)) { currentScreen = screen }
    }
    
    func increaseStress(by amount: Float = 0.1) { stressLevel = min(1, stressLevel + amount) }
    
    func resetGame() { stressLevel = 0; breathingProgress = 0 }
}