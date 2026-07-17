import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var matchSound: AVAudioPlayer?
    private var winSound: AVAudioPlayer?
    private var loseSound: AVAudioPlayer?
    
    private init() {
        setupSounds()
    }
    
    private func setupSounds() {
        // Load match sound
        if let matchURL = Bundle.main.url(forResource: "match", withExtension: "wav") {
            matchSound = try? AVAudioPlayer(contentsOf: matchURL)
            matchSound?.prepareToPlay()
        }
        
        // Load win sound
        if let winURL = Bundle.main.url(forResource: "win", withExtension: "wav") {
            winSound = try? AVAudioPlayer(contentsOf: winURL)
            winSound?.prepareToPlay()
        }
        
        // Load lose sound
        if let loseURL = Bundle.main.url(forResource: "lose", withExtension: "wav") {
            loseSound = try? AVAudioPlayer(contentsOf: loseURL)
            loseSound?.prepareToPlay()
        }
    }
    
    func playMatch() {
        matchSound?.play()
    }
    
    func playWin() {
        winSound?.play()
    }
    
    func playLose() {
        loseSound?.play()
    }
}
