# LudoGame

A SwiftUI implementation of the classic Ludo board game. This repository contains game logic, UI, and supporting modules for a local multiplayer Ludo experience, with emphasis on correct rule handling, responsive animations, and a clear separation between UI and game state.

## Overview
LudoGame implements turn-based mechanics, piece movement rules, and player interactions. The project focuses on robust game logic, maintainable architecture, and an incremental path toward AI and online multiplayer features.

## Key features
- Full Ludo rules (turns, dice, safe squares, home entry)
- Local multiplayer on a single device
- Responsive animations and interaction feedback
- MVVM architecture: Views, ViewModels, and Models separated
- Performance-conscious SwiftUI implementation

## Technical architecture
- Client: iOS app built with Swift and SwiftUI
- Architecture: MVVM — Views (SwiftUI) ↔ ViewModels (state & input handling) ↔ Models (game rules, board state)
- Responsibilities:
  - Models: deterministic game rules, move validation, win detection
  - ViewModels: command handling, turn management, AI hooks
  - Views: presentation, animations, input handling

## Tech stack
- Language: Swift (SwiftUI)
- Frameworks: SwiftUI, Combine (where used), native iOS APIs
- Tooling: Xcode; optional Swift Package Manager for dependencies

## High-level folder structure
- /App or /Sources
  - Models/        — game rules, board state, dice, player models
  - ViewModels/    — state management and game flow controllers
  - Views/         — SwiftUI views and animations
  - Services/      — helpers (audio/haptics, persistence, AI engines)
  - Resources/     — asset catalogs, localized strings, configuration
  - Tests/         — unit and integration tests (when present)
- README.md        — this document

(Adjust paths if the repository uses a different layout.)

## How to run
Prerequisites
- macOS with Xcode (recent stable release)
- iOS deployment target configured in project settings

Steps
1. Clone the repository:
   git clone https://github.com/kirtidhwajpatra/LudoGame.git
2. Open the project in Xcode:
   - If using Swift Package Manager: open the .xcodeproj
   - If a workspace is provided: open the .xcworkspace
3. Verify project settings:
   - Select a signing team and valid bundle identifier
   - Confirm deployment target and device availability
4. Build and run:
   - Prefer running on a physical device for accurate haptics and audio behavior
   - Use the simulator for UI verification (note: some device features are limited)
5. Run tests (if present):
   - Product → Test in Xcode or use xcodebuild test

Notes
- If a Package.swift is present, let Xcode resolve packages on open.
- For best animation and haptic fidelity, test on a recent device.

## Status
In development

Current focus:
- Refining game logic edge cases
- Improving animation smoothness
- Enhancing interaction feedback
- Preparing the module for integration into larger apps

## Future improvements
- AI-based single-player mode
- Online multiplayer support
- Game Center integration
- Advanced haptic feedback
- Performance optimizations for low-end devices

## Screenshots
Screenshots and gameplay previews will be added to this file when available.

## Author
Developed by Kirtidhwaj Patra  
iOS Engineer • SwiftUI Developer

## Contribution
Contributions are welcome. Prefer small, focused pull requests that include:
- A clear description of changes
- Unit tests for game rule changes
- Any dependency or configuration updates reflected in the README

License: See LICENSE file in the repository (if present).
