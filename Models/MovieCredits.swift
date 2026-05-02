//
//  MovieCredits.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

struct MovieCredits: Codable {
    let cast: [Actor]
}

struct Actor: Codable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
}
