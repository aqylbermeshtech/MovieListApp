//
//  NetworkService.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

//MARK: - Struct
struct MovieResponse: Codable {
    let results: [Media]
}

struct VideoResponse: Codable {
    let results: [Video]
}

enum TrendingResult {
    case media([Media])
    case articles([Article])
}

final class NetworkService {
    static let shared = NetworkService()
    private let apiKey = "4af65217d0f22d75f4471c4b7c462d32"
    private let baseURL = "https://api.themoviedb.org/3"
    private let guardianBaseURL = "https://content.guardianapis.com"
    private let guardianApiKey = "4a65ce32-1ae0-4d48-9ff5-62a45255511d"
    
    func fetchTrendingContent(type: ContentType, completion: @escaping (TrendingResult) -> Void) {
        let endpoint: String
        switch type {
        case .movies:
            endpoint = "/trending/movie/day"
        case .tvSeries:
            endpoint = "/trending/tv/day"
        case .articles:
            fetchArticles { articles in
                completion(.articles(articles ?? []))
            }
            return
        }
        let urlString = "\(baseURL)\(endpoint)\(endpoint.contains("?") ? "&" : "?")api_key=\(apiKey)"
        performRequest(urlString: urlString) { (result: MovieResponse?) in
            completion(.media(result?.results ?? []))
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
    
    func fetchActors(for id: Int, isTV: Bool, completion: @escaping ([Actor]?) -> Void) {
        let type = isTV ? "tv" : "movie"
        let urlString = "\(baseURL)/\(type)/\(id)/credits?api_key=\(apiKey)"
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
                print("Decoding error for \(type): \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
    
    func fetchArticles(completion: @escaping ([Article]?) -> Void) {
        let urlString = "\(guardianBaseURL)/search?section=film&show-fields=thumbnail,trailText&api-key=\(guardianApiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(String(describing: error))")
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(GuardianResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result.response.results)
                }
            } catch {
                print("Decoding error for Guardian: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    //TODO: Complete the logic of search
    func fetchDiscoverMovies(category: String, value: String, page: Int, completion: @escaping ([Media]) -> Void) {
        var endpoint = "/discover/movie?page=\(page)"
        if category == "Release date" {
            endpoint += "&primary_release_year=\(value)"
        } else if category == "Genre, country or language" {
            let genreId = getTMDBGenreId(for: value)
            endpoint += "&with_genres=\(genreId)"
        } else if category == "Service" {
            let providerId = getProviderId(for: value)
            endpoint += "&with_watch_providers=\(providerId)&watch_region=US"
        }
        let urlString = "\(baseURL)\(endpoint)&api_key=\(apiKey)&language=en-US"
        performRequest(urlString: urlString) { (result: MovieResponse?) in
            completion(result?.results ?? [])
        }
    }

    private func getTMDBGenreId(for name: String) -> String {
        switch name.lowercased() {
        case "action": return "28"
        case "comedy": return "35"
        case "drama": return "18"
        case "sci-fi": return "878"
        case "thriller": return "53"
        case "horror": return "27"
        case "animation": return "16"
        default: return ""
        }
    }

    private func getProviderId(for name: String) -> String {
        switch name.lowercased() {
        case "netflix": return "8"
        case "hbo max": return "384"
        case "apple tv+": return "350"
        case "disney+": return "337"
        case "amazon prime": return "9"
        default: return ""
        }
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
