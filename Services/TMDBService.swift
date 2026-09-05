import Foundation

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    
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
