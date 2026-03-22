import UIKit

final class NetworkService {
    static let shared = NetworkService()
    private let apiKey = "4af65217d0f22d75f4471c4b7c462d32"
    private let baseURL = "https://api.themoviedb.org/3"
    
    func fetchMovies(completion: @escaping ([Movie]) -> Void) {
        let urlString = "\(baseURL)/trending/movie/day?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching movies: \(error)")
                completion([])
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(MovieResponse.self, from: data)
                
                let firstTen = Array(result.results.prefix(10))
                
                DispatchQueue.main.async {
                    completion(firstTen)
                }
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    func fetchMovieVideo(for id: Int, completion: @escaping (String?) -> Void) {
        let urlString = "\(baseURL)/movie/\(id)/videos?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(VideoResponse.self, from: data)
                // We filter for "Trailer" and "YouTube" specifically
                let trailer = result.results.first { $0.site == "YouTube" && $0.type == "Trailer" }
                
                DispatchQueue.main.async {
                    completion(trailer?.key)
                }
            } catch {
                print("Video decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    struct MovieResponse: Codable {
        let results: [Movie]
    }
    struct VideoResponse: Codable {
        let results: [Video]
    }
}
