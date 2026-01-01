import SwiftUI

struct PlayerSelectionView: View {
    @Binding var selectedCount: Int
    var onStart: () -> Void
    
    // Back mock
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    // Back action
                }) {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "arrow.uturn.backward").foregroundColor(.black))
                }
                Spacer()
                
                // Profile/Settings placeholder
                HStack(spacing: -8) {
                    Circle().fill(Color.blue).frame(width: 32, height: 32)
                    Circle().fill(Color.green).frame(width: 32, height: 32)
                }
            }
            .padding()
            
            Spacer().frame(height: 20)
            
            Text("Players on the match")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.black.opacity(0.8))
            
            Spacer().frame(height: 40)
            
            // Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Player.allCases) { player in
                    PlayerAvatarView(
                        player: player,
                        isActive: isPlayerActive(player)
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Selector
            HStack(spacing: 20) {
                ForEach([2, 3, 4], id: \.self) { number in
                    Button(action: {
                        withAnimation {
                            selectedCount = number
                            HapticsManager.shared.playSelection()
                        }
                    }) {
                        Text("\(number)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .frame(width: 60, height: 60)
                            .foregroundColor(selectedCount == number ? .green : .gray)
                            .background(
                                Circle()
                                    .strokeBorder(selectedCount == number ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .scaleEffect(selectedCount == number ? 1.1 : 1.0)
                    }
                }
            }
            
            Text("Chose number of players")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            Spacer().frame(height: 30)
            
            // Start Button (Implied by selection? Or need explicit?)
            // Design doesn't show "Start", but usually we need one.
            // Or maybe tapping the "4" again starts?
            // "Instant playability" - Let's add a clear "Play" button or FAB.
            // Image 1 and 2 don't show a Start button, just the flow.
            // Maybe the floating button is for Start?
            // I'll add a Big Floating Button or just a "Play" button at bottom.
            
            Button(action: onStart) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppConstants.Colors.background)
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 20)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    private func isPlayerActive(_ player: Player) -> Bool {
        // Simple logic: Green, Yellow, Blue, Red
        // 2 players: Green & Red (Usually opposite in Ludo) or Green & Yellow?
        // Let's stick to standard array order for simplicity first.
        let index = Player.allCases.firstIndex(of: player) ?? 0
        return index < selectedCount
    }
}
