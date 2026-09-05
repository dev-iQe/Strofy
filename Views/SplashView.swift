import SwiftUI
import AVKit

struct SplashView: View {
    @State private var isActive = false
    let player = AVPlayer(url: Bundle.main.url(forResource: "video", withExtension: "mov")!)

    var body: some View {
        if isActive {
            MainTabView()
        } else {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                FullScreenVideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
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

// مشغل فيديو يملأ الشاشة بالكامل بدون حواف
struct FullScreenVideoPlayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(player: player)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
