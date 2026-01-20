import SwiftUI

// Main navigation coordinator for Exalo game
struct ContentView: View {
    @State private var gameState = GameState()
    
    var body: some View {
        ZStack {
            switch gameState.currentScreen {
            case .home:
                HomeView(gameState: gameState)
                    .transition(.opacity)
                
            case .prologue:
                PrologueView(gameState: gameState)
                    .transition(.opacity)
                
            case .morningScene:
                MorningSceneView(gameState: gameState)
                    .transition(.opacity)
                
            case .workScene:
                WorkSceneView(gameState: gameState)
                    .transition(.opacity)
                
            case .innerThoughts:
                InnerThoughtsView(gameState: gameState)
                    .transition(.opacity)
                
            case .breakingPoint:
                BreakingPointView(gameState: gameState)
                    .transition(.opacity)
                
            case .act2Overwhelmed:
                Act2OverwhelmedView(gameState: gameState)
                    .transition(.opacity)
                
            case .lightAppears:
                LightAppearsView(gameState: gameState)
                    .transition(.opacity)
                
            case .act3Breathe:
                Act3BreatheView(gameState: gameState)
                    .transition(.opacity)
                
            case .ending:
                EndingView(gameState: gameState)
                    .transition(.opacity)
                
            case .about:
                AboutView(gameState: gameState)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: gameState.currentScreen)
    }
}