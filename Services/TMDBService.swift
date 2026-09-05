import Foundation

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []              // من trending (فيه movie + tv مع بعض)
    @Published var searchResults: [Movie] = []
    @Published var moviesByGenre: [String: [Movie]] = [:]
    
    let apiKey = "12bae60f08973cb30c741d0844769d9d"
    let baseURL = "https://api.themoviedb.org/3"
    
    // التصنيفات اللي بدك تعرضها كأقسام
    let genreSections: [(name: String, id: Int)] = [
        ("أكشن", 28),
        ("دراما", 18),
        ("مغامرات", 12),
        ("كوميدي", 35),
        ("رعب", 27)
    ]
    
    func fetchTrending() {
        guard let url = URL(string: "\(baseURL)/trending/all/day?api_key=\(apiKey)&language=ar") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decodedResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.movies = decodedResponse.results
                }
            }
        }.resume()
    }
    
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            DispatchQueue.main.async { self.searchResults = [] }
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/search/multi?api_key=\(apiKey)&language=ar&query=\(encodedQuery)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let decodedResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.searchResults = decodedResponse.results
                }
            }
        }.resume()
    }
    
    // يجيب أفلام + مسلسلات لتصنيف معين ويخزنهم باسم القسم
    func fetchByGenre(genreId: Int, name: String) {
        guard let movieURL = URL(string: "\(baseURL)/discover/movie?api_key=\(apiKey)&language=ar&with_genres=\(genreId)"),
              let tvURL = URL(string: "\(baseURL)/discover/tv?api_key=\(apiKey)&language=ar&with_genres=\(genreId)") else { return }
        
        var combinedResults: [Movie] = []
        let group = DispatchGroup()
        
        group.enter()
        URLSession.shared.dataTask(with: movieURL) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                combinedResults.append(contentsOf: decoded.results)
            }
            group.leave()
        }.resume()
        
        group.enter()
        URLSession.shared.dataTask(with: tvURL) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                combinedResults.append(contentsOf: decoded.results)
            }
            group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            self.moviesByGenre[name] = combinedResults
        }
    }
    
    // يجيب كل الأقسام دفعة وحدة
    func fetchAllSections() {
        fetchTrending()
        for genre in genreSections {
            fetchByGenre(genreId: genre.id, name: genre.name)
        }
    }
}
