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
            // Win Overlay (Spotlight & Confetti)
            if let winner = gameEngine.state.winner {
                ZStack {
                    // 1. Spotlight Dimming
                    Color.black.opacity(0.7).ignoresSafeArea()
                        .transition(.opacity)
                    
                    // 2. Confetti
                    ConfettiView()
                    
                    // 3. Elegant Modal
                    VStack(spacing: 24) {
                        Text("Victory!")
                            .font(.system(size: 48, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 10)
                        
                        Text(winner.name + " Wins")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(winner.color)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color.white))
                        
                        Button(action: {
                            withAnimation {
                                gameEngine.startGame(playerCount: gameEngine.state.players.count)
                            }
                        }) {
                            Text("New Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 160)
                                .background(Capsule().stroke(Color.white, lineWidth: 2))
                                .contentShape(Capsule())
                        }
                        .padding(.top, 20)
                    }
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
                .zIndex(2)
            }
        }
        .animation(.spring(), value: gameEngine.state.winner)
    }
}
