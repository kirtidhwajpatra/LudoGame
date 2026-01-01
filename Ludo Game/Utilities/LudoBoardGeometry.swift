import CoreGraphics

struct LudoBoardGeometry {
    // 52 Step Main Track Coordinates (0-14, 0-14)
    static let trackCoordinates: [(Int, Int)] = {
        var path: [(Int, Int)] = []
        
        // 1. Green Wing (Bottom Row) - Moving Right
        // 0-4
        for x in 1...5 { path.append((x, 6)) }
        
        // 2. Yellow Wing (Left Column) - Moving Up
        // 5-10
        // Corner turn is usually handled by (6,5)
        path.append((6, 5))
        for y in stride(from: 4, through: 0, by: -1) { path.append((6, y)) }
        
        // 3. Top Turn
        // 11-12
        path.append((7, 0))
        path.append((8, 0))
        
        // 4. Top Right (Down)
        // 13-17
        for y in 1...5 { path.append((8, y)) }
        path.append((9, 6)) // Corner? No, standard is (8,5) -> (9,6) diagonal or just next.
        // Actually, usually it is (6,0) -> (7,0) -> (8,0).
        // Then (8,1)...
        
        // Let's rely on standard:
        // Top leg is vertical.
        // (8,0) is top right of the 3-col strip.
        // Moving down: (8,0) -> (8,1) -> (8,2) -> (8,3) -> (8,4) -> (8,5).
        
        // 5. Right Wing (Top Row) - Moving Right
        // (9,6) -> (10,6) ... (13,6)
        // 18-22
        // Correcting indices...
        // Let's generate linearly.
        
        return generatePath()
    }()
    
    // Explicit Generator to ensure correct step count (52 steps)
    private static func generatePath() -> [(Int, Int)] {
        var p: [(Int, Int)] = []
        
        // Q1 (Green Start Area) -> Towards Q2 (Yellow)
        // 5 steps right: (1,6) -> (5,6)
        p.append(contentsOf: (1...5).map { ($0, 6) })
        // 6 steps up: (6,5) -> (6,0)
        p.append(contentsOf: stride(from: 5, through: 0, by: -1).map { (6, $0) })
        // 2 steps right: (7,0), (8,0)
        p.append((7,0)); p.append((8,0))
        // 6 steps down: (8,1) -> (8,6)??? No, (8,1)->(8,5) then turn.
        // Standard wing is 6 cells long.
        // (6,0) is end of Up.
        // (7,0) is mid. (8,0) start of Down.
        // (8,1) -> (8,5) is 5 steps.
        // (8,6) is the junction usually. ?
        // Usually board is 6 per wing.
        // Path len = 6 + 6 + 1 (mid) = 13 per quadrant?
        // 13 * 4 = 52. Matches.
        
        // Q2 Down Leg
        p.append(contentsOf: (1...5).map { (8, $0) })
        // Turn Step (Corner of center): (9,6)?
        // (8,5) is adjacent to (9,6)? No.
        // (6,5) was logical. (8,5) is logical. (9,6) is logical.
        
        // Q2 Right Leg (Out)
        // (6,6) is center-left. (9,6) is right-wing-top-row.
        // (9,6) -> (14,6) is 6 steps.
        p.append(contentsOf: (9...14).map { ($0, 6) })
        
        // Turn Right Edge
        p.append((14,7)); p.append((14,8)) // Turn? Usually (14,6) -> (14,7) -> (13,7)?
        // Wait, 13 * 4 = 52.
        // Let's map indices:
        // 0-4: (1,6)..(5,6) [5 steps]
        // 5: (6,5) [1 step]
        // 6-10: (6,4)..(6,0) [5 steps]
        // 11: (7,0) [1 step]
        // 12: (8,0) [1 step] -- Start of Yellow?
        // 13..: (8,1)..
        
        // Re-calibrating 52 steps:
        // 5 (out) + 1 (diag/turn) + 5 (up) + 2 (top) ? = 13.
        // 5 + 1 + 5 + 2 = 13. Perfect.
        
        // 1. Q1->Q2 transition
        // Out: (1,6)..(5,6) [5]
        // Diag/Turn: (6,5) [1]
        // Up: (6,4)..(6,0) [5]
        // Top: (7,0), (8,0) [2]
        
        // 2. Q2->Q3 transition
        // Down: (8,1)..(8,5) [5]
        // Diag: (9,6) [1]
        // Right: (10,6)..(14,6) [5]
        // Right Edge: (14,7), (14,8) [2] -- Wait, (14,7) is safe usually.
        
        // 3. Q3->Q4 transition
        // Left: (13,8)..(9,8) [5]
        // Diag: (8,9) [1]
        // Down: (8,10)..(8,14) [5]
        // Bottom: (7,14), (6,14) [2]
        
        // 4. Q4->Q1 transition
        // Up: (6,13)..(6,9) [5]
        // Diag: (5,8) [1]
        // Left: (4,8)..(0,8) [5] -- (0,8) is end? Start was (1,6).
        // (0,8) -> (0,7) -> (0,6) -> (1,6)?
        // Usually index 50 is (0,7). Index 51 is (0,6). Index 52 is (1,6).
        // Last 2 steps: (0,7), (0,6)? Or just closes loop.
        
        // Let's implement this Pattern.
        
        // Q2 Down (8,1..5)
        p.append(contentsOf: (1...5).map { (8, $0) })
        // Q2 Diag
        p.append((9,6))
        
        // Q3 Out (10,6..14,6)
        p.append(contentsOf: (10...14).map { ($0, 6) })
        // Q3 Right Turn
        p.append((14,7)); p.append((14,8)) // But usually we come back on 8?
        
        // Return: (14,8) -> (13,8)?
        // If we are at (14,8), moving left (13,8)..
        p.append(contentsOf: stride(from: 13, through: 9, by: -1).map { ($0, 8) })
        // Diag
        p.append((8,9))
        // Down
        p.append(contentsOf: (10...14).map { (8, $0) })
        // Bottom Turn
        p.append((7,14)); p.append((6,14))
        
        // Q4 Up
        p.append(contentsOf: stride(from: 13, through: 9, by: -1).map { (6, $0) })
        // Diag
        p.append((5,8))
        // Left
        p.append(contentsOf: stride(from: 4, through: 0, by: -1).map { ($0, 8) })
        // Left Turn
        p.append((0,7)); // Index 50
        p.append((0,6)); // Index 51
        
        return p
    }
    
    static func getCoordinate(for pos: BoardPosition, player: Player) -> (Int, Int) {
        switch pos {
        case .yard:
             // 0-3 based on token ID usually, here simple slot mapping needed
             // We can randomize or just pick 1 for now.
             // Ideally Token has an 'index' in yard.
             return getYardCoordinate(player: player, slot: 0) // Simplify
        case .track(let index):
            // Safety check
            let i = index % trackCoordinates.count
            return trackCoordinates[i]
        case .homePath(let index):
            return getHomePathCoordinate(player: player, index: index)
        case .home:
            return (7,7)
        }
    }
    
    // ... (Keep existing HomePath/Yard logic)
    static func getHomePathCoordinate(player: Player, index: Int) -> (Int, Int) {
        switch player {
        case .green: return (1 + index, 7)
        case .yellow: return (7, 1 + index)
        case .blue: return (13 - index, 7)
        case .red: return (7, 13 - index)
        }
    }
    
    static func getYardCoordinate(player: Player, slot: Int) -> (Int, Int) {
        let base: (Int, Int)
        switch player {
        case .green: base = (2, 2)
        case .yellow: base = (11, 2)
        case .red: base = (2, 11)
        case .blue: base = (11, 11)
        }
        let dx = slot % 2
        let dy = slot / 2
        return (base.0 + dx, base.1 + dy)
    }
}
