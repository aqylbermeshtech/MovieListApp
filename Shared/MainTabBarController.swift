//
//  MainTabBarController.swift
//  Movter
//
//  Created by Nurtore on 22.08.2026.
//

import UIKit

/// Tab bar where the Reviews tab composes instead of navigating: it opens the review
/// sheet over the current tab and leaves the selection untouched.
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
        return false
    }

    private func presentQuickReview() {
        guard let reviewsList = reviewsList, presentedViewController == nil else { return }
        let editor = reviewsList.makeNewReviewEditor()
        present(UINavigationController(rootViewController: editor), animated: true)
    }
}
