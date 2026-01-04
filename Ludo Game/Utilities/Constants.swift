import SwiftUI

struct AppConstants {
    struct Colors {
        // Main Background
        static let background = Color(hex: "4A2388") // Deep Purple
        static let offWhite = Color(hex: "F5F5F7")
        
        // Player Colors
        static let green = Color(hex: "4CD964") // Vibrant Green
        static let yellow = Color(hex: "FFCC00") // Vibrant Yellow
        static let blue = Color(hex: "007AFF") // Vibrant Blue
        static let red = Color(hex: "FF3B30") // Vibrant Red
        
        // UI Elements
        static let boardBackground = Color.white
        static let boardGrid = Color.black.opacity(0.1)
        static let shadow = Color.black.opacity(0.2)
        static let arrow = Color.gray.opacity(0.6)
        static let star = Color.gray.opacity(0.6)
    }
    
    struct Dimensions {
        static let boardPadding: CGFloat = 20
        static let tokenSize: CGFloat = 30 // Approximate, will be dynamic
        static let cornerRadius: CGFloat = 16
    }
}
