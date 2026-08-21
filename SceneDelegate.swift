//
//  SceneDelegate.swift
//  Movter
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
            window.rootViewController = MainTabBarFactory.makeTabBar()
        } else {
            let loginVC = LoginViewController()
            let loginNav = UINavigationController(rootViewController: loginVC)
            window.rootViewController = loginNav
        }
        self.window = window
        window.tintColor = ThemeManager.shared.currentTheme.mainColor
        // Every screen is designed dark — black/graphite backgrounds, white text. Without
        // this the app inherits the system appearance, so semantic colours like .label and
        // .secondarySystemBackground resolve light and render invisible or glaringly wrong.
        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()
    }
}

