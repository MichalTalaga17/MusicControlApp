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
        VStack(spacing: 20) {
            // Wyświetlanie aktualnej godziny
            Text(currentTime)
                .font(.largeTitle)
                .padding()
            
            // Wyświetlanie okładki albumu
            if let albumImage = albumArtwork {
                Image(uiImage: albumImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 10)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            
            // Wyświetlanie aktualnie odtwarzanej piosenki i wykonawcy
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
            
            // Pasek postępu utworu
            Slider(value: $currentPlaybackTime, in: 0...trackDuration)
                .accentColor(.blue)
                .padding(.horizontal)
            
            HStack {
                Text(timeFormatted(currentPlaybackTime))
                    .font(.caption)
                Spacer()
                Text(timeFormatted(trackDuration))
                    .font(.caption)
            }
            .padding(.horizontal, 20)
            
            // Przyciski do kontrolowania muzyki
            HStack(spacing: 50) {
                // Poprzedni utwór
                Button(action: {
                    musicPlayer.skipToPreviousItem()
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
                
                // Odtwarzanie/Wstrzymanie
                Button(action: {
                    togglePlayPause()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                }
                
                // Następny utwór
                Button(action: {
                    musicPlayer.skipToNextItem()
                }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .onAppear {
            startTimer()
            updatePlayState()
            updateNowPlayingInfo()
            
            // Nasłuchiwanie zmian stanu odtwarzacza i informacji o utworze
            NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer, queue: .main) { _ in
                updateNowPlayingInfo()
            }
            
            NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer, queue: .main) { _ in
                updatePlayState()
            }
            
            musicPlayer.beginGeneratingPlaybackNotifications()
        }
        .onDisappear {
            timer?.invalidate()
            musicPlayer.endGeneratingPlaybackNotifications()
        }
    }
    
    // Funkcja do aktualizacji aktualnej godziny co sekundę
    private func startTimer() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTime()
            updatePlaybackTime()
        }
    }
    
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        currentTime = formatter.string(from: Date())
    }
    
    // Funkcja do przełączania między odtwarzaniem a wstrzymaniem
    private func togglePlayPause() {
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }
    
    // Aktualizacja stanu przycisku Play/Pause
    private func updatePlayState() {
        isPlaying = musicPlayer.playbackState == .playing
    }
    
    // Funkcja do pobierania informacji o aktualnie odtwarzanej piosence
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
    
    // Funkcja do aktualizacji aktualnego czasu odtwarzania
    private func updatePlaybackTime() {
        currentPlaybackTime = musicPlayer.currentPlaybackTime
    }
    
    // Funkcja formatowania czasu w formacie mm:ss
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