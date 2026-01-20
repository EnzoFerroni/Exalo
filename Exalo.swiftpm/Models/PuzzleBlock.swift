import SwiftUI

// Puzzle block colors
enum BlockColor {
    case blue
    case pink
    
    var color: Color {
        switch self {
        case .blue:
            return Color(red: 0.55, green: 0.75, blue: 0.9)
        case .pink:
            return Color(red: 0.95, green: 0.7, blue: 0.75)
        }
    }
}

// Puzzle block model
struct PuzzleBlock: Identifiable, Equatable {
    let id: UUID
    var blockColor: BlockColor
    var currentPosition: CGPoint
    var targetPosition: CGPoint
    var isPlaced: Bool
    var size: CGSize
    
    init(
        id: UUID = UUID(),
        blockColor: BlockColor,
        currentPosition: CGPoint,
        targetPosition: CGPoint,
        size: CGSize = CGSize(width: 60, height: 60)
    ) {
        self.id = id
        self.blockColor = blockColor
        self.currentPosition = currentPosition
        self.targetPosition = targetPosition
        self.isPlaced = false
        self.size = size
    }
    
    var isNearTarget: Bool {
        let distance = hypot(
            currentPosition.x - targetPosition.x,
            currentPosition.y - targetPosition.y
        )
        return distance < 40
    }
}
