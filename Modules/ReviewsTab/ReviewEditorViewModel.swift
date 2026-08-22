//
//  ReviewEditorViewModel.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import Foundation

/// Backs both composing a new review and editing an existing one, so the validation
/// rules can't drift apart.
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
        parts.append(tmdbID == nil ? "Added manually" : "From catalogue")
        return parts.joined(separator: "  ·  ")
    }

    var scoreText: String {
        score == 0 ? "Tap to score" : "\(score)/10"
    }

    var remainingCharactersText: String? {
        let remaining = Self.maxReviewLength - reviewText.count
        // Only once it starts to matter.
        guard remaining <= 200 else { return nil }
        return "\(remaining) characters left"
    }

    /// A film and a score are the record; the written review is optional.
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
            // Same id and createdAt, so an edit updates in place.
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
