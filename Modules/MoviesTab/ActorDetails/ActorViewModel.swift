//
//  ActorViewModel.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

final class ActorViewModel {

    private let actorId: Int
    /// Name of the tapped cast member, so the header can render before the fetch lands.
    private let fallbackName: String

    private(set) var details: PersonDetails?
    private(set) var credits: [PersonCredit] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var didFailToLoadDetails = false

    var onUpdate: (() -> Void)?

    init(actorId: Int, name: String) {
        self.actorId = actorId
        self.fallbackName = name
    }

    // MARK: - Display text

    var name: String { details?.name ?? fallbackName }

    var profileURL: URL? { details?.profileURL }

    /// "Acting · Born 30 January 1974 (age 52)" — each piece dropped when TMDB has no value.
    var subtitleText: String? {
        var parts: [String] = []
        if let department = details?.knownForDepartment, !department.isEmpty {
            parts.append(department)
        }
        if let lifespan = lifespanText {
            parts.append(lifespan)
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    var birthplaceText: String? {
        guard let place = details?.placeOfBirth, !place.isEmpty else { return nil }
        return place
    }

    var biographyText: String {
        guard let biography = details?.biography?.trimmingCharacters(in: .whitespacesAndNewlines),
              !biography.isEmpty else {
            return "No biography available for \(name) yet."
        }
        return biography
    }

    var hasBiography: Bool {
        guard let biography = details?.biography?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        return !biography.isEmpty
    }

    var filmographyCountText: String {
        credits.isEmpty ? "Filmography" : "Filmography (\(credits.count))"
    }

    var emptyFilmographyText: String {
        didFailToLoadDetails ? "Couldn’t load filmography." : "No credits listed for \(name) yet."
    }

    private var lifespanText: String? {
        guard let birthday = details?.birthday, let born = Self.isoFormatter.date(from: birthday) else { return nil }
        let bornText = Self.displayFormatter.string(from: born)

        if let deathday = details?.deathday, let died = Self.isoFormatter.date(from: deathday) {
            let age = Calendar.current.dateComponents([.year], from: born, to: died).year
            let diedText = Self.displayFormatter.string(from: died)
            return age.map { "\(bornText) – \(diedText) (aged \($0))" } ?? "\(bornText) – \(diedText)"
        }

        guard let age = Calendar.current.dateComponents([.year], from: born, to: Date()).year else {
            return "Born \(bornText)"
        }
        return "Born \(bornText) (age \(age))"
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Loading

    func load() {
        guard !isLoading else { return }
        isLoading = true

        let group = DispatchGroup()

        group.enter()
        NetworkService.shared.fetchPersonDetails(for: actorId) { [weak self] details in
            self?.details = details
            self?.didFailToLoadDetails = (details == nil)
            group.leave()
        }

        group.enter()
        NetworkService.shared.fetchPersonCredits(for: actorId) { [weak self] credits in
            self?.credits = Self.sortedUniqueCredits(from: credits)
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.hasLoaded = true
            self?.onUpdate?()
        }
    }

    /// An actor can be credited twice on one title (two roles, or a movie counted in
    /// both `cast` groupings), so collapse by media id and show newest work first.
    private static func sortedUniqueCredits(from credits: [PersonCredit]) -> [PersonCredit] {
        var seen = Set<Int>()
        return credits
            .sorted { $0.sortDate > $1.sortDate }
            .filter { seen.insert($0.id).inserted }
    }

    func credit(at index: Int) -> PersonCredit? {
        credits.indices.contains(index) ? credits[index] : nil
    }
}
