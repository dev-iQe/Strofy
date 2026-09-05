import Foundation

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchResults: [Movie] = []
    
    // مفتاح API الخاص بك من الصورة
    let apiKey = "12bae60f08973cb30c741d0844769d9d"
    let baseURL = "https://api.themoviedb.org/3"
    
    func fetchTrending() {
        guard let url = URL(string: "\(baseURL)/trending/all/day?api_key=\(apiKey)&language=ar") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.movies = decodedResponse.results
                    }
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
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.searchResults = decodedResponse.results
                    }
                }
            }
        }.resume()
    }
    
    // يجيب أفلام + مسلسلات بنفس التصنيف ويدمجهم بقائمة وحدة
    func fetchByGenre(genreId: Int) {
        guard let movieURL = URL(string: "\(baseURL)/discover/movie?api_key=\(apiKey)&language=ar&with_genres=\(genreId)"),
              let tvURL = URL(string: "\(baseURL)/discover/tv?api_key=\(apiKey)&language=ar&with_genres=\(genreId)") else { return }
        
        var combinedResults: [Movie] = []
        let group = DispatchGroup()
        
        group.enter()
        URLSession.shared.dataTask(with: movieURL) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                combinedResults.append(contentsOf: decoded.results)
            }
            group.leave()
        }.resume()
        
        group.enter()
        URLSession.shared.dataTask(with: tvURL) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                combinedResults.append(contentsOf: decoded.results)
            }
            group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            self.movies = combinedResults
        }
    }
}

// Models/Movie.swift
struct MovieResponse: Codable { let results: [Movie] }
struct Movie: Codable, Identifiable {
    let id: Int
    let title: String?
    let name: String? // للمسلسلات
    let overview: String
    let poster_path: String?
    let vote_average: Double
}
