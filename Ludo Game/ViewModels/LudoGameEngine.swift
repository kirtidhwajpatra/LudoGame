import SwiftUI
import Combine

class LudoGameEngine: ObservableObject {
    @Published var state: GameState = .initial
    
    // Constants for board logic
    private let trackLength = 52
    
    // Starting positions on the main track for each player
    // Green: 0, Yellow: 13, Blue: 26, Red: 39 (Standard Ludo offsets)
    private func startOffset(for player: Player) -> Int {
        switch player {
        case .green: return 0
        case .yellow: return 13
        case .blue: return 26
        case .red: return 39
        }
    }
    
    // Initialize Game
    func startGame(playerCount: Int) {
        let selectedPlayers = Array(Player.allCases.prefix(playerCount))
        var initialTokens: [Token] = []
        
        for player in selectedPlayers {
            for _ in 0..<4 {
                initialTokens.append(Token(id: UUID(), player: player, position: .yard))
            }
        }
        
        state = GameState(
            players: selectedPlayers,
            currentTurnIndex: 0,
            diceValue: nil,
            isRolling: false,
            tokens: initialTokens,
            winner: nil,
            waitingForMove: false
        )
    }
    
    // Roll Dice Logic
    func rollDice() {
        guard !state.isRolling && !state.waitingForMove else { return }
        
        state.isRolling = true
        HapticsManager.shared.playDiceRoll()
        
        // Simulate roll delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            let roll = Int.random(in: 1...6)
            self.state.diceValue = roll
            self.state.isRolling = false
            HapticsManager.shared.playMediumImpact()
            
            self.handleRollResult(roll)
        }
    }
    
    private func handleRollResult(_ roll: Int) {
        // Check for valid moves
        let playerTokens = state.tokens.filter { $0.player == state.currentPlayer }
        let movableTokens = playerTokens.filter { canMove(token: $0, roll: roll) }
        
        if movableTokens.isEmpty {
            // No moves possible, skip turn
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.nextTurn()
            }
        } else if movableTokens.count == 1 {
            // Auto-move if only one option (optional UX choice, keeps game fast)
            // But for "Touch = reaction" principle, maybe we should still require a tap?
            // The prompt says "Touch = reaction (always)". So let's NOT auto-move unless strictly necessary?
            // "Every tap must feel acknowledged." -> Implies user interaction.
            // I'll leave it as manual for now to wait for user tap.
             state.waitingForMove = true
        } else {
            // Wait for user to select
            state.waitingForMove = true
        }
    }
    
    // Validate Move
    func canMove(token: Token, roll: Int) -> Bool {
        if token.player != state.currentPlayer { return false }
        
        switch token.position {
        case .yard:
            return roll == 6
        case .track(let index):
            let relativeIndex = getRelativeIndex(for: index, player: token.player)
            // track end is 50 (51st step is entry to home path)
            // Total steps from start to home is 51 (0..50) + 6 steps home path = 57 steps?
            // Standard Ludo: 52 cells. one lap is 52.
            // Player starts at offset X. Goes around. Enters home path just before X.
            // Home path entry is at (X - 1 + 52) % 52.
            
            // Re-evaluating standard Ludo board:
            // 52 common cells.
            // Player Start Index for Green is 0 (or 2 depending on board variant, assuming 0 for simplicity).
            // Player enters home straight at cell 50 relative to their start (0-based) ??
            // Let's use relative index 0-51 (one lap).
            // Player enters Home Path after relative index 50.
            
            if relativeIndex + roll > 50 {
                let stepsIntoHome = (relativeIndex + roll) - 50
                // stepsIntoHome: 1 means index 0 of MovePath?
                // let's say roll takes you 1 step past 50. That is HomePath[0].
                // Max relative index is 50.
                // 50 + 1 => HomePath[0].
                // HomePath has 0..5 (length 6). 5 is Home Goal.
                
                let targetHomeIndex = stepsIntoHome - 1
                return targetHomeIndex <= 5 // 5 is Home
            }
            return true
        case .homePath(let index):
            // index 0-5. 5 is Home.
            return index + roll <= 5
        case .home:
            return false
        }
    }
    
    // Execute Move
    func moveToken(_ token: Token) {
        // Find fresh token state
        guard let index = state.tokens.firstIndex(where: { $0.id == token.id }) else { return }
        var currentToken = state.tokens[index]
        let roll = state.diceValue ?? 0
        
        // 1. Calculate new position
        var newPosition: BoardPosition = currentToken.position
        
        switch currentToken.position {
        case .yard:
            if roll == 6 {
                newPosition = .track(index: startOffset(for: currentToken.player))
            }
        case .track(let currentIndex):
            let relativeIndex = getRelativeIndex(for: currentIndex, player: currentToken.player)
            if relativeIndex + roll > 50 {
                // Enter Home Path
                let stepsIntoHome = (relativeIndex + roll) - 50
                let targetHomeIndex = stepsIntoHome - 1
                
                if targetHomeIndex == 5 {
                    newPosition = .home
                } else {
                    newPosition = .homePath(index: targetHomeIndex)
                }
            } else {
                newPosition = .track(index: (currentIndex + roll) % trackLength)
            }
        case .homePath(let currentIndex):
            if currentIndex + roll == 5 {
                newPosition = .home
            } else {
                newPosition = .homePath(index: currentIndex + roll)
            }
        case .home:
            break
        }
        
        // 2. Handle Collisions (only on track)
        if case .track(let newIndex) = newPosition {
            if let collisionIndex = state.tokens.firstIndex(where: { 
                if case .track(let tIndex) = $0.position {
                     return tIndex == newIndex && $0.player != currentToken.player
                }
                return false
            }) {
                // Check if safe zone
                if !isSafeZone(newIndex) {
                    // Capture!
                    var enemyToken = state.tokens[collisionIndex]
                    enemyToken.position = .yard
                    state.tokens[collisionIndex] = enemyToken
                    HapticsManager.shared.playRigidImpact()
                }
            }
        }
        
        // 3. Update Token
        currentToken.position = newPosition
        state.tokens[index] = currentToken
        
        // 4. Animation & Haptics
        HapticsManager.shared.playSelection()
        state.diceValue = nil
        state.waitingForMove = false
        
        // 5. Check Win Condition
        if state.tokens.filter({ $0.player == state.currentPlayer && $0.hasCompleted }).count == 4 {
            state.winner = state.currentPlayer
            HapticsManager.shared.playSuccess()
            return
        }
        
        // 6. Next Turn Logic
        // Bonus turn for rolling 6
        if roll != 6 {
            nextTurn()
        }
    }
    
    // Helper: Get index relative to player's start (0-51)
    private func getRelativeIndex(for index: Int, player: Player) -> Int {
        let offset = startOffset(for: player)
        return (index - offset + trackLength) % trackLength
    }
    
    // Helper: Safe Zones (Star cells)
    // Standard Ludo Safe Zones: 0, 8, 13, 21, 26, 34, 39, 47 (approximate common rules)
    // Adjusting based on standard board:
    // Green Start: 0. Safe.
    // Yellow Start: 13. Safe.
    // Blue Start: 26. Safe.
    // Red Start: 39. Safe.
    // Plus the ones 8 steps ahead? Usually standard Ludo has safe spots at 1, 9... wait.
    // Let's stick to the 4 start points + maybe safe points are visual. 
    // The design shows stars at specific places.
    // Looking at Image 1: Green zone has a Star at relative position ~8?
    // Let's assume Starts + global indices +8 relative.
    private func isSafeZone(_ index: Int) -> Bool {
        let safeIndices = [0, 8, 13, 21, 26, 34, 39, 47]
        return safeIndices.contains(index)
    }
    
    private func nextTurn() {
        state.currentTurnIndex = (state.currentTurnIndex + 1) % state.players.count
        state.diceValue = nil
    }
}
