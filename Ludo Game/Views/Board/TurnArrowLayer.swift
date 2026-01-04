import SwiftUI

struct TurnArrowLayer: View {
    let cellSize: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            // Arrow Size Calculation:
            // SVG Legs are at x=0 and x=24 (Width 27).
            // We want Legs to land on Cell Centers (Distance 1.0 cellSize).
            // Scale = 1.0 / (24/27) = 1.125.
            // Width = 1.125 * cellSize.
            // Aspect Ratio 33/27 = 1.22.
            // Height = 1.125 * 1.22 = 1.375 * cellSize.
            
            let w = cellSize * 1.13
            let h = cellSize * 1.38
            let off = cellSize * 0.06
            
            // 1. Green Turn (Left)
            // Vertical Bridge (0,6)-(0,7). Flow Right.
            arrow()
                .frame(width: w, height: h)
                .rotationEffect(.degrees(-90))
                .position(x: cellSize * 0.5, y: cellSize * 7.0 - off)
            
            // 2. Yellow Turn (Top)
            // Horizontal Bridge (6,0)-(7,0). Flow Down.
            arrow()
                .frame(width: w, height: h)
                .rotationEffect(.degrees(0))
                .position(x: cellSize * 7.0 - off, y: cellSize * 0.5)
            
            // 3. Blue Turn (Right)
            // Vertical Bridge (14,8)-(14,7). Flow Left.
            arrow()
                .frame(width: w, height: h)
                .rotationEffect(.degrees(90))
                .position(x: cellSize * 14.5, y: cellSize * 8.0 + off)
            
            // 4. Red Turn (Bottom)
            // Horizontal Bridge (8,14)-(7,14). Flow Up.
            arrow()
                .frame(width: w, height: h)
                .rotationEffect(.degrees(180))
                .position(x: cellSize * 8.0 + off, y: cellSize * 14.5)
            
        }
    }
    
    func arrow() -> some View {
        TurnArrowView(color: .black)
    }
}
