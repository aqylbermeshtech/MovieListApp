//
//  Review.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import Foundation

/// One film the user has watched, scored and written about.
///
/// Deliberately not a `Media`: that struct is TMDB's view of a title and is rebuilt
/// from the network on every launch. This is the user's own record and has to stand
/// on its own, so it keeps a flat snapshot of the few fields it needs to render.
/// `tmdbID` and `posterPath` are nil for a film typed in by hand — the catalogue
/// doesn't know about every student film or unreleased cut somebody wants to log.
struct Review: Codable, Equatable {

    /// Whole numbers only. A personal score is a judgement, not an average, so this
    /// doesn't reuse `RatingState`: there are no vote counts to weigh against it and
    /// no provisional/unrated cases to disambiguate. It's just what the user thought.
    static let scoreRange = 1...10

    let id: UUID
    var filmTitle: String
    var filmYear: String?
    var tmdbID: Int?
    var posterPath: String?
    var score: Int
    var reviewText: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        filmTitle: String,
        filmYear: String? = nil,
        tmdbID: Int? = nil,
        posterPath: String? = nil,
        score: Int,
        reviewText: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.filmTitle = filmTitle
        self.filmYear = filmYear
        self.tmdbID = tmdbID
        self.posterPath = posterPath
        self.score = score.clamped(to: Self.scoreRange)
        self.reviewText = reviewText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Seeds a review from a catalogue title, carrying over everything needed to render
    /// the entry later without a second network call.
    init(from media: Media, score: Int, reviewText: String = "") {
        self.init(
            filmTitle: media.displayName,
            filmYear: media.year,
            tmdbID: media.id,
            posterPath: media.posterPath,
            score: score,
            reviewText: reviewText
        )
    }

    /// Matches `Media.fullPosterURL` so a review cell and a catalogue cell pull the
    /// same cached image rather than fetching the poster twice at different widths.
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    /// "Dune  ·  2021" — the year is dropped along with its separator when unknown,
    /// which is the common case for hand-typed entries.
    var titleWithYear: String {
        guard let filmYear = filmYear, !filmYear.isEmpty else { return filmTitle }
        return "\(filmTitle)  ·  \(filmYear)"
    }

    var hasReviewText: Bool {
        !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
