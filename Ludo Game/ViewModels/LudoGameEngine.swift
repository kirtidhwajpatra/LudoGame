import SwiftUI
import Combine

class LudoGameEngine: ObservableObject {
    @Published var state: GameState = .initial
    
    // Constants for board logic
    private let trackLength = 52
    
    // Starting positions on the main track for each player
    // Green: 0, Yellow: 13, Blue: 26, Red: 39
    private func startOffset(for player: Player) -> Int {
        switch player {
        case .green: return 0
        case .yellow: return 13
        case .blue: return 26
        case .red: return 39
        }
    }
    
    // MARK: - Game Lifecycle
    
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
    
    // MARK: - Actions
    
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
        
        // Highlight valid moves & Calculate Previews
        state.validMoveTokenIds = Set(movableTokens.map { $0.id })
        
        var previews: [UUID: [BoardPosition]] = [:]
        for token in movableTokens {
            previews[token.id] = calculatePath(for: token, steps: roll)
        }
        state.previewPaths = previews
        
        if movableTokens.isEmpty {
            // No moves possible, skip turn
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.nextTurn()
            }
        } else {
            // Wait for user to select (even if 1 option, for tactile feel)
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
            
            // Ludo Track Logic:
            // - Track length is 52 cells (0-51).
            // - Players enter their Home Path after relative index 50.
            if relativeIndex + roll > 50 {
                let stepsIntoHome = (relativeIndex + roll) - 50
                // stepsIntoHome: 1 corresponds to HomePath index 0
                let targetHomeIndex = stepsIntoHome - 1
                return targetHomeIndex <= 5 // 5 is the Home Goal
            }
            return true
        case .homePath(let index):
            // index 0-5. 5 is Home.
            return index + roll <= 5
        case .home:
            return false
        }
    }
    
    // Execute Move with Stepped Animation
    func moveToken(_ token: Token) {
        guard let index = state.tokens.firstIndex(where: { $0.id == token.id }) else { return }
        let currentToken = state.tokens[index]
        let roll = state.diceValue ?? 0
        
        // 1. Calculate Path
        let path = calculatePath(for: currentToken, steps: roll)
        
        // 2. Start Animation Interaction
        state.waitingForMove = false // Prevent other interactions
        state.validMoveTokenIds = [] // Stop highlighting
        state.previewPaths = [:] // Clear previews
        
        
        animateMovement(tokenIndex: index, path: path) { [weak self] in
            self?.finalizeMove(tokenIndex: index, roll: roll)
        }
    }
    
    // Calculate the sequence of positions
    private func calculatePath(for token: Token, steps: Int) -> [BoardPosition] {
        var path: [BoardPosition] = []
        var currentPos = token.position
        
        if case .yard = currentPos {
            // Yard to Track is 1 step move (if roll is 6)
            if steps == 6 {
                let startPos = boardPosition(at: startOffset(for: token.player))
                path.append(startPos)
            }
            return path
        }
        
        // Simulate step-by-step
        for _ in 0..<steps {
            if let next = getNextStep(from: currentPos, player: token.player) {
                path.append(next)
                currentPos = next
            } else {
                break // Blocked (e.g. at Home)
            }
        }
        
        return path
    }
    
    // Helper for single step calculation
    private func getNextStep(from position: BoardPosition, player: Player) -> BoardPosition? {
        switch position {
        case .yard: return nil // Special case handled above
        case .track(let idx):
            let relativeIndex = getRelativeIndex(for: idx, player: player)
            // trackLength = 52. Relative 0..51.
            // If relative is 50, next is HomePath[0]
            if relativeIndex == 50 {
                return .homePath(index: 0)
            } else {
                return .track(index: (idx + 1) % trackLength)
            }
        case .homePath(let idx):
            if idx < 5 { return .homePath(index: idx + 1) }
            if idx == 5 { return .home }
            return nil
        case .home:
            return nil
        }
    }
    
    private func boardPosition(at index: Int) -> BoardPosition {
        return .track(index: index)
    }
    
    // Recursive Animation
    private func animateMovement(tokenIndex: Int, path: [BoardPosition], completion: @escaping () -> Void) {
        guard !path.isEmpty else {
            completion()
            return
        }
        
        var remainingPath = path
        let nextPos = remainingPath.removeFirst()
        
        // Physical "Snap" Animation
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0)) {
            state.tokens[tokenIndex].position = nextPos
        }
        HapticsManager.shared.playSelection() // Tick per step
        
        // Delay for next step (approx 0.25s per step for fast but physical feel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.animateMovement(tokenIndex: tokenIndex, path: remainingPath, completion: completion)
        }
    }
    

    
    private func finalizeMove(tokenIndex: Int, roll: Int) {
        let currentToken = state.tokens[tokenIndex]
        
        // Handle Collisions (only on track)
        if case .track(let newIndex) = currentToken.position {
            if let collisionIndex = state.tokens.firstIndex(where: {
                if case .track(let tIndex) = $0.position {
                     return tIndex == newIndex && $0.player != currentToken.player
                }
                return false
            }) {
                if !isSafeZone(newIndex) {
                    // Capture!
                    let enemyId = state.tokens[collisionIndex].id
                    
                    // 1. Trigger "Time Slow" / Drain Effect
                    // Immediate visual cue: Enemy desaturates
                    state.capturedTokenId = enemyId
                    HapticsManager.shared.playRigidImpact() // Strong hit
                    
                    // 2. Pause briefly for "Impact Frame" (Emotional Weight)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                        guard let self = self else { return }
                        
                        // 3. Animate Victim to Yard (The "Walk of Shame")
                        var enemyToken = self.state.tokens[collisionIndex]
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                             enemyToken.position = .yard
                        }
                        self.state.tokens[collisionIndex] = enemyToken
                        
                        // Clear drain effect after animation starts (or kept until yard?)
                        // Keeping it until they land in yard feels better.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.state.capturedTokenId = nil
                        }
                    }
                }
            }
        }
        
        state.diceValue = nil
        
        // Check Win Condition
        if state.tokens.filter({ $0.player == state.currentPlayer && $0.hasCompleted }).count == 4 {
            state.winner = state.currentPlayer
            HapticsManager.shared.playSuccess()
            return
        }
        
        // Next Turn Logic (Bonus on 6)
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
    // Standard safe spots are start positions (0, 13, 26, 39) plus cells 8 steps after each start (8, 21, 34, 47).
    private func isSafeZone(_ index: Int) -> Bool {
        let safeIndices = [0, 8, 13, 21, 26, 34, 39, 47]
        return safeIndices.contains(index)
    }
    
    private func nextTurn() {
        state.currentTurnIndex = (state.currentTurnIndex + 1) % state.players.count
        state.diceValue = nil
        state.validMoveTokenIds = []
        state.previewPaths = [:]
    }
}
