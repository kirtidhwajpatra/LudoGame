// Exact Shape matching the provided SVG
import SwiftUI

// Exact Shape matching the provided SVG (Outline Path)
struct TurnArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 27.0
        let sy = rect.height / 33.0
        
        var path = Path()
        
        // 1. Arrow Head
        // M23.9802 32.6797 L26.8887 27.642 L21.0717 27.642 L23.9802 32.6797 Z
        path.move(to: CGPoint(x: 23.9802 * sx, y: 32.6797 * sy))
        path.addLine(to: CGPoint(x: 26.8887 * sx, y: 27.642 * sy))
        path.addLine(to: CGPoint(x: 21.0717 * sx, y: 27.642 * sy))
        path.closeSubpath()
        
        // 2. Left Stem
        // M0.503906 26.7442 L1.00767 26.7442 L1.00767 12.2425 L0.503905 12.2425 L0.000138284 12.2425 L0.000138917 26.7442 L0.503906 26.7442 Z
        // Simplified: Rect from x=0 to 1.007, y=12.24 to 26.74
        path.move(to: CGPoint(x: 0.5039 * sx, y: 26.7442 * sy))
        path.addLine(to: CGPoint(x: 1.0077 * sx, y: 26.7442 * sy))
        path.addLine(to: CGPoint(x: 1.0077 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 0.5039 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 0.0001 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 0.0001 * sx, y: 26.7442 * sy))
        path.closeSubpath()
        
        // 3. Right Stem
        // M23.9802 12.2425 L23.4765 12.2425 L23.4765 28.1458 L23.9802 28.1458 L24.484 28.1458 L24.484 12.2425 L23.9802 12.2425 Z
        path.move(to: CGPoint(x: 23.9802 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 23.4765 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 23.4765 * sx, y: 28.1458 * sy))
        path.addLine(to: CGPoint(x: 23.9802 * sx, y: 28.1458 * sy))
        path.addLine(to: CGPoint(x: 24.484 * sx, y: 28.1458 * sy))
        path.addLine(to: CGPoint(x: 24.484 * sx, y: 12.2425 * sy))
        path.closeSubpath()
        
        // 4. Arch
        // M12.2421 0.504325 L12.2421 1.00809
        // C18.4467 1.00809 23.4765 6.0379 23.4765 12.2425
        // L23.9802 12.2425 L24.484 12.2425
        // C24.484 5.48146 19.0031 0.000556137 12.2421 0.000556433
        // L12.2421 0.504325 Z
        // Also Left side of arch:
        // M0.503905 12.2425 L1.00767 12.2425
        // C1.00767 6.03791 6.03749 1.00809 12.2421 1.00809
        // L12.2421 0.504325 L12.2421 0.000556433
        // C5.48104 0.000556728 0.000137988 5.48147 0.000138284 12.2425
        // L0.503905 12.2425 Z
        // I will combine these into one loop or two halves.
        
        // Right Half Arch
        path.move(to: CGPoint(x: 12.2421 * sx, y: 0.5043 * sy))
        path.addLine(to: CGPoint(x: 12.2421 * sx, y: 1.0081 * sy))
        path.addCurve(to: CGPoint(x: 23.4765 * sx, y: 12.2425 * sy),
                      control1: CGPoint(x: 18.4467 * sx, y: 1.0081 * sy),
                      control2: CGPoint(x: 23.4765 * sx, y: 6.0379 * sy))
        path.addLine(to: CGPoint(x: 23.9802 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 24.484 * sx, y: 12.2425 * sy))
        path.addCurve(to: CGPoint(x: 12.2421 * sx, y: 0.0005 * sy),
                      control1: CGPoint(x: 24.484 * sx, y: 5.4815 * sy),
                      control2: CGPoint(x: 19.0031 * sx, y: 0.0005 * sy))
        path.closeSubpath()
        
        // Left Half Arch
        path.move(to: CGPoint(x: 0.5039 * sx, y: 12.2425 * sy))
        path.addLine(to: CGPoint(x: 1.0077 * sx, y: 12.2425 * sy))
        path.addCurve(to: CGPoint(x: 12.2421 * sx, y: 1.0081 * sy),
                      control1: CGPoint(x: 1.0077 * sx, y: 6.0379 * sy),
                      control2: CGPoint(x: 6.0375 * sx, y: 1.0081 * sy))
        path.addLine(to: CGPoint(x: 12.2421 * sx, y: 0.5043 * sy))
        path.addLine(to: CGPoint(x: 12.2421 * sx, y: 0.0006 * sy))
        path.addCurve(to: CGPoint(x: 0.0001 * sx, y: 12.2425 * sy),
                      control1: CGPoint(x: 5.481 * sx, y: 0.0006 * sy),
                      control2: CGPoint(x: 0.0001 * sx, y: 5.4815 * sy))
        path.closeSubpath()
        
        return path
    }
}

struct TurnArrowView: View {
    let color: Color
    
    var body: some View {
        TurnArrowShape()
            .fill(color) // Now using Fill since Shape defines the area
            .frame(width: 27, height: 33) // Aspect Ratio defaults (will be resized by container)
    }
}
