//
//  MainTabBarFactory.swift
//  Movter
//

import UIKit

enum MainTabBarFactory {
    static func makeTabBar() -> UITabBarController {
        let mediaListVC = MediaListViewController()
        mediaListVC.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "film"), tag: 0)

        let searchMoviesVC = SearchMoviesController()
        searchMoviesVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)

        let movieListNav = UINavigationController(rootViewController: mediaListVC)
        let searchMoviesNav = UINavigationController(rootViewController: searchMoviesVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        let tabBar = UITabBarController()
        tabBar.viewControllers = [movieListNav, searchMoviesNav, profileNav]
        return tabBar
    }
}
