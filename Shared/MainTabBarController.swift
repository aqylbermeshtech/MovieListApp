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
        // Saving from here leaves no trace on screen — the sheet closes onto the tab the
        // user was already on — so the confirmation is the only signal it worked.
        let editor = reviewsList.makeNewReviewEditor { [weak self] in
            guard let self = self else { return }
            ToastView.show(
                "Added to your reviews",
                in: self.view,
                bottomInset: self.tabBar.frame.height
            )
        }
        present(UINavigationController(rootViewController: editor), animated: true)
    }
}
