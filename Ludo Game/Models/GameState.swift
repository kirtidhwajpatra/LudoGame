import Foundation

struct GameState {
    var players: [Player] = []
    var currentTurnIndex: Int = 0
    var diceValue: Int? = nil
    var isRolling: Bool = false
    var tokens: [Token] = []
    var winner: Player? = nil
    var waitingForMove: Bool = false
    var validMoveTokenIds: Set<UUID> = []
    var previewPaths: [UUID: [BoardPosition]] = [:]
    var capturedTokenId: UUID? = nil
    
    var currentPlayer: Player {
        guard !players.isEmpty else { return .green }
        return players[currentTurnIndex]
    }
    
    static let initial = GameState()
}
