//Testar o básico do SpriteKit

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Cria o chao
        let floor = SKSpriteNode(color: .gray, size: CGSize(width: size.width, height: 20))
        floor.position = CGPoint(x: size.width / 2, y: 10)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        addChild(floor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Cores aleatorias
        let colors: [UIColor] = [.red, .blue, .green, .orange, .purple, .cyan]
        let randomColor = colors.randomElement() ?? .blue
        let randomSize = CGFloat.random(in: 40...60)
        
        // Cria sprite com fisica
        let sprite = SKSpriteNode(color: randomColor, size: CGSize(width: randomSize, height: randomSize))
        sprite.position = location
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.restitution = 0.6
        addChild(sprite)
    }
}

struct SpriteKitView: View {
    var body: some View {
        VStack {
            Text("Toque para criar objetos")
                .padding()
            
            SpriteView(scene: {
                let scene = GameScene()
                scene.size = CGSize(width: 400, height: 500)
                scene.scaleMode = .aspectFill
                return scene
            }())
        }
    }
}

#Preview {
    SpriteKitView()
}
