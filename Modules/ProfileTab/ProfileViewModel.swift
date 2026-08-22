//
//  ProfileViewModel.swift
//  Movter
//
//  Created by Nurtore on 01.07.2026.
//

import UIKit
import FirebaseAuth

enum ProfileOptionType {
    case editProfile
    case notifications
    case privacyPolicy
    case changeTheme
    case logout
}

struct ProfileOption {
    let title: String
    let iconName: String
    let type: ProfileOptionType
    /// Right-hand detail text, e.g. the theme currently selected.
    var detail: String?
}

struct ProfileSection {
    let header: String?
    let options: [ProfileOption]
}

final class ProfileViewModel {

    /// Points at the data provider's until the app publishes its own.
    static let privacyPolicyURL = URL(string: "https://www.themoviedb.org/privacy-policy")!

    var onNavigationRequired: ((ProfileOptionType) -> Void)?

    private var user: User? { Auth.auth().currentUser }

    // MARK: - Header

    var userName: String {
        let displayName = user?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let displayName = displayName, !displayName.isEmpty { return displayName }
        // Something recognisable, rather than a generic "User".
        if let emailName = user?.email?.split(separator: "@").first { return String(emailName) }
        return "Your Profile"
    }

    var userEmail: String { user?.email ?? "Not signed in" }

    var avatarImage: UIImage {
        InitialsAvatar.image(name: user?.displayName, email: user?.email, size: 200)
    }

    /// "Member since August 2026", from real account metadata.
    var memberSinceText: String? {
        guard let created = user?.metadata.creationDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return "Member since \(formatter.string(from: created))"
    }

    // MARK: - Sections

    private(set) var sections: [ProfileSection] = []

    init() {
        rebuildSections()
    }

    func rebuildSections() {
        sections = [
            ProfileSection(header: "ACCOUNT", options: [
                ProfileOption(title: "Edit Profile", iconName: "person.crop.circle", type: .editProfile)
            ]),
            ProfileSection(header: "PREFERENCES", options: [
                ProfileOption(title: "Notifications", iconName: "bell", type: .notifications),
                ProfileOption(
                    title: "App Theme",
                    iconName: "paintbrush",
                    type: .changeTheme,
                    detail: ThemeManager.shared.currentTheme.displayName
                )
            ]),
            ProfileSection(header: "ABOUT", options: [
                ProfileOption(title: "Privacy Policy", iconName: "lock.shield", type: .privacyPolicy)
            ]),
            ProfileSection(header: nil, options: [
                ProfileOption(title: "Log Out", iconName: "rectangle.portrait.and.arrow.right", type: .logout)
            ])
        ]
    }

    func option(at indexPath: IndexPath) -> ProfileOption? {
        guard let section = sections[safe: indexPath.section] else { return nil }
        return section.options[safe: indexPath.row]
    }

    func didSelectOption(at indexPath: IndexPath) {
        guard let option = option(at: indexPath) else { return }
        onNavigationRequired?(option.type)
    }

    func changeTheme(to theme: AppTheme) {
        ThemeManager.shared.selectTheme(theme)
        rebuildSections()
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
