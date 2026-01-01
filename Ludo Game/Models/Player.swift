import SwiftUI

enum Player: Int, CaseIterable, Identifiable {
    case green = 0
    case yellow = 1
    case blue = 2
    case red = 3
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        case .red: return "Red"
        }
    }
    
    var color: Color {
        switch self {
        case .green: return AppConstants.Colors.green
        case .yellow: return AppConstants.Colors.yellow
        case .blue: return AppConstants.Colors.blue
        case .red: return AppConstants.Colors.red
        }
    }
}
