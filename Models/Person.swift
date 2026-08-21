//
//  Person.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

struct PersonDetails: Codable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let profilePath: String?
    let knownForDepartment: String?

    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(path)")
    }
}

struct PersonCreditsResponse: Codable {
    let cast: [PersonCredit]
}

/// One entry of a person's combined (movie + TV) filmography. Every field beyond
/// `id` is optional because TMDB omits them freely across media types.
struct PersonCredit: Codable {
    let id: Int
    let title: String?
    let name: String?
    let character: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let voteAverage: Double?
    let voteCount: Int?
    let genreIds: [Int]?

    var displayName: String { title ?? name ?? "Unknown" }

    var ratingState: RatingState {
        RatingState(voteAverage: voteAverage ?? 0, voteCount: voteCount ?? 0, releaseDate: releaseDate ?? firstAirDate)
    }

    /// TMDB dates are ISO "yyyy-MM-dd", so lexicographic ordering is chronological.
    /// Undated credits sort last because an empty string precedes every real date.
    var sortDate: String { releaseDate ?? firstAirDate ?? "" }

    var year: String? {
        let date = sortDate
        guard date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }

    /// Bridges a credit into the shape the existing details screen already consumes.
    /// `name` stays nil for films so `MediaDetailsViewModel` keeps treating them as movies.
    var asMedia: Media {
        Media(
            id: id,
            title: title,
            name: name,
            overview: overview ?? "",
            posterPath: posterPath,
            releaseDate: releaseDate,
            firstAirDate: firstAirDate,
            voteAverage: voteAverage ?? 0,
            voteCount: voteCount,
            genreIds: genreIds
        )
    }
}
