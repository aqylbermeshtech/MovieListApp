//
//  GenreProvider.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

struct GenreListResponse: Codable {
    struct Genre: Codable {
        let id: Int
        let name: String
    }
    let genres: [Genre]
}

/// Resolves `genre_ids` into names. TMDB's genre table is small and static, so it's
/// fetched once per media type and kept for the process lifetime.
final class GenreProvider {

    static let shared = GenreProvider()
    private init() {}

    private var cache: [Bool: [Int: String]] = [:]        // isTV -> [id: name]
    private var inFlight: [Bool: [(  [Int: String]) -> Void]] = [:]
    private let queue = DispatchQueue(label: "GenreProvider", attributes: .concurrent)

    /// First name only; TMDB orders them most-representative first.
    func primaryGenreName(for ids: [Int]?, isTV: Bool, completion: @escaping (String?) -> Void) {
        guard let ids = ids, !ids.isEmpty else {
            completion(nil)
            return
        }
        table(isTV: isTV) { table in
            completion(ids.compactMap { table[$0] }.first)
        }
    }

    private func table(isTV: Bool, completion: @escaping ([Int: String]) -> Void) {
        if let cached = queue.sync(execute: { cache[isTV] }) {
            completion(cached)
            return
        }

        // Coalesce concurrent callers so a screenful of cells triggers one request.
        var shouldFetch = false
        queue.sync(flags: .barrier) {
            if inFlight[isTV] == nil {
                inFlight[isTV] = []
                shouldFetch = true
            }
            inFlight[isTV]?.append(completion)
        }
        guard shouldFetch else { return }

        NetworkService.shared.fetchGenres(isTV: isTV) { [weak self] genres in
            guard let self = self else { return }
            let table = Dictionary(uniqueKeysWithValues: (genres ?? []).map { ($0.id, $0.name) })

            var waiting: [([Int: String]) -> Void] = []
            self.queue.sync(flags: .barrier) {
                // Only cache a real answer, so a failed request retries next time.
                if !table.isEmpty { self.cache[isTV] = table }
                waiting = self.inFlight[isTV] ?? []
                self.inFlight[isTV] = nil
            }
            waiting.forEach { $0(table) }
        }
    }
}
