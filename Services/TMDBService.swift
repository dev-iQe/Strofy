import Foundation

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var moviesByGenre: [String: [Movie]] = [:]
    
    let apiKey = "12bae60f08973cb30c741d0844769d9d"
    let baseURL = "https://api.themoviedb.org/3"
    
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
    
    func fetchAllSections() {
        fetchTrending()
        for genre in genreSections {
            fetchByGenre(genreId: genre.id, name: genre.name)
        }
    }
    
    // دالة جديدة تم إضافتها لجلب رابط فيديو العرض الترويجي (Trailer) لتشغيله في PlayerView
    func fetchMovieVideo(movieId: Int, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/\(movieId)/videos?api_key=\(apiKey)") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(VideoResponse.self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            if let video = decoded.results.first(where: { $0.type == "Trailer" && $0.site == "YouTube" }) {
                let youtubeURL = URL(string: "https://www.youtube.com/watch?v=\(video.key)")
                DispatchQueue.main.async { completion(youtubeURL) }
            } else if let firstVideo = decoded.results.first(where: { $0.site == "YouTube" }) {
                let youtubeURL = URL(string: "https://www.youtube.com/watch?v=\(firstVideo.key)")
                DispatchQueue.main.async { completion(youtubeURL) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}

struct MovieResponse: Codable { let results: [Movie] }

struct VideoResponse: Codable { let results: [VideoResult] }

struct VideoResult: Codable {
    let key: String
    let site: String
    let type: String
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String
    let poster_path: String?
    let vote_average: Double
    let release_date: String?
    let first_air_date: String?
    let media_type: String?
    
    var year: String {
        let date = release_date ?? first_air_date ?? ""
        return date.count >= 4 ? String(date.prefix(4)) : ""
    }
    
    var displayTitle: String {
        title ?? name ?? "بدون اسم"
    }
}
