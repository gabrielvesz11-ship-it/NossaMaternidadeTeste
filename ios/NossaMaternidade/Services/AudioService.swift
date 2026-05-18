import Foundation
import AVFoundation

@Observable
final class AudioService {
    private var player: AVAudioPlayer?
    private var timer: Timer?
    var isPlaying = false
    var currentTrack: AudioTrack?
    var progress: Double = 0.0
    var duration: Double = 0.0
    
    enum AudioTrack: String, CaseIterable {
        case breathing = "respiracao"
        case heartbeat = "batimento"
        case lullaby = "ninar"
        case rain = "chuva"
        case ocean = "oceano"
        
        var displayName: String {
            switch self {
            case .breathing: return "Respiração Guiada"
            case .heartbeat: return "Batimento Materno"
            case .lullaby: return "Canção de Ninar"
            case .rain: return "Chuva Suave"
            case .ocean: return "Ondas do Mar"
            }
        }
        
        var icon: String {
            switch self {
            case .breathing: return "wind"
            case .heartbeat: return "heart.fill"
            case .lullaby: return "music.note"
            case .rain: return "cloud.rain.fill"
            case .ocean: return "water.waves"
            }
        }
        
        var description: String {
            switch self {
            case .breathing: return "Respire com calma. Você está segura."
            case .heartbeat: return "O som que seu bebê mais ama."
            case .lullaby: return "Melodia suave para momentos de paz."
            case .rain: return "A chuva lava o dia. Descanse."
            case .ocean: return "O mar traz serenidade. Soltar."
            }
        }
    }
    
    func play(track: AudioTrack) {
        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "mp3")
              ?? generateTone(for: track) else {
            simulatePlayback(for: track)
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
            
            currentTrack = track
            isPlaying = true
            duration = player?.duration ?? 180
            startProgressTimer()
        } catch {
            simulatePlayback(for: track)
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTrack = nil
        progress = 0
        timer?.invalidate()
        timer = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch { }
    }
    
    private func simulatePlayback(for track: AudioTrack) {
        currentTrack = track
        isPlaying = true
        progress = 0
        duration = 300
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 1
            if self.progress >= self.duration {
                self.progress = 0
            }
        }
    }
    
    private func generateTone(for track: AudioTrack) -> URL? {
        return nil
    }
    
    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.progress = player.currentTime
            self.duration = player.duration
        }
    }
    
    deinit {
        timer?.invalidate()
        player?.stop()
    }
}
