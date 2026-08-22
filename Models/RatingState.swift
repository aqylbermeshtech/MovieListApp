//
//  RatingState.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

/// What a title's score actually means. TMDB reports `vote_average: 0.0` for both
/// unrated and unreleased titles, and a headline 10.0 off a single vote — so the
/// average is only meaningful against `vote_count` and the release date.
enum RatingState {
    /// Enough votes to show the score plainly.
    case rated(score: Double, votes: Int)
    /// A real score, but off so few votes that it shouldn't stand next to a real one.
    case provisional(score: Double, votes: Int)
    /// Already out, nobody has rated it.
    case unrated
    /// Not out yet, or announced with no date at all.
    case upcoming(releaseDate: Date?)

    /// Below this, one enthusiast can push a title to 10.0 and outrank a blockbuster.
    static let confidentVoteThreshold = 10

    init(voteAverage: Double, voteCount: Int, releaseDate: String?) {
        let date = releaseDate.flatMap { Self.isoFormatter.date(from: $0) }

        guard voteCount > 0 else {
            // No votes: a future or missing date means unreleased, a past one unrated.
            guard let date = date else {
                self = .upcoming(releaseDate: nil)
                return
            }
            self = date > Date() ? .upcoming(releaseDate: date) : .unrated
            return
        }

        self = voteCount < Self.confidentVoteThreshold
            ? .provisional(score: voteAverage, votes: voteCount)
            : .rated(score: voteAverage, votes: voteCount)
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
