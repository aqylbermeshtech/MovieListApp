//
//  ReviewEditorViewModel.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import Foundation

/// Backs both halves of the editor's job: composing a new review and correcting an
/// existing one. Keeping them in one type means the validation rules can't drift apart
/// — an edit that clears the score has to be refused exactly as a new one would be.
final class ReviewEditorViewModel {

    enum Mode {
        case create
        case edit(Review)
    }

    static let maxReviewLength = 2000

    private let store: ReviewStoring
    private let mode: Mode

    // MARK: - Draft

    private(set) var filmTitle: String = ""
    private(set) var filmYear: String?
    private(set) var tmdbID: Int?
    private(set) var posterPath: String?

    var score: Int = 0
    var reviewText: String = ""

    init(store: ReviewStoring, mode: Mode) {
        self.store = store
        self.mode = mode

        if case let .edit(review) = mode {
            filmTitle = review.filmTitle
            filmYear = review.filmYear
            tmdbID = review.tmdbID
            posterPath = review.posterPath
            score = review.score
            reviewText = review.reviewText
        }
    }

    // MARK: - Presentation

    var screenTitle: String {
        if case .edit = mode { return "Edit Review" }
        return "New Review"
    }

    var saveButtonTitle: String {
        if case .edit = mode { return "Save Changes" }
        return "Save Review"
    }

    var hasFilm: Bool { !filmTitle.isEmpty }

    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var filmSubtitle: String {
        guard hasFilm else { return "Search the catalogue, or add one by hand" }
        var parts: [String] = []
        if let filmYear = filmYear, !filmYear.isEmpty { parts.append(filmYear) }
        // Worth surfacing: a hand-typed entry has no poster and no link back to the
        // catalogue, and the user should be able to see which kind they created.
        parts.append(tmdbID == nil ? "Added manually" : "From catalogue")
        return parts.joined(separator: "  ·  ")
    }

    var scoreText: String {
        score == 0 ? "Tap to score" : "\(score)/10"
    }

    var remainingCharactersText: String? {
        let remaining = Self.maxReviewLength - reviewText.count
        // Only worth showing when it starts to matter — a counter sitting at 1,987 is
        // noise on every screen the user opens.
        guard remaining <= 200 else { return nil }
        return "\(remaining) characters left"
    }

    /// A film and a score are the record; the written review is optional. Plenty of
    /// people log a score the night they watch something and write it up later, and
    /// refusing to save that would just push them to type a placeholder character.
    var canSave: Bool {
        hasFilm && Review.scoreRange.contains(score)
    }

    // MARK: - Editing

    func apply(_ selection: FilmSelection) {
        switch selection {
        case let .catalogue(media):
            filmTitle = media.displayName
            filmYear = media.year
            tmdbID = media.id
            posterPath = media.posterPath
        case let .manual(title):
            filmTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            filmYear = nil
            tmdbID = nil
            posterPath = nil
        }
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        guard canSave else { return }

        let review: Review
        switch mode {
        case .create:
            review = Review(
                filmTitle: filmTitle,
                filmYear: filmYear,
                tmdbID: tmdbID,
                posterPath: posterPath,
                score: score,
                reviewText: reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        case let .edit(existing):
            // Reuses the original id and createdAt, so an edit updates the entry in
            // place instead of quietly leaving a duplicate behind.
            review = Review(
                id: existing.id,
                filmTitle: filmTitle,
                filmYear: filmYear,
                tmdbID: tmdbID,
                posterPath: posterPath,
                score: score,
                reviewText: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
                createdAt: existing.createdAt
            )
        }

        store.save(review, completion: completion)
    }
}
