import SwiftUI

struct LudoTokenView: View {
    let token: Token
    let cellSize: CGFloat
    var isMovable: Bool = false
    var shouldDim: Bool = false
    var isCaptured: Bool = false // Emotional Cues: captured state
    
    @State private var isBreathing = false
    
    // Impact Animation State
    @State private var impactScale: CGFloat = 1.0
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 0.0
    
    // Call-To-Action State
    @State private var ctaScale: CGFloat = 1.0
    @State private var ctaOpacity: Double = 0.5
    
    // Victory Celebration State
    var isWinner: Bool = false
    @State private var celebrationRotation: Double = 0
    @State private var celebrationJump: CGFloat = 0
    
    // Progress Calculation for "Excitement"
    var progress: Double {
        switch token.position {
        case .yard: return 0.0
        case .home: return 1.0
        case .homePath(let index):
            // 52 track steps + index. Max ~57.
            // 52 + 0..5 = 52..57.
            return Double(52 + index) / 57.0
        case .track(let index):
            // Calculate relative progress (0.0 to ~0.9)
            let offset: Int
            switch token.player {
            case .green: offset = 0
            case .yellow: offset = 13
            case .blue: offset = 26
            case .red: offset = 39
            }
            let rel = (index - offset + 52) % 52
            return Double(rel) / 57.0
        }
    }
    
    var body: some View {
        ZStack {
            // 0. Active Player Glow (Call to Action)
            if isMovable {
                Circle()
                    .fill(token.player.color)
                    .frame(width: cellSize * 1.2, height: cellSize * 1.2)
                    .blur(radius: 4)
                    .scaleEffect(ctaScale)
                    .opacity(ctaOpacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            ctaScale = 1.3
                            ctaOpacity = 0.8
                        }
                    }
            }
            
            // Home Stretch Excitement Glow
            if progress > 0.85 && !token.hasCompleted {
                Circle()
                    .fill(Color.white)
                    .frame(width: cellSize * 1.0, height: cellSize * 1.0)
                    .blur(radius: 5)
                    .opacity(isBreathing ? 0.6 : 0.2)
            }
            
            // Ripple Effect (Behind)
            Circle()
                .stroke(token.player.color.opacity(0.8), lineWidth: 3)
                .frame(width: cellSize, height: cellSize)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)
            
            // Pure Emoji Design (Clean, No Background)
            // Dynamic Sizing based on location
            let isYard = (token.position == .yard)
            let scale: CGFloat = isYard ? 1.5 : 1.1
            
            Text(emoji(for: token.player))
                .font(.system(size: cellSize * scale))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2) // Subtle lift
                // Micro-interactions (Breathing & Tiny Rotation) + Impact Pulse
                // Excitement: Breathe deeper/faster if near home
                .scaleEffect(impactScale * (isBreathing ? (progress > 0.85 ? 1.1 : 1.03) : 1.0))
                .rotationEffect(.degrees((isBreathing ? (progress > 0.85 ? 3 : 1) : -1) + celebrationRotation))
                // Bounce if movable (Active "Pick Me") OR Celebration Jump
                .offset(y: (isMovable ? -self.cellSize * 0.1 : 0) + celebrationJump)
                .animation(isMovable ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isMovable)
                // Captured: Desaturate ("Drain")
                .saturation(isCaptured ? 0.0 : 1.0)
                .scaleEffect(isCaptured ? 0.8 : 1.0)
                .animation(.linear(duration: 0.2), value: isCaptured)
            
            // Minimal Status Indicator
            if token.hasCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .background(Circle().fill(Color.white))
                    .font(.system(size: cellSize * 0.3))
                    .offset(x: cellSize * 0.3, y: -cellSize * 0.3)
            }
        }
        .opacity(shouldDim ? 0.4 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: shouldDim)
        .onChange(of: token.position) { _ in
            triggerImpact()
        }
        .onAppear {
            // Desynchronize animations to prevent "robot army" effect
            let randomDelay = Double.random(in: 0.0...1.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                // Excitement: Faster breathing
                let duration = (progress > 0.85) ? 1.0 : 2.5
                withAnimation(
                    .easeInOut(duration: duration) // Fast if excited
                    .repeatForever(autoreverses: true)
                ) {
                    isBreathing = true
                }
                
                if isWinner {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        celebrationRotation = 360
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                        celebrationJump = -10
                    }
                }
            }
        }
    }
    
    func triggerImpact() {
        // 1. Impact Scale Pulse (Snap)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            impactScale = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                impactScale = 1.0
            }
        }
        
        // 2. Ripple Emission
        rippleScale = 0.5
        rippleOpacity = 0.6
        withAnimation(.easeOut(duration: 0.5)) {
            rippleScale = 1.5
            rippleOpacity = 0.0
        }
    }
    
    func emoji(for player: Player) -> String {
        switch player {
        case .green: return "🐸"
        case .yellow: return "🐥"
        case .blue: return "🐬"
        case .red: return "🦀"
        }
    }
        // Selection Pulse logic could go here
    
}
