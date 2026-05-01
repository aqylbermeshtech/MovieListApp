//
//  NetworkService.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation


struct MovieResponse: Codable {
    let results: [Movie]
}

struct VideoResponse: Codable {
    let results: [Video]
}

final class NetworkService {
    static let shared = NetworkService()
    private let apiKey = "4af65217d0f22d75f4471c4b7c462d32"
    private let baseURL = "https://api.themoviedb.org/3"
    
    func fetchMovies(completion: @escaping ([Movie]) -> Void) {
        let urlString = "\(baseURL)/trending/movie/day?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion([]) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error status code")
                DispatchQueue.main.async { completion([]) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(MovieResponse.self, from: data)
                
                let limitedResults = Array(result.results.prefix(9))
                
                DispatchQueue.main.async {
                    completion(limitedResults)
                }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
    
    func fetchMovieVideo(for id: Int, completion: @escaping (String?) -> Void) {
        let urlString = "\(baseURL)/movie/\(id)/videos?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(VideoResponse.self, from: data)
                
                let trailer = result.results.first { $0.site == "YouTube" && $0.type == "Trailer" }
                             ?? result.results.first { $0.site == "YouTube" }
                
                DispatchQueue.main.async {
                    completion(trailer?.key)
                }
            } catch {
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
    func searchMovies(query: String, completion: @escaping ([Movie]) -> Void) {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encoded)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(MovieResponse.self, from: data)
                DispatchQueue.main.async { completion(result.results) }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
    
}
