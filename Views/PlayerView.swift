import SwiftUI
import AVKit

struct PlayerView: View {
    let videoURL: URL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        CustomAVPlayerView(videoURL: videoURL, dismissAction: {
            presentationMode.wrappedValue.dismiss()
        })
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
}

// بناء هيكل مخصص لربط AVPlayerViewController مع SwiftUI ودعم الشاشة الكاملة
struct CustomAVPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    let dismissAction: () -> Void
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        controller.player = player
        
        // السماح بتشغيل الفيديو بملء الشاشة وتحكم كامل
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        
        // بدء التشغيل تلقائياً
        player.play()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
