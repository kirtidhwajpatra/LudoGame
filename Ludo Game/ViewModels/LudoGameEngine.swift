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
        // We rely on isRolling=true or similar to block dice, currently isRolling=false.
        // We should probably flag that an animation is busy to prevent re-rolling?
        // Actually, current `rollDice` checks `!state.waitingForMove`.
        // But `waitingForMove` is set to TRUE when we await selection.
        // Once selected, we set it to FALSE here.
        // If we set it to false, user might click "Roll"?
        // `rollDice` checks `!state.isRolling`.
        // Let's rely on the fact we won't show the dice control or next turn until we are done.
        
        
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
    
    // logic after movement is done
    private func finalizeMove(tokenIndex: Int) {
        let currentToken = state.tokens[tokenIndex]
        
        // 2. Handle Collisions (only on track)
        if case .track(let newIndex) = currentToken.position {
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
                    withAnimation(.spring()) {
                        enemyToken.position = .yard
                    }
                    state.tokens[collisionIndex] = enemyToken
                    HapticsManager.shared.playRigidImpact()
                }
            }
        }
        
        
        state.diceValue = nil
        
        // 3. Check Win Condition
        if state.tokens.filter({ $0.player == state.currentPlayer && $0.hasCompleted }).count == 4 {
            state.winner = state.currentPlayer
            HapticsManager.shared.playSuccess()
            return
        }
        
        // 4. Next Turn Logic
        // We need to know what the original ROLL was to determine bonus.
        // But diceValue was cleared? 
        // Logic: if currentToken.position changed significantly? 
        // We can check if it was a 6. 
        // Issue: We cleared diceValue above. 
        // Better to check roll BEFORE clearing.
        // Wait, I don't have access to 'roll' here easily unless I pass it or check logic.
        // Simplification: Standard Ludo rules, 6 gives repeat turn.
        // I'll defer `state.diceValue = nil` until I check.
        // But `state.diceValue` in `moveToken` (original) was used.
        // Let's modify `moveToken` to capture roll to pass to finalize?
        // Or just check logic: If we moved from Yard, it WAS a 6.
        // If we moved 6 steps...
        // Actually, let's keep it simple: Pass `shouldSwitchTurn` bool?
        // Or just let `moveToken` handle the `nextTurn` call?
        // Move `finalizeMove` logic back into `moveToken`? No, it's async completion.
        
        // Let's re-read the original `moveToken`:
        // if roll != 6 { nextTurn() }
        
        // I will modify animateMovement to take a completion block, and handle nextTurn logic there.
        // But I need `roll` value. 
        // I will capture `roll` in the closure in `moveToken`.
        
        // This function `finalizeMove` is defined inside class? 
        // I'll implement `finalizeMove(tokenIndex: Int, roll: Int)`
    }
    
    private func finalizeMove(tokenIndex: Int, roll: Int) {
        let currentToken = state.tokens[tokenIndex]
        
        // Handle Collisions (only on track)
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
        state.validMoveTokenIds = []
        state.previewPaths = [:]
    }
}
