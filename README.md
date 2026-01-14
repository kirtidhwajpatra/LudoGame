# Ludo Game - iOS

![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0%2B-green)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

A premium, local multiplayer Ludo board game built entirely with **SwiftUI**. This project demonstrates modern iOS development practices, including **MVVM architecture**, **complex state management**, **interactive animations**, and **haptic feedback integration**.

## 🌟 Key Features

*   **Complete Game Logic**: Fully functional Ludo rules implementation including turn management, dice rolling mechanics, piece movement, capturing opponents, and safe zones.
*   **Fluid Animations**: Smooth, physics-based spring animations for token movement, dice rolling, and UI transitions.
*   **Haptic Feedback**: Meaningful haptic patterns using `CoreHaptics` (heavy impact on captures, light ticks on movement, success notification on win).
*   **Dynamic UI**: A responsive, vector-based board design that adapts to screen sizes.
*   **Local Multiplayer**: Supports 2-4 players on a single device with visual turn indicators.

## 🏗 Technical Architecture

The application follows a clean **MVVM (Model-View-ViewModel)** architecture to ensure separation of concerns and testability.

### Core Components

*   **Models**: Pure Swift structs (`GameState`, `Player`, `Token`, `BoardPosition`) that encapsulate the rules and state of the game. They are deterministic and unit-testable.
*   **ViewModels**: `LudoGameEngine` acts as the source of truth. It manages the game loop, validates moves, executes logic updates, and publishes changes to the UI using the `ObservableObject` protocol.
*   **Views**: Declarative SwiftUI views (`GameView`, `LudoBoardView`) that reactively render the state. They handle user interactions and trigger intents in the ViewModel.

### Folder Structure

```
Ludo Game/
├── Models/         # Game rules and data structures
├── ViewModels/     # Game logic engine and state management
├── Views/          # SwiftUI views (Board, Tokens, Screens)
├── Utilities/      # Constants, geometry helpers
└── Resources/      # Assets and configuration
```

## 🚀 Getting Started

### Prerequisites

*   macOS running Xcode 13.0 or later.
*   iOS 15.0+ deployment target.

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/kirtidhwajpatra/LudoGame.git
    ```
2.  Open `Ludo Game.xcodeproj` in Xcode.
3.  Select your target simulator or physical device (recommended for haptics).
4.  Press `Cmd + R` to build and run.

## 🔮 Roadmap

*   [ ] **AI Opponent**: Single-player mode with a heuristic-based AI.
*   [ ] **Online Multiplayer**: Real-time play using Game Center or a custom WebSocket backend.
*   [ ] **Themes**: Customizable board skins and token designs.
*   [ ] **Sound Effects**: Spatial audio integration for immersive gameplay.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Developed by Kirtidhwaj Patra**
*iOS Engineer • SwiftUI Specialist*
