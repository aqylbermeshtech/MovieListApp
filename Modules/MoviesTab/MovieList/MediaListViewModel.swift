//
//  MovieListViewModel.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

final class MediaListViewModel {
    private(set) var mediaContent: [Media] = []
    private(set) var articleContent: [Article] = []
    var onUpdate: ((TrendingResult) -> Void)?
    private(set) var currentType: ContentType = .movies
    var sectionTitle: String {
        switch currentType {
        case .movies:
            return "Trending Movies"
        case .tvSeries:
            return "Trending TV Shows"
        case .articles:
            return "Latest Film News"
        }
    }

    func fetchContent(type: ContentType) {
        self.currentType = type
        NetworkService.shared.fetchTrendingContent(type: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .media(let mediaList):
                self.mediaContent = mediaList
                self.onUpdate?(.media(mediaList))
            case .articles(let articleList):
                self.articleContent = articleList
                self.onUpdate?(.articles(articleList))
            }
        }
    }
    
    func getUrl(for article: Article) -> URL? {
        return URL(string: article.webUrl)
    }
}

enum ContentType: Int {
    case movies = 0
    case tvSeries = 1
    case articles = 2
}
