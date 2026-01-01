import Foundation

enum BoardPosition: Equatable, Hashable {
    case yard
    case track(index: Int) // global index 0-51
    case homePath(index: Int) // local index 0-5 (0 is start of safe zone)
    case home
}

struct Token: Identifiable, Equatable, Hashable {
    let id: UUID
    let player: Player
    var position: BoardPosition
    var hasCompleted: Bool {
        if case .home = position { return true }
        return false
    }
}
