import SwiftUI

// شاشة اختبار بسيطة ومستقلة: تجيب أفلام حقيقية من Internet Archive
// وتشغلها مباشرة عند الضغط عليها. لا تحتاج أي API key.
struct ArchiveTestView: View {
    @StateObject private var archiveService = ArchiveService()
    @State private var searchText = ""
    @State private var selectedVideoURL: URL? = nil
    @State private var showPlayer = false
    @State private var loadingId: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        TextField("ابحث عن فيلم (Public Domain)...", text: $searchText)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .onSubmit {
                                archiveService.fetchMovies(query: searchText)
                            }
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding()

                    if archiveService.isLoading {
                        Spacer()
                        ProgressView().tint(.white)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(archiveService.movies) { movie in
                                    ArchiveMovieCard(
                                        movie: movie,
                                        isLoading: loadingId == movie.id,
                                        onTap: { play(movie) }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("اختبار Archive.org")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            archiveService.fetchMovies()
        }
        .fullScreenCover(isPresented: $showPlayer) {
            if let url = selectedVideoURL {
                PlayerView(videoURL: url)
            }
        }
    }

    private func play(_ movie: ArchiveMovie) {
        loadingId = movie.id
        archiveService.fetchVideoURL(identifier: movie.identifier) { url in
            loadingId = nil
            guard let url = url else { return }
            selectedVideoURL = url
            showPlayer = true
        }
    }
}

struct ArchiveMovieCard: View {
    let movie: ArchiveMovie
    let isLoading: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: movie.thumbnailURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(16)

                if isLoading {
                    Color.black.opacity(0.5)
                        .frame(height: 200)
                        .cornerRadius(16)
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }

                Text(movie.displayTitle)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                    .cornerRadius(16)
            }
        }
    }
}
