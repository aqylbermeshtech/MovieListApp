import Foundation

final class MovieDetailViewModel {

    private let movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }

    var title: String { movie.title }
    var description: String { movie.overview }
    var year: String { movie.releaseDate }
    var rating: String { "⭐️ \(movie.voteAverage)" }
    var imageURL: URL? { URL(string: movie.posterPath) }
}
