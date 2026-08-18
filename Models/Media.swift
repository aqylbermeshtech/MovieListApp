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
    /// Optional with a nil fallback: TMDB omits it on some payloads, and a missing
    /// key on a non-optional field fails the whole response's decode.
    let voteCount: Int?
    /// Present on list endpoints (`genre_ids`); the per-title detail endpoint returns
    /// full objects under a different key, which the app doesn't call.
    let genreIds: [Int]?

    var displayName: String {
        return title ?? name ?? "Unknown"
    }

    /// Movies carry `release_date`, TV carries `first_air_date`.
    var releaseDateString: String? { releaseDate ?? firstAirDate }

    var year: String? {
        guard let date = releaseDateString, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }

    var ratingState: RatingState {
        RatingState(voteAverage: voteAverage, voteCount: voteCount ?? 0, releaseDate: releaseDateString)
    }

    var fullPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    /// w500 is visibly soft when a poster spans the full screen width on a 3x device.
    var largePosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }
}
