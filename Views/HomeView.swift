import SwiftUI

struct HomeView: View {
    @StateObject var tmdbService = TMDBService()
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.18, blue: 0.14)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // الهيدر
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.title)
                                .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.5))
                            Text("Strofy")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            
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
                        
                        // حقل البحث
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
                        
                        // لو في بحث فعّال، اعرض نتائج البحث بس
                        if !searchText.isEmpty {
                            MovieSectionRow(title: "نتائج البحث", movies: tmdbService.searchResults)
                        } else {
                            MovieSectionRow(
                                title: "أفلام",
                                movies: tmdbService.movies.filter { $0.media_type == "movie" }
                            )
                            
                            MovieSectionRow(
                                title: "مسلسلات",
                                movies: tmdbService.movies.filter { $0.media_type == "tv" }
                            )
                            
                            ForEach(tmdbService.genreSections, id: \.name) { genre in
                                if let genreMovies = tmdbService.moviesByGenre[genre.name], !genreMovies.isEmpty {
                                    MovieSectionRow(title: genre.name, movies: genreMovies)
                                }
                            }
                        }
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            tmdbService.fetchAllSections()
        }
    }
}

struct MovieSectionRow: View {
    let title: String
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieCard(movie: movie)
                        }
                    }
                }
                .padding(.horizontal)
            }
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.displayTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if !movie.year.isEmpty {
                        Text(movie.year)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    HStack(spacing: 3) {
                        Text("IMDb")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                        Text(String(format: "%.1f", movie.vote_average))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.yellow)
                    .cornerRadius(4)
                }
            }
            .padding()
            .frame(width: 160, alignment: .leading)
            .background(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(20)
        }
    }
}
