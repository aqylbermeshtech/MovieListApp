//
//  ViewDetailsViewModel.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

final class MediaDetailsViewModel {
    private let media: Media
    var onVideoUpdate: ((String?) -> Void)?
    var onActorsUpdate: (() -> Void)?
    var actors: [Actor] = []
    var title: String { media.displayName }
    var overview: String { media.overview }
    var posterPath: String { media.posterPath ?? "" }
    var releaseDate: String { media.releaseDate ?? media.firstAirDate ?? "N/A" }
    var voteAverage: Double { media.voteAverage }
    var imageURL: URL? { media.fullPosterURL }
    var ratingState: RatingState { media.ratingState }
    var year: String? { media.year }
    var largeImageURL: URL? { media.largePosterURL ?? media.fullPosterURL }
    private var isTV: Bool { media.name != nil }

    private(set) var genreName: String?
    var onGenreUpdate: (() -> Void)?

    func fetchGenre() {
        GenreProvider.shared.primaryGenreName(for: media.genreIds, isTV: isTV) { [weak self] name in
            guard let self = self, let name = name else { return }
            self.genreName = name
            self.onGenreUpdate?()
        }
    }

    init(media: Media) {
        self.media = media
    }

    func youtubeRequest(for key: String) -> URLRequest? {
        let urlString = "https://www.youtube.com/embed/\(key)?enablejsapi=1&origin=https://www.themoviedb.org"
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.setValue("https://www.themoviedb.org", forHTTPHeaderField: "Referer")
        return request
    }
    
    
    func fetchTrailer() {
        NetworkService.shared.fetchVideo(for: media.id, isTV: isTV) { [weak self] key in
            self?.onVideoUpdate?(key)
        }
    }
    
    func fetchActors() {
        NetworkService.shared.fetchActors(for: media.id, isTV: isTV) { [weak self] fetchedActors in
            guard let self = self, let fetchedActors = fetchedActors else { return }
            self.actors = fetchedActors
            self.onActorsUpdate?()
        }
    }
}
