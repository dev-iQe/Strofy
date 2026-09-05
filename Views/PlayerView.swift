import SwiftUI
import AVKit

struct PlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            }
        }
        .onAppear {
            self.player = AVPlayer(url: videoURL)
            // إعدادات لدعم الـ PiP (صورة في صورة)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to setup audio session.")
            }
        }
    }
}
