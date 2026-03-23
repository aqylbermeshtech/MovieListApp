import UIKit

final class NetworkService {
    static let shared = NetworkService()
    private let apiKey = "4af65217d0f22d75f4471c4b7c462d32blablablable"
    private let baseURL = "https://api.themoviedb.org/3"
    
    func fetchMovies(completion: @escaping ([Movie]) -> Void) {
        let urlString = "\(baseURL)/trending/movie/day?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching movies: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
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
                let trailer = result.results.first { $0.site == "YouTube" }
                DispatchQueue.main.async {
                    completion(trailer?.key)
                }
            } catch {
                print("Video decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchActors(for id: Int, completion: @escaping ([Actor]?) -> Void) {
        let urlString = "\(baseURL)/movie/\(id)/credits?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(MovieCredits.self, from: data)
                DispatchQueue.main.async {
                    completion(result.cast)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
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
