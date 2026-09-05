import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @StateObject private var tmdbService = TMDBService()
    @State private var videoURL: URL? = nil
    @State private var isLoadingVideo = false
    @State private var showPlayer = false
    
    var body: some View {
        ZStack {
            // الثيم الأخضر الداكن الفاخر
            Color(red: 0.05, green: 0.18, blue: 0.14)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.poster_path ?? "")")) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 350)
                    .cornerRadius(20)
                    .padding()
                    
                    Text(movie.displayTitle)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(movie.overview)
                        .padding()
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    // زر تشغيل الفيديو عبر الـ API مع دعم الثيم الأخضر
                    Button(action: {
                        isLoadingVideo = true
                        tmdbService.fetchMovieVideo(movieId: movie.id) { url in
                            isLoadingVideo = false
                            if let url = url {
                                self.videoURL = url
                                self.showPlayer = true
                            } else {
                                // رابط احتياطي في حال لم يتوفر فيديو في الـ API
                                self.videoURL = URL(string: "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cc-us-2018_720x405.mp4")
                                self.showPlayer = true
                            }
                        }
                    }) {
                        HStack {
                            if isLoadingVideo {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "play.fill")
                                Text("Play Now")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.2, green: 0.85, blue: 0.5)) // أخضر مضيء
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .disabled(isLoadingVideo)
                }
            }
        }
        .sheet(isPresented: $showPlayer) {
            if let url = videoURL {
                PlayerView(videoURL: url)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
