//
//  NetworkService.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation


struct MovieResponse: Codable {
    let results: [Media]
}

struct VideoResponse: Codable {
    let results: [Video]
}

final class NetworkService {
    static let shared = NetworkService()
    private let apiKey = "4af65217d0f22d75f4471c4b7c462d32"
    private let baseURL = "https://api.themoviedb.org/3"
    
    func fetchTrendingContent(type: ContentType, completion: @escaping ([Media]) -> Void) {
        let endpoint: String
        
        switch type {
        case .movies:
            endpoint = "/trending/movie/day"
        case .tvSeries:
            endpoint = "/trending/tv/day"
        case .anime:
            // Для аниме используем discover и фильтр по жанру "Animation" (16) + регион Япония
            endpoint = "/discover/tv?with_genres=16&with_original_language=ja"
        }
        
        let urlString = "\(baseURL)\(endpoint)\(endpoint.contains("?") ? "&" : "?")api_key=\(apiKey)"
        
        performRequest(urlString: urlString) { (result: MovieResponse?) in
            completion(result?.results ?? [])
        }
    }

    private func performRequest<T: Decodable>(urlString: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(result) }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    func fetchVideo(for id: Int, isTV: Bool, completion: @escaping (String?) -> Void) {
        let category = isTV ? "tv" : "movie"
        let urlString = "\(baseURL)/\(category)/\(id)/videos?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Обработка сетевых ошибок
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
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
                print("Decoding error: \(error)")
                DispatchQueue.main.async { completion(nil) }
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
    func searchMovies(query: String, completion: @escaping ([Media]) -> Void) {
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
