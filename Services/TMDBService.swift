class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchResults: [Movie] = []
    
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
}
