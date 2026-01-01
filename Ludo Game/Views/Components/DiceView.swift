import SwiftUI

struct DiceView: View {
    let diceValue: Int?
    let isRolling: Bool
    let color: Color
    let onTap: () -> Void
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            animateTap()
            onTap()
        }) {
            ZStack {
                // Background Glow
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isRolling ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRolling)
                
                // Button Container
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                
                // Dice Face (Square inside circle as per design)
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .overlay(
                        Group {
                            if let value = diceValue {
                                DiceDotsView(value: value)
                            } else {
                                // Default state or "Roll" icon
                                Image(systemName: "die.face.6.fill") // Placeholder
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                        }
                    )
            }
        }
        .onChange(of: isRolling) { rolling in
            if rolling {
                withAnimation(.linear(duration: 0.2).repeatForever(autoreverses: false)) {
                   rotation += 360
                }
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    rotation = 0 // Reset or settle
                    scale = 1.0
                }
            }
        }
    }
    
    private func animateTap() {
        withAnimation(.easeOut(duration: 0.1)) {
            scale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                scale = 1.0
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
