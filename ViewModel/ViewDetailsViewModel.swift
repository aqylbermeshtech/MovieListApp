import UIKit

final class MovieDetailViewModel {
    private let movie: Movie
    var onVideoUpdate: ((String?) -> Void)?

    init(movie: Movie) {
        self.movie = movie
    }
    var title: String { movie.title }
    var overview: String { movie.overview }
    var posterPath : String { movie.posterPath ?? "N/A" }
    var releaseDate: String { movie.releaseDate ?? "N/A"}
    var voteAverage: Double { movie.voteAverage }
    var imageURL: URL? { movie.fullPosterURL }
    
    func fetchTrailer() {
        NetworkService.shared.fetchMovieVideo(for: movie.id) { [weak self] key in
            self?.onVideoUpdate?(key)
        }
    }
}
