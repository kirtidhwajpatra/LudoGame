import SwiftUI

struct PlayerAvatarView: View {
    let player: Player
    let isActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(player.color)
                .shadow(color: player.color.opacity(0.4), radius: 8, x: 0, y: 5)
            
            if isActive {
                // Active Avatar
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .background(Circle().fill(Color.white.opacity(0.3)))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    )
            } else {
                // Placeholder
                Circle()
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                    )
            }
        }
        .frame(height: 140)
        .scaleEffect(isActive ? 1.0 : 0.95)
        .opacity(isActive ? 1.0 : 0.6)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isActive)
    }
}
