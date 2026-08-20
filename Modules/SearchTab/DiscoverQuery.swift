//
//  DiscoverQuery.swift
//  MovieListApp
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

/// A browse selection turned into a real TMDB request.
///
/// This replaces the previous string matching, which understood only three of the nine
/// categories and let every other selection fall through to an unfiltered
/// `/discover/movie` — the same million-title list dressed up under six different names.
/// Anything genuinely unsupported now returns nil so the screen can say so, rather than
/// silently showing the whole catalogue.
struct DiscoverQuery {

    let path: String
    let queryItems: [URLQueryItem]

    private init(_ path: String, _ items: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = items
    }

    private static func discover(_ items: [String: String]) -> DiscoverQuery {
        DiscoverQuery("/discover/movie", items.map { URLQueryItem(name: $0.key, value: $0.value) })
    }

    static func make(category: String, value: String) -> DiscoverQuery? {
        switch category {
        case "Release date":       return releaseDate(value)
        case "Genre, country or language": return genre(value)
        case "Service":            return service(value)
        case "Most popular":       return mostPopular(value)
        case "Highest Rated":      return highestRated(value)
        case "Most anticipated":   return mostAnticipated(value)
        case "Coming soon":        return comingSoon(value)
        case "Featured lists":     return featured(value)
        case "Official lists":     return official(value)
        default:                   return nil
        }
    }

    // MARK: - Categories

    private static func releaseDate(_ value: String) -> DiscoverQuery? {
        // A decade has to become a date range: TMDB coerces "2020s" to the year 2020,
        // so the old code quietly returned one year where the user asked for ten.
        if value.hasSuffix("s"), let start = Int(value.dropLast()) {
            return discover([
                "primary_release_date.gte": "\(start)-01-01",
                "primary_release_date.lte": "\(start + 9)-12-31",
                "sort_by": "popularity.desc"
            ])
        }
        guard let year = Int(value) else { return nil }
        return discover(["primary_release_year": "\(year)", "sort_by": "popularity.desc"])
    }

    private static func genre(_ value: String) -> DiscoverQuery? {
        guard let id = genreIds[value.lowercased()] else { return nil }
        return discover(["with_genres": id, "sort_by": "popularity.desc"])
    }

    private static func service(_ value: String) -> DiscoverQuery? {
        guard let id = providerIds[value.lowercased()] else { return nil }
        return discover([
            "with_watch_providers": id,
            "watch_region": "US",
            "sort_by": "popularity.desc"
        ])
    }

    private static func mostPopular(_ value: String) -> DiscoverQuery? {
        switch value {
        case "Popular Today":     return DiscoverQuery("/movie/popular")
        case "Popular This Week": return DiscoverQuery("/trending/movie/week")
        case "All Time Popular":
            return discover(["sort_by": "vote_count.desc", "vote_count.gte": "5000"])
        default: return nil
        }
    }

    private static func highestRated(_ value: String) -> DiscoverQuery? {
        switch value {
        case "Top 250 Movies", "TMDB Top Rated":
            return DiscoverQuery("/movie/top_rated")
        case "Critically Acclaimed":
            // A high average is meaningless without volume behind it.
            return discover(["sort_by": "vote_average.desc", "vote_count.gte": "3000"])
        default: return nil
        }
    }

    private static func mostAnticipated(_ value: String) -> DiscoverQuery? {
        let today = isoDay(Date())
        switch value {
        case "Coming This Month":
            return discover([
                "primary_release_date.gte": today,
                "primary_release_date.lte": isoDay(Date().addingTimeInterval(30 * 86_400)),
                "sort_by": "popularity.desc"
            ])
        case "Most Hyped 2026", "Trending Preorders":
            return discover(["primary_release_date.gte": today, "sort_by": "popularity.desc"])
        default: return nil
        }
    }

    private static func comingSoon(_ value: String) -> DiscoverQuery? {
        switch value {
        case "Theaters This Friday":
            return DiscoverQuery("/movie/upcoming")
        case "Streaming Next Week":
            return discover([
                "primary_release_date.gte": isoDay(Date()),
                "primary_release_date.lte": isoDay(Date().addingTimeInterval(14 * 86_400)),
                "with_watch_monetization_types": "flatrate",
                "watch_region": "US",
                "sort_by": "popularity.desc"
            ])
        case "Announced Projects":
            // Far enough out that nothing has a firm release yet.
            return discover([
                "primary_release_date.gte": isoDay(Date().addingTimeInterval(180 * 86_400)),
                "sort_by": "popularity.desc"
            ])
        default: return nil
        }
    }

    private static func featured(_ value: String) -> DiscoverQuery? {
        switch value {
        case "Best of Marvel":
            return discover(["with_companies": "420", "sort_by": "popularity.desc"])
        case "Christopher Nolan Collection":
            return discover(["with_crew": "525", "sort_by": "primary_release_date.desc"])
        // "Oscar Winners" and "Cannes Festival" have no TMDB filter behind them —
        // they'd need a curated list, so they report as unavailable instead of
        // returning an unfiltered catalogue.
        default: return nil
        }
    }

    private static func official(_ value: String) -> DiscoverQuery? {
        switch value {
        case "TMDB Top Rated": return DiscoverQuery("/movie/top_rated")
        // "Letterboxd Top 250" isn't TMDB data, and "App Users Choice" needs a backend
        // this app doesn't have.
        default: return nil
        }
    }

    // MARK: - Lookups

    private static let genreIds: [String: String] = [
        "action": "28", "comedy": "35", "drama": "18", "sci-fi": "878",
        "thriller": "53", "horror": "27", "animation": "16"
    ]

    private static let providerIds: [String: String] = [
        "netflix": "8", "hbo max": "384", "apple tv+": "350",
        "disney+": "337", "amazon prime": "9"
    ]

    private static func isoDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
