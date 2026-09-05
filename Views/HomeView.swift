import SwiftUI

struct HomeView: View {
    @StateObject var tmdbService = TMDBService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.95).edgesIgnoringSafeArea(.all) // لون أبيض غامق
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // الهيدر والبحث
                        HStack {
                            Image(systemName: "flame.fill").font(.title)
                            Text("Strofy").font(.title2).bold()
                            Spacer()
                            Image(systemName: "magnifyingglass").font(.title2)
                        }
                        .padding(.horizontal)
                        
                        // التصنيفات
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                CategoryButton(title: "Most Watched", isSelected: true)
                                CategoryButton(title: "For Kids", isSelected: false)
                                CategoryButton(title: "Family", isSelected: false)
                            }
                            .padding(.horizontal)
                        }
                        
                        // قسم الأفلام
                        Text("Movies").font(.headline).padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(tmdbService.movies) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        MovieCard(movie: movie)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 120) // مساحة للبار السفلي الزجاجي
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            tmdbService.fetchTrending()
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        Text(title)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color.black : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
    }
}

struct MovieCard: View {
    let movie: Movie
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // هنا يتم جلب صورة البوستر من API
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.poster_path ?? "")")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 160, height: 240)
            .cornerRadius(20)
            
            VStack(alignment: .leading) {
                Text(movie.title ?? movie.name ?? "بدون اسم")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    Text(String(format: "%.1f", movie.vote_average))
                        .font(.caption)
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                }
                .foregroundColor(.white)
            }
            .padding()
            .frame(width: 160, alignment: .leading)
            .background(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(20)
        }
    }
}
