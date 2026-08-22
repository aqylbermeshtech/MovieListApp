//
//  Movie.swift
//  Movter
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
    /// Optional: TMDB omits it on some payloads, and that would fail the whole decode.
    let voteCount: Int?
    /// List endpoints only; the detail endpoint returns full objects under another key.
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
