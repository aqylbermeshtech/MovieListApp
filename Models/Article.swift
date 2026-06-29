//
//  Article.swift
//  MovieListApp
//
//  Created by Nurtore on 02.05.2026.
//

import Foundation

struct GuardianResponse: Codable {
    let response: GuardianContent
}

struct GuardianContent: Codable {
    let results: [Article]
}

struct Article: Codable {
    let id: String
    let webTitle: String
    let webUrl: String
    let fields: ArticleFields?
    var title: String { webTitle }
    
    var description: String {
        return fields?.trailText?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) ?? ""
    }
    var thumbnailURL: String? {
        return fields?.thumbnail
    }
}

struct ArticleFields: Codable {
    let thumbnail: String?
    let trailText: String?
}
