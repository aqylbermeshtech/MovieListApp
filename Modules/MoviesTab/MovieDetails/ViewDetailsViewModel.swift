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
    var ratingText: String {
        return String(format: "%.1f ⭐", media.voteAverage)
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
        let isTV = media.name != nil
        NetworkService.shared.fetchVideo(for: media.id, isTV: isTV) { [weak self] key in
            self?.onVideoUpdate?(key)
        }
    }
    
    func fetchActors() {
        let isTV = media.name != nil
        NetworkService.shared.fetchActors(for: media.id, isTV: isTV) { [weak self] fetchedActors in
            guard let self = self, let fetchedActors = fetchedActors else { return }
            self.actors = fetchedActors
            self.onActorsUpdate?()
        }
    }
}
