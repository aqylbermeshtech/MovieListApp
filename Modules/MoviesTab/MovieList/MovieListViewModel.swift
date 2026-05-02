//
//  MovieListViewModel.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

final class MovieListViewModel {

    private(set) var content: [Media] = []

    var onUpdate: (() -> Void)?

    private var currentType: ContentType = .movies

    func fetchContent(type: ContentType) {
        self.currentType = type

        NetworkService.shared.fetchTrendingContent(type: type) { [weak self] results in
            guard let self = self else { return }
            self.content = Array(results.prefix(9))
            self.onUpdate?()
        }
    }

    var numberOfItems: Int {
        content.count
    }

    func item(at index: Int) -> Media {
        content[index]
    }
}

enum ContentType: Int {
    case movies = 0
    case tvSeries = 1
    case anime = 2
}
