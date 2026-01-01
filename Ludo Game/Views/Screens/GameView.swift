import SwiftUI

struct GameView: View {
    @ObservedObject var gameEngine: LudoGameEngine
    @Namespace private var animationNamespace
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            AppConstants.Colors.background.ignoresSafeArea()
            
            VStack {
                // Header (Back + Status)
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "arrow.uturn.backward").foregroundColor(AppConstants.Colors.background))
                    }
                    
                    Spacer()
                    
                    // Turn Indicator
                    Text(gameEngine.state.currentPlayer.name + "'s Turn")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(gameEngine.state.currentPlayer.color))
                }
                .padding()
                
                Spacer()
                
                // Ludo Board
                LudoBoardView(gameEngine: gameEngine, namespace: animationNamespace)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                
                Spacer()
                
                // Dice Section
                DiceView(
                    diceValue: gameEngine.state.diceValue,
                    isRolling: gameEngine.state.isRolling,
                    color: gameEngine.state.currentPlayer.color,
                    onTap: {
                        gameEngine.rollDice()
                    }
                )
                .disabled(gameEngine.state.diceValue != nil && !gameEngine.state.waitingForMove) 
                // Logic: Disable if value exists BUT we need to move? No, if value exists, we wait for board tap.
                // So disable roll button if value is present.
                .opacity((gameEngine.state.diceValue != nil) ? 0.6 : 1.0)
                .padding(.bottom, 40)
            }
            .blur(radius: gameEngine.state.winner != nil ? 10 : 0)
            
            // Win Overlay
            if let winner = gameEngine.state.winner {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Winner!")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(winner.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(winner.color)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                    
                    Button(action: {
                        gameEngine.startGame(playerCount: gameEngine.state.players.count)
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(AppConstants.Colors.background)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                .transition(.scale)
                .zIndex(1)
            }
        }
        .animation(.spring(), value: gameEngine.state.winner)
    }
}
