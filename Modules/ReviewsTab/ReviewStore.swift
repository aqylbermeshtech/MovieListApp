//
//  ReviewStore.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import Foundation
import FirebaseAuth

/// Where a user's reviews live.
///
/// Completion-based even though the local store could answer synchronously: a remote
/// backend can't, and a synchronous protocol would force every call site to change the
/// day sync is added. Callbacks land on the main queue.
protocol ReviewStoring: AnyObject {
    /// Newest first.
    func fetchAll(completion: @escaping (Result<[Review], Error>) -> Void)
    /// Inserts, or replaces the existing review with the same `id`.
    func save(_ review: Review, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(_ reviewID: UUID, completion: @escaping (Result<Void, Error>) -> Void)
}

extension ReviewStoring {

    /// Defaulted rather than required so a remote backend can override it with an
    /// indexed query instead of fetching the whole diary.
    func fetchReview(forTMDBID tmdbID: Int, completion: @escaping (Result<Review?, Error>) -> Void) {
        fetchAll { result in
            completion(result.map { reviews in
                reviews.first { $0.tmdbID == tmdbID }
            })
        }
    }
}

/// The single place that picks the storage backend.
enum ReviewStoreFactory {
    static func makeStore() -> ReviewStoring {
        LocalReviewStore(userID: Auth.auth().currentUser?.uid)
    }
}

/// Reviews as a JSON file in Documents, one file per account so switching users can't
/// expose the previous user's diary.
final class LocalReviewStore: ReviewStoring {

    private let fileURL: URL
    /// Serial: every operation rewrites the whole file.
    private let queue = DispatchQueue(label: "com.nurtore.movter.reviewstore")

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    /// - Parameter userID: Firebase uid; nil falls back to a shared local file.
    init(userID: String?) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent("reviews-\(userID ?? "local").json")
    }

    // MARK: - ReviewStoring

    func fetchAll(completion: @escaping (Result<[Review], Error>) -> Void) {
        queue.async {
            let result = Result { try self.readFromDisk() }
                .map { $0.sorted { $0.updatedAt > $1.updatedAt } }
            DispatchQueue.main.async { completion(result) }
        }
    }

    func save(_ review: Review, completion: @escaping (Result<Void, Error>) -> Void) {
        mutate(completion: completion) { reviews in
            var updated = review
            updated.updatedAt = Date()
            if let index = reviews.firstIndex(where: { $0.id == review.id }) {
                reviews[index] = updated
            } else {
                reviews.append(updated)
            }
        }
    }

    func delete(_ reviewID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        mutate(completion: completion) { reviews in
            reviews.removeAll { $0.id == reviewID }
        }
    }

    // MARK: - Disk

    /// Read-modify-write on the serial queue so concurrent saves can't clobber
    /// each other.
    private func mutate(
        completion: @escaping (Result<Void, Error>) -> Void,
        _ changes: @escaping (inout [Review]) -> Void
    ) {
        queue.async {
            let result = Result {
                var reviews = try self.readFromDisk()
                changes(&reviews)
                try self.writeToDisk(reviews)
            }
            DispatchQueue.main.async { completion(result) }
        }
    }

    private func readFromDisk() throws -> [Review] {
        // Missing file is the first-launch state, not a failure.
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else { return [] }
        return try decoder.decode([Review].self, from: data)
    }

    private func writeToDisk(_ reviews: [Review]) throws {
        let data = try encoder.encode(reviews)
        // Atomic: a crash mid-write leaves the previous file intact rather than a
        // truncated one that fails to decode.
        try data.write(to: fileURL, options: .atomic)
    }
}
