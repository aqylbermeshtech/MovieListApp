import UIKit

final class MovieDetailViewModel {
    private let movie: Movie
    var onVideoUpdate: ((String?) -> Void)?
    var onActorsUpdate: (() -> Void)?
    
    var actors : [Actor] = []

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
    
    func fetchActors() {
        NetworkService.shared.fetchActors(for: movie.id) { [weak self] fetchedActors in
            guard let self = self, let fetchedActors = fetchedActors else { return }
            self.actors = fetchedActors
            self.onActorsUpdate?()
        }
    }
}
