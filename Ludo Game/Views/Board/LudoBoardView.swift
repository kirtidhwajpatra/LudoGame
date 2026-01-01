import SwiftUI

// MARK: - 1. Color Palette Extension
// Matches the specific flat design colors from your Figma reference
extension Color {
    static let ludoGreen = Color(red: 100/255, green: 196/255, blue: 86/255)   // #64C456
    static let ludoYellow = Color(red: 242/255, green: 222/255, blue: 74/255)  // #F2DE4A
    static let ludoBlue = Color(red: 46/255, green: 108/255, blue: 209/255)    // #2E6CD1
    static let ludoRed = Color(red: 235/255, green: 94/255, blue: 71/255)      // #EB5E47
    static let ludoGrid = Color.gray.opacity(0.3)
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
                BoardGridLayer(cellSize: cellSize)
                
                // Layer 2: Tokens
                // (Using your existing logic for tokens)
                ForEach(gameEngine.state.tokens) { token in
                    LudoTokenView(token: token, cellSize: cellSize)
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
            .background(Color.white)
            // Optional: Shadow and Corner Radius for the whole board card
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }

    // Helper to map BoardPosition to CGPoint on the 15x15 grid
    func position(for token: Token, cellSize: CGFloat) -> CGPoint {
        let (x,y): (Int, Int)
        
        switch token.position {
        case .yard:
            // Using ID hash or index in list to determine slot 0-3.
            let playerTokens = gameEngine.state.tokens.filter { $0.player == token.player }
            let slot = playerTokens.firstIndex(where: { $0.id == token.id }) ?? 0
            (x, y) = LudoBoardGeometry.getYardCoordinate(player: token.player, slot: slot)
            
        case .track, .homePath, .home:
            (x, y) = LudoBoardGeometry.getCoordinate(for: token.position, player: token.player)
        }
        
        // Convert Grid (0-14, 0-14) to Points. 0,0 is Top Left.
        return CGPoint(
            x: CGFloat(x) * cellSize + cellSize / 2,
            y: CGFloat(y) * cellSize + cellSize / 2
        )
    }
}

// MARK: - 4. Board Grid Components

struct BoardGridLayer: View {
    let cellSize: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section
            HStack(spacing: 0) {
                CornerYard(color: .ludoGreen, cellSize: cellSize)
                VerticalTrack(playerColor: .ludoYellow, cellSize: cellSize, isTop: true)
                CornerYard(color: .ludoYellow, cellSize: cellSize)
            }
            
            // Middle Section
            HStack(spacing: 0) {
                HorizontalTrack(playerColor: .ludoGreen, cellSize: cellSize, isLeft: true)
                CenterHome(cellSize: cellSize)
                HorizontalTrack(playerColor: .ludoBlue, cellSize: cellSize, isLeft: false)
            }
            
            // Bottom Section
            HStack(spacing: 0) {
                CornerYard(color: .ludoRed, cellSize: cellSize)
                VerticalTrack(playerColor: .ludoRed, cellSize: cellSize, isTop: false)
                CornerYard(color: .ludoBlue, cellSize: cellSize)
            }
        }
        .border(Color.black.opacity(0.1), width: 1)
    }
}

// MARK: - Corner Yard (Refined)
struct CornerYard: View {
    let color: Color
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            // Base Color
            Rectangle().fill(color)
            
            // White Container (The "Yard" area)
            RoundedRectangle(cornerRadius: cellSize)
                .fill(Color.white)
                .padding(cellSize * 0.8)
            
            // The 4 Token Placeholders
            // Arranged in a 2x2 grid
            VStack(spacing: cellSize * 0.8) {
                HStack(spacing: cellSize * 0.8) {
                    TokenPlaceholder(color: color, size: cellSize)
                    TokenPlaceholder(color: color, size: cellSize)
                }
                HStack(spacing: cellSize * 0.8) {
                    TokenPlaceholder(color: color, size: cellSize)
                    TokenPlaceholder(color: color, size: cellSize)
                }
            }
        }
        .frame(width: cellSize * 6, height: cellSize * 6)
    }
}

struct TokenPlaceholder: View {
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3)) // Lighter shade for empty slot
            .frame(width: size * 1.0, height: size * 1.0)
            .overlay(
                Circle().stroke(color, lineWidth: 2)
            )
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
            if col == 2 && row == 1 { return .arrow(direction: .down) } // Start
            if col == 0 && row == 2 { return .star } // Safe
        } else {
            // Bottom Track (Red)
            if col == 1 && row < 5 { return .colored }
            if col == 0 && row == 4 { return .arrow(direction: .up) } // Start
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
            if row == 0 && col == 1 { return .arrow(direction: .right) } // Start
            if row == 2 && col == 2 { return .star } // Safe
        } else {
            // Right Track (Blue)
            if row == 1 && col < 5 { return .colored }
            if row == 2 && col == 4 { return .arrow(direction: .left) } // Start
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
            Rectangle()
                .fill(type == .colored ? color : Color.white)
                .border(Color.ludoGrid, width: 0.5)
            
            // Icons
            switch type {
            case .star:
                Image(systemName: "star.fill") // filled star is more visible
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.gray.opacity(0.4))
                    .padding(4)
            case .arrow(let direction):
                arrowIcon(direction)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color)
                    .padding(2)
            case .normal, .colored:
                EmptyView()
            }
        }
        .frame(width: cellSize, height: cellSize)
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
