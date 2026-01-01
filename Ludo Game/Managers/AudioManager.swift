import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    // Placeholder for actual sound files
    // In a real app, we would load .mp3/.wav files here
    
    func playSound(_ name: String) {
        // Implementation would involve AVAudioPlayer
        // print("Playing sound: \(name)")
    }
    
    func playRoll() {
        playSound("dice_roll")
    }
    
    func playMove() {
        playSound("move_piece")
    }
    
    func playCapture() {
        playSound("capture")
    }
    
    func playWin() {
        playSound("win_fanfare")
    }
}
