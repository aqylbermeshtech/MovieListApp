//
//  Movie.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import Foundation

struct Movie: Codable {
    let id:Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double

    var fullPosterURL: URL? {
        guard let path = posterPath else { return nil }
        let urlString = "https://image.tmdb.org/t/p/w500\(path)"
        return URL(string: urlString)
    }
}
