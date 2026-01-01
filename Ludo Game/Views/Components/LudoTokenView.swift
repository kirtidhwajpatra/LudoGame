import SwiftUI

struct LudoTokenView: View {
    let token: Token
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: cellSize * 0.9, height: cellSize * 0.9)
                .shadow(radius: 2, y: 2)
            
            Circle()
                .fill(token.player.color)
                .frame(width: cellSize * 0.7, height: cellSize * 0.7)
            
            // Highlight/Bevel
            Circle()
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                .frame(width: cellSize * 0.6)
            
            if token.hasCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: cellSize * 0.4, weight: .bold))
            }
        }
        // Selection Pulse logic could go here
    }
}
