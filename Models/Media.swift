//
//  Movie.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

struct Media: Codable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let voteAverage: Double

    var displayName: String {
        return title ?? name ?? "Unknown"
    }

    var fullPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
