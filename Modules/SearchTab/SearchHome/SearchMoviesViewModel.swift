//
//  SearchMoviesViewModel.swift
//  MovieListApp
//
//  Created by Nurtore on 02.05.2026.
//

import Foundation
import UIKit

enum SearchNavigationTarget {
    case subcategory(title: String, items: [String])
    case infoAction(title: String, description: String)
}

final class SearchMoviesViewModel {
    private let sections: [(title: String, items: [String])] = [
        (
            title: "Browse by",
            items: ["Release date", "Genre, country or language", "Service", "Most popular", "Highest Rated", "Most anticipated", "Coming soon", "Featured lists", "Official lists"]
        ),
        (
            title: "MoviesApp",
            items: ["New here?", "About Us", "Journal/Editorial", "Showdown Challenges", "Year in Review", "Contacts", "Social Accounts / Follow us", "Community Policy"]
        )
    ]
    var numberOfSections: Int {
        return sections.count
    }
    func numberOfRows(in section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].items.count
    }
    func titleForHeader(in section: Int) -> String? {
        guard section < sections.count else { return nil }
        return sections[section].title
    }
    func item(at indexPath: IndexPath) -> String {
        return sections[indexPath.section].items[indexPath.row]
    }
    func handleSelection(at indexPath: IndexPath) -> SearchNavigationTarget? {
        let selectedItem = item(at: indexPath)
        switch selectedItem {
        case "Release date":
            return .subcategory(title: selectedItem, items: ["2026", "2025", "2024", "2023", "2022", "2020s", "2010s", "2000s"])
        case "Genre, country or language":
            return .subcategory(title: selectedItem, items: ["Action", "Comedy", "Drama", "Sci-Fi", "Thriller", "Horror", "Animation"])
        case "Service":
            return .subcategory(title: selectedItem, items: ["Netflix", "HBO Max", "Apple TV+", "Disney+", "Amazon Prime"])
        case "Most popular":
            return .subcategory(title: selectedItem, items: ["Popular Today", "Popular This Week", "All Time Popular"])
        case "Highest Rated":
            return .subcategory(title: selectedItem, items: ["Top 250 Movies", "Top IMDb", "Critically Acclaimed"])
        case "Most anticipated":
            return .subcategory(title: selectedItem, items: ["Coming This Month", "Most Hyped 2026", "Trending Preorders"])
        case "Coming soon":
            return .subcategory(title: selectedItem, items: ["Theaters This Friday", "Streaming Next Week", "Announced Projects"])
        case "Featured lists":
            return .subcategory(title: selectedItem, items: ["Oscar Winners", "Cannes Festival", "Best of Marvel", "Christopher Nolan Collection"])
        case "Official lists":
            return .subcategory(title: selectedItem, items: ["TMDB Top Rated", "Letterboxd Top 250", "App Users Choice"])
        case "New here?":
            return .infoAction(title: selectedItem, description: "Открыть экран-приветствие или онбординг")
        case "About Us":
            return .infoAction(title: selectedItem, description: "Открыть экран с информацией о команде")
        case "Journal/Editorial":
            return .infoAction(title: selectedItem, description: "Открыть блог или статьи редакции")
        case "Showdown Challenges":
            return .infoAction(title: selectedItem, description: "Открыть игровой режим / челленджи приложения")
        case "Year in Review":
            return .infoAction(title: selectedItem, description: "Открыть итоги года для пользователя")
        case "Contacts":
            return .infoAction(title: selectedItem, description: "Открыть экран обратной связи")
        case "Social Accounts / Follow us":
            return .infoAction(title: selectedItem, description: "Открыть ссылки на Telegram / Instagram приложения")
        case "Community Policy":
            return .infoAction(title: selectedItem, description: "Открыть документ с правилами сообщества")
        default:
            return nil
        }
    }
}
