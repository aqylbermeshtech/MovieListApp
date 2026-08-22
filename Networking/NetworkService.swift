//
//  NetworkService.swift
//  Movter
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

//MARK: - Struct
struct MovieResponse: Codable {
    let results: [Media]
    /// TMDB caps paging at 500; without this the grid kept requesting pages forever.
    let totalPages: Int?
    let totalResults: Int?
}

struct MediaPage {
    let items: [Media]
    let isLastPage: Bool
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
    private let baseURL = "https://api.themoviedb.org/3"
    private let guardianBaseURL = "https://content.guardianapis.com"

    // Injected at build time from Config/Secrets.xcconfig (gitignored); see
    // Movter/Config/Secrets.xcconfig.example.
    private let apiKey = NetworkService.infoPlistValue(for: "TMDB_API_KEY")
    private let guardianApiKey = NetworkService.infoPlistValue(for: "GUARDIAN_API_KEY")

    private static func infoPlistValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            assertionFailure("Missing \(key) — copy Movter/Config/Secrets.xcconfig.example to Config/Secrets.xcconfig (next to Movter.xcodeproj) and fill in real values.")
            return ""
        }
        return value
    }
    
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
    
    func fetchGenres(isTV: Bool, completion: @escaping ([GenreListResponse.Genre]?) -> Void) {
        let type = isTV ? "tv" : "movie"
        let urlString = "\(baseURL)/genre/\(type)/list?api_key=\(apiKey)&language=en-US"
        performRequest(urlString: urlString) { (result: GenreListResponse?) in
            completion(result?.genres)
        }
    }

    func fetchPersonDetails(for id: Int, completion: @escaping (PersonDetails?) -> Void) {
        let urlString = "\(baseURL)/person/\(id)?api_key=\(apiKey)&language=en-US"
        performRequest(urlString: urlString, completion: completion)
    }

    func fetchPersonCredits(for id: Int, completion: @escaping ([PersonCredit]) -> Void) {
        let urlString = "\(baseURL)/person/\(id)/combined_credits?api_key=\(apiKey)&language=en-US"
        performRequest(urlString: urlString) { (result: PersonCreditsResponse?) in
            completion(result?.cast ?? [])
        }
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
    
    func fetchDiscover(query: DiscoverQuery, page: Int, completion: @escaping (MediaPage?) -> Void) {
        var components = URLComponents(string: baseURL + query.path)
        components?.queryItems = query.queryItems + [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US")
        ]
        guard let urlString = components?.url?.absoluteString else {
            completion(nil)
            return
        }
        performRequest(urlString: urlString) { (result: MovieResponse?) in
            completion(result.map { Self.page(from: $0, requested: page) })
        }
    }

    /// TMDB refuses pages past 500 regardless of `total_pages`.
    private static func page(from response: MovieResponse, requested: Int) -> MediaPage {
        let cap = min(response.totalPages ?? requested, 500)
        return MediaPage(items: response.results, isLastPage: requested >= cap || response.results.isEmpty)
    }

    func searchMovies(query: String, page: Int, completion: @escaping (MediaPage?) -> Void) {
        var components = URLComponents(string: baseURL + "/search/movie")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "include_adult", value: "false")
        ]
        guard let urlString = components?.url?.absoluteString else {
            completion(nil)
            return
        }
        performRequest(urlString: urlString) { (result: MovieResponse?) in
            completion(result.map { Self.page(from: $0, requested: page) })
        }
    }

}
