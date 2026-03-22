import Foundation

final class MovieListViewModel {

    private var movies: [Movie] = []
    var onUpdate: (() -> Void)?

    // MovieListViewModel.swift
    func fetchMovies() {
        NetworkService.shared.fetchMovies { [weak self] movies in
            self?.movies = movies
            self?.onUpdate?() // Already on the main thread from NetworkService
        }
    }

    var numberOfItems: Int {
        movies.count
    }

    func movie(at index: Int) -> Movie {
        movies[index]
    }
}
