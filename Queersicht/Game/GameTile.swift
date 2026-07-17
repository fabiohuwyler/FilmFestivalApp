import SwiftUI

enum TileType: String, CaseIterable {
    case rainbow
    case trans
    case heart
    case queer
    case star
    case flower
    
    var imageName: String {
        switch self {
        case .rainbow: return "piece_rainbow"
        case .trans: return "piece_trans"
        case .heart: return "piece_heart"
        case .queer: return "piece_queer"
        case .star: return "piece_star"
        case .flower: return "piece_flower"
        }
    }
    
    var color: Color {
        switch self {
        case .rainbow: return .red
        case .trans: return .blue
        case .heart: return .pink
        case .queer: return .purple
        case .star: return .yellow
        case .flower: return .green
        }
    }
    
    var points: Int {
        switch self {
        case .rainbow, .trans: return 10  // Special pride symbols worth more
        case .heart, .queer: return 10    // Medium value
        case .star, .flower: return 10    // Basic symbols
        }
    }
}

struct GameTile: Identifiable, Equatable {
    let id = UUID()
    var type: TileType
    var position: CGPoint
    var isMatched: Bool = false
    
    static func == (lhs: GameTile, rhs: GameTile) -> Bool {
        lhs.id == rhs.id
    }
    
    static func random(at position: CGPoint) -> GameTile {
        GameTile(type: TileType.allCases.randomElement()!, position: position)
    }
}
