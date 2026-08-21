//
//  MainTabBarFactory.swift
//  Movter
//

import UIKit
import FirebaseAuth

enum MainTabBarFactory {
    static func makeTabBar() -> UITabBarController {
        // Scoped to the signed-in account, and built here because the tab bar is
        // recreated on every sign-in — so switching accounts can never leave one
        // user looking at another's diary.
        let reviewStore = ReviewStoreFactory.makeStore()

        // Tab labels are owned here, and the root screens set `navigationItem.title`
        // rather than `title` so they stay that way. `UIViewController.title` writes
        // through to *both* the navigation item and the tab bar item, and it runs in
        // viewDidLoad — after this — so a screen setting `title` would silently rename
        // its own tab.
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

        let tabBar = UITabBarController()
        tabBar.viewControllers = [movieListNav, searchMoviesNav, reviewsNav, profileNav]
        return tabBar
    }
}
