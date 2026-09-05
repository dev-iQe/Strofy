import SwiftUI
import AVKit

struct SplashView: View {
    @State private var isActive = false
    // اسم ملف الفيديو الذي سترفعه "video.mov"
    let player = AVPlayer(url: Bundle.main.url(forResource: "video", withExtension: "mov")!)
    
    var body: some View {
        if isActive {
            MainTabView()
        } else {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.95).edgesIgnoringSafeArea(.all) // أبيض غامق
                VideoPlayer(player: player)
                    .disabled(true)
                    .onAppear {
                        player.play()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation { self.isActive = true }
                        }
                    }
            }
        }
    }
}
