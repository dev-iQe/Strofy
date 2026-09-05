import SwiftUI

struct HomeView: View {
    @StateObject var tmdbService = TMDBService()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory = "Most Watched"
    
    var body: some View {
        NavigationView {
            ZStack {
                // الخلفية بالثيم الأخضر الداكن الفاخر
                Color(red: 0.05, green: 0.18, blue: 0.14)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // الهيدر والبحث التفاعلي
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.title)
                                .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.5))
                            Text("Strofy")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            
                            // زر البحث الذي يفتح خانة الإدخال
                            Button(action: {
                                withAnimation(.spring()) {
                                    isSearching.toggle()
                                    if !isSearching {
                                        searchText = ""
                                        tmdbService.searchResults = []
                                    }
                                }
                            }) {
                                Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        // حقل البحث الفعال
                        if isSearching {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.6))
                                TextField("ابحث عن فيلم أو مسلسل...", text: $searchText)
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .onChange(of: searchText) { newValue in
                                        tmdbService.searchMovies(query: newValue)
                                    }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // التصنيفات (متناسقة مع الثيم الأخضر)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                CategoryButton(title: "Most Watched", isSelected: selectedCategory == "Most Watched") {
                                    selectedCategory = "Most Watched"
                                    tmdbService.fetchTrending()
                                }
                                CategoryButton(title: "For Kids", isSelected: selectedCategory == "For Kids") {
                                    selectedCategory = "For Kids"
                                    tmdbService.fetchByGenre(genreId: 16) // أفلام أنيميشن/أطفال
                                }
                                CategoryButton(title: "Family", isSelected: selectedCategory == "Family") {
                                    selectedCategory = "Family"
                                    tmdbService.fetchByGenre(genreId: 10751) // عائلي
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // قسم الأفلام
                        Text(searchText.isEmpty ? "Movies" : "نتائج البحث")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                let displayedMovies = searchText.isEmpty ? tmdbService.movies : tmdbService.searchResults
                                
                                ForEach(displayedMovies) { movie in
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color(red: 0.2, green: 0.85, blue: 0.5) : Color.white.opacity(0.1))
                .foregroundColor(isSelected ? .black : .white)
                .cornerRadius(20)
        }
    }
}

struct MovieCard: View {
    let movie: Movie
    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
