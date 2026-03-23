import Foundation

final class MovieListViewModel {
    private var movies: [Movie] = []
    var onUpdate: (() -> Void)?

    func fetchMovies() {
        NetworkService.shared.fetchMovies { [weak self] movies in
            self?.movies = movies
            self?.onUpdate?()
        }
    }

    var numberOfItems: Int {
        movies.count
    }

    func movie(at index: Int) -> Movie {
        movies[index]
    }
}
