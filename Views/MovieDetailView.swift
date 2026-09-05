import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.poster_path ?? "")")) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .cornerRadius(20)
                    .padding()
                    
                    Text(movie.title ?? movie.name ?? "")
                        .font(.title)
                        .bold()
                    
                    Text(movie.overview)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    // زر تشغيل الفيديو
                    NavigationLink(destination: PlayerView(videoURL: URL(string: "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cc-us-2018_720x405.mp4")!)) {
                        Text("▶ Play Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}
