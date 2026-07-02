//
//  SceneDelegate.swift
//  MovieListApp
//
//  Created by Nurtore on 13.03.2026.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        if Auth.auth().currentUser != nil {
            let tabBar = createMainTabBar()
            window.rootViewController = tabBar
        } else {
            let loginVC = LoginViewController()
            let loginNav = UINavigationController(rootViewController: loginVC)
            window.rootViewController = loginNav
        }
        self.window = window
        window.makeKeyAndVisible()
    }

    private func createMainTabBar() -> UITabBarController {
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

