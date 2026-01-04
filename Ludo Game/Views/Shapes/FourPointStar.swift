import SwiftUI

struct FourPointStar: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let center = CGPoint(x: w / 2, y: h / 2)
        
        // A 4-pointed star (concave square)
        // Tune the 'inset' to match the reference "soft" star look
        // Reference looks like a diamond with curved inward sides
        
        var path = Path()
        
        // Let's use curves for a "Soft" 4-point star
        // Top Point: (w/2, 0)
        // Right Point: (w, h/2)
        // Bottom Point: (w/2, h)
        // Left Point: (0, h/2)
        
        // Control points towards center
        let controlInset = w * 0.15 // Adjust for "fatness" of the star arms
        
        let top = CGPoint(x: w/2, y: 0)
        let right = CGPoint(x: w, y: h/2)
        let bottom = CGPoint(x: w/2, y: h)
        let left = CGPoint(x: 0, y: h/2)
        
        // Center control points
        let centerControl = CGPoint(x: w/2, y: h/2)
        
        path.move(to: top)
        // Curve to Right
        path.addQuadCurve(to: right, control: CGPoint(x: w/2 + controlInset, y: h/2 - controlInset))
        // Curve to Bottom
        path.addQuadCurve(to: bottom, control: CGPoint(x: w/2 + controlInset, y: h/2 + controlInset))
        // Curve to Left
        path.addQuadCurve(to: left, control: CGPoint(x: w/2 - controlInset, y: h/2 + controlInset))
        // Curve to Top
        path.addQuadCurve(to: top, control: CGPoint(x: w/2 - controlInset, y: h/2 - controlInset))
        
        return path
    }
}
