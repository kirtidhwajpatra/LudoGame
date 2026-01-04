import SwiftUI

struct DiceView: View {
    let diceValue: Int?
    let isRolling: Bool
    let color: Color
    let onTap: () -> Void
    
    // Internal Animation State
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var shadowY: CGFloat = 5
    @State private var isHovering: Bool = false
    
    var canRoll: Bool {
        return diceValue == nil && !isRolling
    }
    
    var body: some View {
        Button(action: {
            animateTap()
            onTap()
        }) {
            ZStack {
                // Background Glow (Anticipatory)
                if canRoll {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 110, height: 110)
                        .scaleEffect(isHovering ? 1.1 : 1.0)
                        .opacity(isHovering ? 0.6 : 0.3)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isHovering)
                }
                
                // Button Container
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: shadowY)
                
                // Dice Face (3D Cube Face)
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Group {
                            if let value = diceValue {
                                DiceDotsView(value: value)
                            } else {
                                Image(systemName: "die.face.6.fill")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.title)
                            }
                        }
                    )
                    .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(scale)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Remove default fade
        .onChange(of: isRolling) { rolling in
            if rolling {
                // 3D Tumble
                withAnimation(.linear(duration: 0.2).repeatForever(autoreverses: false)) {
                    rotationX += 360
                    rotationY += 720 // Faster Y spin
                }
            } else {
                // Determine face up rotation (reset)
                // We want a Hard Snap
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    rotationX = 0
                    rotationY = 0
                    scale = 1.0
                }
            }
        }
        .onAppear {
            if canRoll { isHovering = true }
        }
        .onChange(of: canRoll) { can in
            isHovering = can
        }
    }
    
    private func animateTap() {
        // Press down
        withAnimation(.easeOut(duration: 0.1)) {
            scale = 0.8
            shadowY = 2
        }
        // Spring up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                shadowY = 5
            }
        }
    }
}

struct DiceDotsView: View {
    let value: Int
    
    var body: some View {
        // Simple text for now, or custom dot drawing
        // Design shows 4 dots for 4 (image).
        Image(systemName: "die.face.\(value).fill")
            .resizable()
            .foregroundColor(.white)
            .padding(4)
    }
}

#Preview{
    DiceView(diceValue: 4, isRolling: true, color: .red) {
        print("Dice tapped")
    }
}
