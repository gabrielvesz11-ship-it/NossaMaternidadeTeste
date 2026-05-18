import SwiftUI

struct NossaLuzView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var audioService = AudioService()
    @State private var selectedTrack: AudioService.AudioTrack?
    @State private var timerValue = 300
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    let timerOptions = [60, 300, 600, 900, 1800]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.calmGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    trackList
                    
                    if audioService.isPlaying {
                        playerBar
                    }
                }
            }
            .navigationTitle("Nossa Luz")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        audioService.stop()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.nightText)
                }
            }
        }
        .onDisappear {
            audioService.stop()
            timer?.invalidate()
        }
    }
    
    private var trackList: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                
                ForEach(AudioService.AudioTrack.allCases, id: \.self) { track in
                    TrackCard(
                        track: track,
                        isPlaying: audioService.currentTrack == track && audioService.isPlaying,
                        progress: audioService.currentTrack == track ? audioService.progress : 0,
                        duration: audioService.currentTrack == track ? audioService.duration : 300
                    ) {
                        toggleTrack(track)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryLight.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.primaryLight)
            }
            
            Text("Um momento só seu.")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.nightText)
                .multilineTextAlignment(.center)
            
            Text("Escolha um som. Feche os olhos. Respire.")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.nightText.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }
    
    private var playerBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppColors.nightText.opacity(0.1))
            
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    Button(action: {
                        audioService.isPlaying ? audioService.pause() : resumeCurrent()
                    }) {
                        Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(AppColors.primaryLight)
                    }
                    .accessibilityLabel(audioService.isPlaying ? "Pausar" : "Continuar")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(audioService.currentTrack?.displayName ?? "")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.nightText)
                        
                        ProgressView(value: audioService.progress, total: max(audioService.duration, 1))
                            .tint(AppColors.primaryLight)
                            .scaleEffect(y: 1.5)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        AppHaptics.medium()
                        audioService.stop()
                        timer?.invalidate()
                        isTimerRunning = false
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColors.nightText.opacity(0.5))
                    }
                    .accessibilityLabel("Parar")
                }
                
                timerBar
            }
            .padding(20)
            .background(AppColors.nightSurface.opacity(0.8))
        }
    }
    
    private var timerBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.nightText.opacity(0.5))
            
            ForEach(timerOptions, id: \.self) { seconds in
                Button(action: {
                    AppHaptics.selection()
                    timerValue = seconds
                    startTimer()
                }) {
                    Text(formatTime(seconds))
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .foregroundStyle(timerValue == seconds && isTimerRunning ? AppColors.nightBackground : AppColors.nightText)
                        .background(timerValue == seconds && isTimerRunning ? AppColors.primaryLight : AppColors.nightText.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            
            if isTimerRunning {
                Text(formatTime(timerValue))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AppColors.primaryLight)
                    .frame(width: 50)
            }
        }
    }
    
    private func toggleTrack(_ track: AudioService.AudioTrack) {
        if audioService.currentTrack == track && audioService.isPlaying {
            AppHaptics.medium()
            audioService.pause()
        } else {
            AppHaptics.success()
            audioService.play(track: track)
            startTimer()
        }
    }
    
    private func resumeCurrent() {
        if let track = audioService.currentTrack {
            audioService.play(track: track)
            startTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timer?.invalidate()
                isTimerRunning = false
                audioService.stop()
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        return "\(m)m"
    }
}

struct TrackCard: View {
    let track: AudioService.AudioTrack
    let isPlaying: Bool
    let progress: Double
    let duration: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isPlaying ? AppColors.primary.opacity(0.3) : AppColors.nightText.opacity(0.08))
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: track.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(isPlaying ? AppColors.primaryLight : AppColors.nightText.opacity(0.6))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isPlaying ? AppColors.primaryLight : AppColors.nightText)
                        
                        Text(track.description)
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.nightText.opacity(0.5))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(isPlaying ? AppColors.primaryLight : AppColors.nightText.opacity(0.4))
                }
                
                if isPlaying && duration > 0 {
                    ProgressView(value: progress, total: duration)
                        .tint(AppColors.primaryLight)
                        .scaleEffect(y: 1.2)
                }
            }
            .padding(16)
            .background(AppColors.nightSurface.opacity(0.6))
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isPlaying ? AppColors.primaryLight.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .accessibilityLabel("\(track.displayName). \(track.description)")
        .frame(minHeight: 44)
    }
}
