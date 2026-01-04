import SwiftUI

struct LudoTokenView: View {
    let token: Token
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            // Pure Emoji Design (Clean, No Background)
            // Dynamic Sizing based on location
            let isYard = (token.position == .yard)
            let scale: CGFloat = isYard ? 1.5 : 1.1
            
            Text(emoji(for: token.player))
                .font(.system(size: cellSize * scale))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2) // Subtle lift
            
            // Minimal Status Indicator
            if token.hasCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .background(Circle().fill(Color.white))
                    .font(.system(size: cellSize * 0.3))
                    .offset(x: cellSize * 0.3, y: -cellSize * 0.3)
            }
        }
    }
    
    func emoji(for player: Player) -> String {
        switch player {
        case .green: return "🐸"
        case .yellow: return "🐥"
        case .blue: return "🐬"
        case .red: return "🦀"
        }
    }
        // Selection Pulse logic could go here
    
}
