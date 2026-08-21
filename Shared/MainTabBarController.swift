//
//  MainTabBarController.swift
//  Movter
//
//  Created by Nurtore on 22.08.2026.
//

import UIKit

/// The tab bar, with one piece of behaviour of its own: the Reviews tab is an action
/// rather than a destination.
///
/// Choosing it doesn't switch tabs. It raises the composer over whatever you were
/// looking at, and closing the composer puts you back exactly where you were — the tab
/// bar never moves. Nothing about logging a film should cost you your place.
final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    private weak var reviewsNav: UIViewController?
    private weak var reviewsList: ReviewsListViewController?

    func enableQuickReview(nav: UIViewController, list: ReviewsListViewController) {
        reviewsNav = nav
        reviewsList = list
        delegate = self
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard viewController === reviewsNav, viewController !== selectedViewController else {
            return true
        }
        presentQuickReview()
        // Veto the selection: the sheet goes up over the tab the user is already on,
        // and that tab is still there when the sheet comes down.
        return false
    }

    private func presentQuickReview() {
        guard let reviewsList = reviewsList, presentedViewController == nil else { return }
        let editor = reviewsList.makeNewReviewEditor()
        present(UINavigationController(rootViewController: editor), animated: true)
    }
}
