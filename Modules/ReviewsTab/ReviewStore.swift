//
//  ReviewStore.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import Foundation

/// Where a user's reviews live.
///
/// The API is completion-based even though the only implementation today writes to a
/// local file and could answer synchronously. That's the whole point: a Firestore
/// backend can't answer synchronously, so a synchronous protocol would force every
/// call site to be rewritten the day sync is added. Callers already have to handle
/// "the answer arrives later", exactly as they do with `NetworkService`.
///
/// Every callback lands on the main queue.
protocol ReviewStoring: AnyObject {
    /// Newest first — the order the list screen renders.
    func fetchAll(completion: @escaping (Result<[Review], Error>) -> Void)
    /// Inserts, or replaces the existing review with the same `id`.
    func save(_ review: Review, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(_ reviewID: UUID, completion: @escaping (Result<Void, Error>) -> Void)
}

/// Reviews as a JSON file in Documents, scoped to one signed-in account.
///
/// Scoping matters more than it looks: without it, logging out and signing in as
/// somebody else on the same device would show them the previous user's diary. The
/// per-user file also maps cleanly onto `users/{uid}/reviews` when this moves to
/// Firestore, so the migration is a copy rather than a reshape.
final class LocalReviewStore: ReviewStoring {

    private let fileURL: URL
    /// Serial: reads and writes rewrite the whole file, so they must not interleave.
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

    /// - Parameter userID: the Firebase uid. Nil falls back to a shared local file so
    ///   the screen still works if the session is somehow missing, rather than crashing.
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

    /// Read, apply, write — all on the serial queue, so two saves in flight can't
    /// each read the same starting state and clobber one another's entry.
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
        // No file yet is the normal first-launch state, not a failure.
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else { return [] }
        return try decoder.decode([Review].self, from: data)
    }

    private func writeToDisk(_ reviews: [Review]) throws {
        let data = try encoder.encode(reviews)
        // Atomic: a crash mid-write leaves the previous file intact rather than a
        // truncated one that fails to decode and reads as "all your reviews are gone".
        try data.write(to: fileURL, options: .atomic)
    }
}
