import SwiftUI

// MARK: - 1. Color Palette Extension
// Matches the specific flat design colors from your Figma reference
extension Color {
    static let ludoGreen = AppConstants.Colors.green
    static let ludoYellow = AppConstants.Colors.yellow
    static let ludoBlue = AppConstants.Colors.blue
    static let ludoRed = AppConstants.Colors.red
    static let ludoGrid = AppConstants.Colors.boardGrid
    static let ludoPurple = AppConstants.Colors.background
}

// MARK: - 2. Custom Types (Fixed Ambiguity)

// Renamed to 'ArrowDirection' to avoid conflict with SwiftUI 'Image.Orientation'
enum ArrowDirection: Equatable {
    case up, down, left, right
}

// Conforms to Equatable to fix the "Referencing operator function '=='" error
enum CellType: Equatable {
    case normal
    case colored
    case star
    case arrow(direction: ArrowDirection)
}

// MARK: - 3. Main Board View

struct LudoBoardView: View {
    @ObservedObject var gameEngine: LudoGameEngine
    var namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { geo in
            // Ensure board is square based on the smallest dimension
            let boardSize = min(geo.size.width, geo.size.height)
            let cellSize = boardSize / 15
            
            ZStack {
                // Layer 1: The Board Design
                BoardGridLayer(cellSize: cellSize, activePlayer: gameEngine.state.currentPlayer)
                
                // Layer 1.5: Path Previews (Intelligent Guidance)
                PathPreviewLayer(
                    previews: gameEngine.state.previewPaths,
                    cellSize: cellSize,
                    player: gameEngine.state.currentPlayer
                )
                
                // Layer 2: Tokens
                // (Using your existing logic for tokens)
                ForEach(gameEngine.state.tokens) { token in
                    LudoTokenView(
                        token: token,
                        cellSize: cellSize,
                        isMovable: gameEngine.state.validMoveTokenIds.contains(token.id),
                        shouldDim: !gameEngine.state.validMoveTokenIds.isEmpty && !gameEngine.state.validMoveTokenIds.contains(token.id),
                        isCaptured: gameEngine.state.capturedTokenId == token.id,
                        isWinner: gameEngine.state.winner == token.player
                    )
                        .position(position(for: token, cellSize: cellSize))
                        .onTapGesture {
                            if gameEngine.state.diceValue != nil {
                                gameEngine.moveToken(token)
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: token.position)
                }
            }
            .frame(width: boardSize, height: boardSize)
            .frame(width: boardSize, height: boardSize)
            .background(Color.ludoPurple)
            // Optional: Shadow and Corner Radius for the whole board card
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }

    // Helper to map BoardPosition to CGPoint on the 15x15 grid
    func position(for token: Token, cellSize: CGFloat) -> CGPoint {
        switch token.position {
        case .yard:
            // Custom visual grouping for Yard (Extra Close and Center)
            // Layout: 6x6 area. Center is 3.0.
            // visual offsets: 2.2 and 3.8 (Distance 1.6).
            let playerTokens = gameEngine.state.tokens.filter { $0.player == token.player }
            let index = playerTokens.firstIndex(where: { $0.id == token.id }) ?? 0
            
            // Map index 0..3 to offsets
            // 0: (2.2, 2.2), 1: (3.8, 2.2)
            // 2: (2.2, 3.8), 3: (3.8, 3.8)
            let safeIndex = max(0, min(index, 3))
            
            let dx: CGFloat = (safeIndex % 2 == 0) ? 2.2 : 3.8
            let dy: CGFloat = (safeIndex < 2) ? 2.2 : 3.8
            
            // Base Offsets (Top-Left of Yard)
            let bx: CGFloat
            let by: CGFloat
            
            switch token.player {
            case .green:  (bx, by) = (0, 0)
            case .yellow: (bx, by) = (9, 0)
            case .red:    (bx, by) = (0, 9)
            case .blue:   (bx, by) = (9, 9)
            }
            
            // Return precise point
            return CGPoint(
                x: (bx + dx) * cellSize,
                y: (by + dy) * cellSize
            )
            
        case .track, .homePath, .home:
            let (x, y) = LudoBoardGeometry.getCoordinate(for: token.position, player: token.player)
            return CGPoint(
                x: CGFloat(x) * cellSize + cellSize / 2,
                y: CGFloat(y) * cellSize + cellSize / 2
            )
        }
    }
}

// MARK: - 4. Board Grid Components

struct BoardGridLayer: View {
    let cellSize: CGFloat
    let activePlayer: Player
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Section
                HStack(spacing: 0) {
                    CornerYard(color: .ludoGreen, cellSize: cellSize, isActive: activePlayer == .green)
                    VerticalTrack(playerColor: .ludoYellow, cellSize: cellSize, isTop: true)
                    CornerYard(color: .ludoYellow, cellSize: cellSize, isActive: activePlayer == .yellow)
                }
                
                // Middle Section
                HStack(spacing: 0) {
                    HorizontalTrack(playerColor: .ludoGreen, cellSize: cellSize, isLeft: true)
                    CenterHome(cellSize: cellSize)
                    HorizontalTrack(playerColor: .ludoBlue, cellSize: cellSize, isLeft: false)
                }
                
                // Bottom Section
                HStack(spacing: 0) {
                    CornerYard(color: .ludoRed, cellSize: cellSize, isActive: activePlayer == .red)
                    VerticalTrack(playerColor: .ludoRed, cellSize: cellSize, isTop: false)
                    CornerYard(color: .ludoBlue, cellSize: cellSize, isActive: activePlayer == .blue)
                }
            }
            .border(Color.black.opacity(0.1), width: 1)
            
            // Turn Arrows Overlay
            // Positioned specifically at the turns into Home Runs
            // 1. Green (Left): Arrow pointing RIGHT into Green Home (Row 7, Col 1-5).
            //    Entry is from Col 6 (White) into Col 5 (End of home run? No).
            //    Green Home Run: (1,7) to (5,7).
            //    Entry is from (6,6) [Top of Left-Horizontal] -> Turn into (?
            //    Green path: Travels UP col 6. Arrives at (6,6).
            //    Turns RIGHT into Home (7,7 - Center). No.
            //    Let's check Geometry.
            //    Green Path: (6,0)..(6,5) [Up].
            //    Usually Green Home Entry is at (0,7)?
            //    If I am Green, I start at (1,6). I go around.
            //    I approach Green Home from (0,6) ?
            //    (0,6) -> (0,7) -> Home Run.
            //    The arrow should be at (0,6) pointing into (1,7)?
            
            //    Reference image shows Arrow bridging a White Cell and a Yellow Cell.
            //    Let's place them at standard Ludo "Turn" spots.
            //    Yellow Home Entry: (6,0) -> (7,0) ?
            //    Yellow Home Path starts at (7,1).
            //    Entrance is from (6, ?)
            //    Yellow approaches from Col 6, Top.
            //    Specific cell: (6,0) is white. (7,0) is top-middle (Start).
            //    If purely visual matching:
            //    Yellow Arrow: At (6,0) (Top Right of Green Quad/Top Left of Vertical Strip).
            //                  Points East? Or curves into South.
            
            //    Let's assume standard visual placement:
            //    Green Turn: At (0,6). Points Right.
            //    Yellow Turn: At (6,0). Points Down.
            //    Blue Turn: At (14,8). Points Left.
            //    Red Turn: At (8,14). Points Up.
            
            let arrowSize = cellSize * 2.0 // Spanning 2 cells visually?
            // The arrow shape is 27x33 (approx 0.8 aspect).
            // Let's place it at the junction.
            
            TurnArrowLayer(cellSize: cellSize)
        }
    }
}

// MARK: - Corner Yard (Refined)
struct CornerYard: View {
    let color: Color
    let cellSize: CGFloat
    let isActive: Bool
    
    var body: some View {
        ZStack {
            // Base Color
            Rectangle().fill(color)
            
            // White Container (The "Yard" area) - Rounded Square
            RoundedRectangle(cornerRadius: cellSize)
                .fill(Color.white)
                .padding(cellSize * 0.7) // Less padding to make the white area larger
            
            // The 4 Token Placeholders (Grouped Extra Close & Center)
            // Base Size = 1.5. Center Distance = 1.6.
            // Spacing = 1.6 - 1.5 = 0.1.
            VStack(spacing: cellSize * 0.1) {
                HStack(spacing: cellSize * 0.1) {
                    TokenPlaceholder(color: color, size: cellSize * 1.5)
                    TokenPlaceholder(color: color, size: cellSize * 1.5)
                }
                HStack(spacing: cellSize * 0.1) {
                    TokenPlaceholder(color: color, size: cellSize * 1.5)
                    TokenPlaceholder(color: color, size: cellSize * 1.5)
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
        .opacity(isActive ? 1.0 : 0.6)
        .scaleEffect(isActive ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: isActive)
    }
}


struct TokenPlaceholder: View {
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: max(1.8, size * 0.07))
                )
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Vertical Track
struct VerticalTrack: View {
    let playerColor: Color
    let cellSize: CGFloat
    let isTop: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<6) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3) { col in
                        let cellType = getVerticalCellType(row: row, col: col)
                        
                        BoardCell(
                            type: cellType,
                            color: playerColor,
                            cellSize: cellSize
                        )
                    }
                }
            }
        }
        .frame(width: cellSize * 3, height: cellSize * 6)
    }
    
    func getVerticalCellType(row: Int, col: Int) -> CellType {
        if isTop {
            // Top Track (Yellow)
            if col == 1 && row > 0 { return .colored }
            if col == 2 && row == 1 { return .colored } // Start (was arrow)
            if col == 0 && row == 2 { return .star } // Safe
        } else {
            // Bottom Track (Red)
            if col == 1 && row < 5 { return .colored }
            if col == 0 && row == 4 { return .colored } // Start (was arrow)
            if col == 2 && row == 3 { return .star } // Safe
        }
        return .normal
    }
}

// MARK: - Horizontal Track
struct HorizontalTrack: View {
    let playerColor: Color
    let cellSize: CGFloat
    let isLeft: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { row in
                HStack(spacing: 0) {
                    ForEach(0..<6) { col in
                        let cellType = getHorizontalCellType(row: row, col: col)
                        
                        BoardCell(
                            type: cellType,
                            color: playerColor,
                            cellSize: cellSize
                        )
                    }
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 3)
    }
    
    func getHorizontalCellType(row: Int, col: Int) -> CellType {
        if isLeft {
            // Left Track (Green)
            if row == 1 && col > 0 { return .colored }
            if row == 0 && col == 1 { return .colored } // Start (was arrow)
            if row == 2 && col == 2 { return .star } // Safe
        } else {
            // Right Track (Blue)
            if row == 1 && col < 5 { return .colored }
            if row == 2 && col == 4 { return .colored } // Start (was arrow)
            if row == 0 && col == 3 { return .star } // Safe
        }
        return .normal
    }
}

// MARK: - Single Cell View
struct BoardCell: View {
    let type: CellType
    let color: Color
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            // Start cells (arrows) and Home Path cells are colored
            // Background
            // Background
            // Start cells (arrows) and Home Path cells are colored
            Rectangle()
                .fill(shouldBeColored ? color : Color.white)
                .border(Color.ludoGrid, width: 0.5)
            
            // Icons
            switch type {
            case .star:
                Image(systemName: "star") // Outline star as per reference usually, or light grey fill
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(AppConstants.Colors.star)
                    .padding(4)
            case .arrow(let direction):
                arrowIcon(direction)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white) // White arrow on colored background
                    .padding(2)
            case .normal, .colored:
                EmptyView()
            }
        }
        .frame(width: cellSize, height: cellSize)
    }
    
    var shouldBeColored: Bool {
        switch type {
        case .colored, .arrow: return true
        default: return false
        }
    }
    
    func arrowIcon(_ direction: ArrowDirection) -> Image {
        // SF Symbols for turning arrows to match Ludo style
        switch direction {
        case .up: return Image(systemName: "arrow.turn.left.up")
        case .down: return Image(systemName: "arrow.turn.right.down")
        case .left: return Image(systemName: "arrow.turn.up.left")
        case .right: return Image(systemName: "arrow.turn.down.right")
        }
    }
}

// MARK: - Center Home
struct CenterHome: View {
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                // Green (Left)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: w/2, y: h/2))
                    p.addLine(to: CGPoint(x: 0, y: h))
                }.fill(Color.ludoGreen)
                
                // Yellow (Top)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: w/2, y: h/2))
                }.fill(Color.ludoYellow)
                
                // Blue (Right)
                Path { p in
                    p.move(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: w/2, y: h/2))
                }.fill(Color.ludoBlue)
                
                // Red (Bottom)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: w/2, y: h/2))
                }.fill(Color.ludoRed)
            }
        }
        .frame(width: cellSize * 3, height: cellSize * 3)
    }
    
}
