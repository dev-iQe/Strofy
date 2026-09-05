import Foundation

// خدمة بسيطة لجلب أفلام حقيقية (ملكية عامة) من Internet Archive
// وتشغيلها مباشرة، بدون الحاجة لأي API key.
class ArchiveService: ObservableObject {
    @Published var movies: [ArchiveMovie] = []
    @Published var isLoading = false

    private let baseURL = "https://archive.org"

    // البحث عن أفلام داخل قسم "feature_films" (أفلام كاملة ملكية عامة)
    func fetchMovies(query: String = "", rows: Int = 30) {
        isLoading = true

        var q = "collection:feature_films AND mediatype:movies"
        if !query.isEmpty {
            let encodedQuery = query.trimmingCharacters(in: .whitespaces)
            q += " AND title:(\(encodedQuery))"
        }

        var components = URLComponents(string: "\(baseURL)/advancedsearch.php")!
        components.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "fl[]", value: "identifier"),
            URLQueryItem(name: "fl[]", value: "title"),
            URLQueryItem(name: "fl[]", value: "description"),
            URLQueryItem(name: "rows", value: "\(rows)"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "output", value: "json")
        ]

        guard let url = components.url else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { DispatchQueue.main.async { self.isLoading = false } }

            guard let data = data, error == nil else { return }

            if let decoded = try? JSONDecoder().decode(ArchiveSearchResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.movies = decoded.response.docs
                }
            }
        }.resume()
    }

    // جلب رابط الفيديو المباشر (mp4) القابل للتشغيل عبر AVPlayer
    func fetchVideoURL(identifier: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "\(baseURL)/metadata/\(identifier)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let decoded = try? JSONDecoder().decode(ArchiveMetadataResponse.self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // نفضّل ملفات MPEG4/h.264 لأنها الأكثر توافقاً مع AVPlayer
            let preferredFormats = ["MPEG4", "h.264", "512Kb MPEG4", "MPEG2"]
            let candidates = decoded.files.filter { file in
                file.name.lowercased().hasSuffix(".mp4") ||
                (file.format.map { preferredFormats.contains($0) } ?? false)
            }

            let chosen = candidates.first ?? decoded.files.first { $0.name.lowercased().hasSuffix(".mp4") }

            guard let file = chosen,
                  let encodedName = file.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                  let videoURL = URL(string: "\(self.baseURL)/download/\(identifier)/\(encodedName)") else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            DispatchQueue.main.async { completion(videoURL) }
        }.resume()
    }
}

// MARK: - Models

struct ArchiveSearchResponse: Codable {
    let response: ArchiveResponseBody
}

struct ArchiveResponseBody: Codable {
    let docs: [ArchiveMovie]
}

struct ArchiveMovie: Codable, Identifiable {
    let identifier: String
    let title: String?
    let description: String?

    var id: String { identifier }

    var displayTitle: String {
        title ?? identifier
    }

    // رابط صورة الغلاف يوفره Archive.org تلقائياً لكل عنصر
    var thumbnailURL: URL? {
        URL(string: "https://archive.org/services/img/\(identifier)")
    }
}

struct ArchiveMetadataResponse: Codable {
    let files: [ArchiveFile]
}

struct ArchiveFile: Codable {
    let name: String
    let format: String?
}
