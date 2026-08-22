//
//  MainTabBarFactory.swift
//  Movter
//

import UIKit
import FirebaseAuth

enum MainTabBarFactory {
    static func makeTabBar() -> UITabBarController {
        // Built per sign-in, so the store is always scoped to the current account.
        let reviewStore = ReviewStoreFactory.makeStore()

        // Tab labels live here. Root screens must set `navigationItem.title`, never
        // `title` — that writes through to the tab bar item too, and runs later.
        let mediaListVC = MediaListViewController()
        mediaListVC.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "film"), tag: 0)

        let searchMoviesVC = SearchMoviesController()
        searchMoviesVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let reviewsVC = ReviewsListViewController(
            viewModel: ReviewsListViewModel(store: reviewStore)
        )
        reviewsVC.tabBarItem = UITabBarItem(title: "Reviews", image: UIImage(systemName: "star.bubble"), tag: 2)

        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)

        let movieListNav = UINavigationController(rootViewController: mediaListVC)
        let searchMoviesNav = UINavigationController(rootViewController: searchMoviesVC)
        let reviewsNav = UINavigationController(rootViewController: reviewsVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        let tabBar = MainTabBarController()
        tabBar.viewControllers = [movieListNav, searchMoviesNav, reviewsNav, profileNav]
        tabBar.enableQuickReview(nav: reviewsNav, list: reviewsVC)
        return tabBar
    }
}
