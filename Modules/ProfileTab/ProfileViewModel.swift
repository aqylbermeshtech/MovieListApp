//
//  ProfileViewModel.swift
//  MovieListApp
//
//  Created by Nurtore on 01.07.2026.
//

import Foundation

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
}

final class ProfileViewModel {
    let userName = "Nurtore"
    let userEmail = "nurtore@moviesapp.com"
    let avatarSystemName = "person.circle.fill"

    var onNavigationRequired: ((ProfileOptionType) -> Void)?

    private let options: [ProfileOption] = [
        ProfileOption(title: "Edit Profile", iconName: "gearshape", type: .editProfile),
        ProfileOption(title: "Notifications", iconName: "bell", type: .notifications),
        ProfileOption(title: "Privacy Policy", iconName: "lock.shield", type: .privacyPolicy),
        ProfileOption(title: "App Theme", iconName: "paintbrush", type: .changeTheme),
        ProfileOption(title: "Log Out", iconName: "arrow.left.square", type: .logout)
    ]

    var numberOfOptions: Int {
        return options.count
    }
    
    func option(at index: Int) -> ProfileOption {
        return options[index]
    }

    func didSelectOption(at index: Int) {
        let selectedOption = options[index]
        onNavigationRequired?(selectedOption.type)
    }
    
    func changeTheme(to theme: AppTheme) {
        ThemeManager.shared.selectTheme(theme)
    }
}
