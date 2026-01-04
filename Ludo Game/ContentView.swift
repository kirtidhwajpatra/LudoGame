import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    @State private var gameStarted = false
    @StateObject private var gameEngine = LudoGameEngine()
    
    // Player Selection State
    @State private var selectedPlayerCount = 4
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            } else if !gameStarted {
                // Player Selection
                PlayerSelectionView(
                    selectedCount: $selectedPlayerCount,
                    onStart: {
                        gameEngine.startGame(playerCount: selectedPlayerCount)
                        withAnimation {
                            gameStarted = true
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            } else {
                // Main Game
                GameView(gameEngine: gameEngine)
                    .transition(.opacity)
            }
        }
        .animation(.spring(), value: isLoading)
        .animation(.spring(), value: gameStarted)
        .onAppear {
            // Explicitly handle loading delay here
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

#Preview{
    ContentView()
}
