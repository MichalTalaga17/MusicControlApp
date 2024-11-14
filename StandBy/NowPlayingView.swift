//
//  MusicControlView.swift
//  StandBy
//
//  Created by Michał Talaga on 14/11/2024.
//

import SwiftUI
import MediaPlayer

struct MusicControlView: View {
    @State private var currentTime: String = ""
    @State private var timer: Timer? = nil
    @State private var isPlaying: Bool = false
    @State private var songTitle: String = "Brak informacji"
    @State private var artistName: String = "Brak informacji"
    @State private var albumArtwork: UIImage? = nil
    @State private var trackDuration: TimeInterval = 0
    @State private var currentPlaybackTime: TimeInterval = 0
    
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            VStack(spacing: 20) {
                Text(currentTime)
                    .font(.largeTitle .bold())
                    .padding()
                
                if let albumImage = albumArtwork {
                    Image(uiImage: albumImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isLandscape ? 150 : 200, height: isLandscape ? 150 : 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 10)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isLandscape ? 150 : 200, height: isLandscape ? 150 : 200)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                
                if isLandscape {
                    // Widok poziomy - układ horyzontalny
                    HStack(spacing: 20) {
                        songInfoView()
                        controlButtonsView()
                    }
                } else {
                    // Widok pionowy - układ wertykalny
                    songInfoView()
                    playbackSlider()
                    controlButtonsView()
                }
            }
            .padding()
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true  // Zapobiega wygaszaniu ekranu
                startTimer()
                updatePlayState()
                updateNowPlayingInfo()
                
                NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer, queue: .main) { _ in
                    updateNowPlayingInfo()
                }
                
                NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer, queue: .main) { _ in
                    updatePlayState()
                }
                
                musicPlayer.beginGeneratingPlaybackNotifications()
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false  // Przywraca domyślne wygaszanie ekranu
                timer?.invalidate()
                musicPlayer.endGeneratingPlaybackNotifications()
            }
        }
    }
    
    // Widok dla informacji o utworze
    private func songInfoView() -> some View {
        VStack {
            Text(songTitle)
                .font(.title2)
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 5)
            
            Text(artistName)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    // Widok dla suwaka czasu odtwarzania
    private func playbackSlider() -> some View {
        VStack {
            Slider(value: $currentPlaybackTime, in: 0...trackDuration)
                .accentColor(.primary)
                .padding(.horizontal)
            
            HStack {
                Text(timeFormatted(currentPlaybackTime))
                    .font(.caption)
                Spacer()
                Text(timeFormatted(trackDuration))
                    .font(.caption)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // Widok dla przycisków sterowania
    private func controlButtonsView() -> some View {
        HStack(spacing: 50) {
            Button(action: {
                musicPlayer.skipToPreviousItem()
            }) {
                Image(systemName: "backward.fill")
                    .resizable()
                    .frame(width: 50, height: 30)
                    .foregroundStyle(Color.primary)
            }
            
            Button(action: {
                togglePlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .foregroundStyle(Color.primary)
            }
            
            Button(action: {
                musicPlayer.skipToNextItem()
            }) {
                Image(systemName: "forward.fill")
                    .resizable()
                    .frame(width: 50, height: 30)
                    .foregroundStyle(Color.primary)
            }
        }
    }
    
    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTime()
            updatePlaybackTime()
        }
    }
    
    private func updateTime() {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        let formattedHour = hour < 10 ? "0\(hour)" : "\(hour)"
        let formattedMinute = minute < 10 ? "0\(minute)" : "\(minute)"
        currentTime = "\(formattedHour):\(formattedMinute)"
    }
    
    private func togglePlayPause() {
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }
    
    private func updatePlayState() {
        isPlaying = musicPlayer.playbackState == .playing
    }
    
    private func updateNowPlayingInfo() {
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            songTitle = nowPlayingItem.title ?? "Nieznany tytuł"
            artistName = nowPlayingItem.artist ?? "Nieznany wykonawca"
            trackDuration = nowPlayingItem.playbackDuration
            
            if let artwork = nowPlayingItem.artwork {
                albumArtwork = artwork.image(at: CGSize(width: 200, height: 200))
            } else {
                albumArtwork = nil
            }
        } else {
            songTitle = "Brak informacji"
            artistName = "Brak informacji"
            trackDuration = 0
            albumArtwork = nil
        }
    }
    
    private func updatePlaybackTime() {
        currentPlaybackTime = musicPlayer.currentPlaybackTime
    }
    
    private func timeFormatted(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MusicControlView_Previews: PreviewProvider {
    static var previews: some View {
        MusicControlView()
    }
}
