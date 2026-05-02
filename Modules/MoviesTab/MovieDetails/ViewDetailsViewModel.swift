//
//  ViewDetailsViewModel.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

final class MovieDetailViewModel {
    private let media: Media
    
    var onVideoUpdate: ((String?) -> Void)?
    var onActorsUpdate: (() -> Void)?
    
    var actors: [Actor] = []

    init(media: Media) {
        self.media = media
    }

    var title: String { media.displayName }
    var overview: String { media.overview }
    var posterPath: String { media.posterPath ?? "" }

    var releaseDate: String { media.releaseDate ?? media.firstAirDate ?? "N/A" }
    
    var voteAverage: Double { media.voteAverage }
    var imageURL: URL? { media.fullPosterURL }
    
    
    func fetchTrailer() {
        let isTV = media.name != nil
        
        NetworkService.shared.fetchVideo(for: media.id, isTV: isTV) { [weak self] key in
            self?.onVideoUpdate?(key)
        }
    }
    
    func fetchActors() {
        NetworkService.shared.fetchActors(for: media.id) { [weak self] fetchedActors in
            guard let self = self, let fetchedActors = fetchedActors else { return }
            self.actors = fetchedActors
            self.onActorsUpdate?()
        }
    }
}
