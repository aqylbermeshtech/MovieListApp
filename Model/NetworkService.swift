import Foundation

final class NetworkService {

    static let shared = NetworkService()

    func fetchMovies(completion: @escaping ([Movie]) -> Void) {
        let movies = [
            Movie(title: "Inception",
                  overview: "A thief who steals corporate secrets...",
                  posterPath: "https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg",
                  releaseDate: "2010",
                  voteAverage: 8.8),

            Movie(title: "Interstellar",
                  overview: "A team travels through a wormhole...",
                  posterPath: "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
                  releaseDate: "2014",
                  voteAverage: 8.6)
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(movies)
        }
    }
}
