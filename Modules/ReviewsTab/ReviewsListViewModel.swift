//
//  ReviewsListViewModel.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import UIKit

final class ReviewsListViewModel {

    /// Fired whenever `reviews` changes, including the first load.
    var onChange: (() -> Void)?
    var onError: ((String) -> Void)?

    private let store: ReviewStoring
    private(set) var reviews: [Review] = []

    init(store: ReviewStoring) {
        self.store = store
    }

    var isEmpty: Bool { reviews.isEmpty }

    var summaryText: String? {
        guard !reviews.isEmpty else { return nil }
        let average = Double(reviews.reduce(0) { $0 + $1.score }) / Double(reviews.count)
        let filmCount = "\(reviews.count) film\(reviews.count == 1 ? "" : "s")"
        return String(format: "%@  ·  %.1f average", filmCount, average)
    }

    func load() {
        store.fetchAll { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(reviews):
                self.reviews = reviews
                self.onChange?()
            case let .failure(error):
                self.onError?(error.localizedDescription)
            }
        }
    }

    func review(at indexPath: IndexPath) -> Review? {
        reviews[safe: indexPath.row]
    }

    func delete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard let review = review(at: indexPath) else {
            completion(false)
            return
        }
        // Drop it from the local copy first so the row animates out immediately; a
        // failed write reloads from disk and puts it back rather than lying about it.
        reviews.remove(at: indexPath.row)

        store.delete(review.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                completion(true)
            case let .failure(error):
                self.onError?(error.localizedDescription)
                self.load()
                completion(false)
            }
        }
    }

    func makeEditorViewModel(for review: Review?) -> ReviewEditorViewModel {
        ReviewEditorViewModel(
            store: store,
            mode: review.map { .edit($0) } ?? .create
        )
    }
}
