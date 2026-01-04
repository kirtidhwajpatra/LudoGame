import SwiftUI

struct PathPreviewLayer: View {
    let previews: [UUID: [BoardPosition]]
    let cellSize: CGFloat
    let player: Player
    
    var body: some View {
        ZStack {
            ForEach(Array(previews.values), id: \.self) { path in
                ForEach(Array(path.enumerated()), id: \.offset) { index, position in
                    let coord = coordinate(for: position)
                    let point = CGPoint(
                        x: CGFloat(coord.col) * cellSize + cellSize / 2,
                        y: CGFloat(coord.row) * cellSize + cellSize / 2
                    )
                    
                    if index == path.count - 1 {
                        // Destination: Glowing Ring
                        Circle()
                            .stroke(player.color, lineWidth: 2)
                            .background(Circle().fill(player.color.opacity(0.2)))
                            .frame(width: cellSize * 0.6, height: cellSize * 0.6)
                            .position(point)
                    } else {
                        // Path: Small Dot
                        Circle()
                            .fill(player.color.opacity(0.4))
                            .frame(width: cellSize * 0.15, height: cellSize * 0.15)
                            .position(point)
                    }
                }
            }
        }
    }
    
    func coordinate(for position: BoardPosition) -> (col: Int, row: Int) {
        switch position {
        case .yard: return (0,0) // Should not happen in track path
        case .track, .homePath, .home:
            return LudoBoardGeometry.getCoordinate(for: position, player: player)
        }
    }
}
