//
//  NotificationPreferences.swift
//  MovieListApp
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

enum NotificationPreference: String, CaseIterable {
    case newTrailers
    case weeklyDigest
    case filmNews

    var title: String {
        switch self {
        case .newTrailers: return "New Trailers"
        case .weeklyDigest: return "Weekly Digest"
        case .filmNews: return "Film News"
        }
    }

    var subtitle: String {
        switch self {
        case .newTrailers: return "When a film you viewed gets a trailer"
        case .weeklyDigest: return "A summary of what's trending each week"
        case .filmNews: return "Latest articles from the news feed"
        }
    }

    /// New installs opt into the quieter two and leave the daily-ish one off.
    var defaultValue: Bool {
        switch self {
        case .newTrailers: return true
        case .weeklyDigest: return true
        case .filmNews: return false
        }
    }
}

final class NotificationPreferencesStore {

    static let shared = NotificationPreferencesStore()

    private let defaults: UserDefaults
    private let keyPrefix = "notification_preference_"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isEnabled(_ preference: NotificationPreference) -> Bool {
        let key = keyPrefix + preference.rawValue
        // `bool(forKey:)` can't distinguish "off" from "never set", so check presence
        // first or every default-on toggle would read as off on a fresh install.
        guard defaults.object(forKey: key) != nil else { return preference.defaultValue }
        return defaults.bool(forKey: key)
    }

    func setEnabled(_ isEnabled: Bool, for preference: NotificationPreference) {
        defaults.set(isEnabled, forKey: keyPrefix + preference.rawValue)
    }
}
