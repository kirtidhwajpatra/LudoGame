import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<50) { i in
                    ConfettiParticle(
                        width: geo.size.width,
                        height: geo.size.height,
                        delay: Double.random(in: 0.0...2.0)
                    )
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ConfettiParticle: View {
    let width: CGFloat
    let height: CGFloat
    let delay: Double
    
    @State private var xStart: CGFloat = 0.0
    @State private var yStart: CGFloat = -20.0
    @State private var yEnd: CGFloat = 0.0
    @State private var rotation: Double = 0.0
    
    let color: Color = [Color.red, .blue, .green, .yellow, .purple, .gold].randomElement()!
    let size: CGFloat = CGFloat.random(in: 6...12)
    
    var body: some View {
        Circle() // Or RoundedRectangle
            .fill(color)
            .frame(width: size, height: size)
            .position(x: xStart, y: yStart)
            .opacity(0.8)
            .onAppear {
                xStart = CGFloat.random(in: 0...width)
                // Start slightly above screen
                yEnd = height + 100
                
                withAnimation(
                    .linear(duration: Double.random(in: 3.0...5.0))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    yStart = yEnd
                    rotation += 360
                }
                
                // Swaying
                // Need complex animation for sway? 
                // Simple falling is fine for "calm premium".
                // Maybe keyframes for sway if iOS 17?
                // Stick to simple linear drop for now to avoid complexity errors.
            }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
