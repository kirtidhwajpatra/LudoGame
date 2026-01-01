import SwiftUI

struct LoadingView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color(hex: "FFFFFF") // Pure white as per design
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // App Icon / Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(AppConstants.Colors.background)
                        .frame(width: 120, height: 120)
                        .shadow(color: AppConstants.Colors.background.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Text("LUDO")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: 45) // Basic positioning
                    
                    // "New" Badge
                    Text("New")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "CCFF00")) // Neon yellow-green
                        .clipShape(Capsule())
                        .offset(x: 40, y: -40)
                }
                .scaleEffect(scale)
                
                Text("Loading...")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scale = 1.05
                opacity = 1.0
            }
            
            HapticsManager.shared.playLightImpact()
        }
    }
}
