//
//  ThemeManager.swift
//  Movter
//
//  Created by Nurtore on 02.07.2026.
//

import UIKit

enum AppTheme: String {
    case mono
    case amber
    case slate

    /// Deliberately low-chroma: posters supply the colour, the chrome stays back.
    var mainColor: UIColor {
        switch self {
        case .mono:  return UIColor(hex: "F5F5F7")
        case .amber: return UIColor(hex: "D8A657")
        case .slate: return UIColor(hex: "8FA3B8")
        }
    }

    var displayName: String {
        switch self {
        case .mono:  return "Monochrome"
        case .amber: return "Amber"
        case .slate: return "Slate"
        }
    }
}

final class ThemeManager {
    static let shared = ThemeManager()
    
    static let themeDidChangeNotification = Notification.Name("ThemeDidChangeNotification")
    
    private let themeKey = "selected_app_theme"
    
    private(set) var currentTheme: AppTheme = .mono
    
    private init() {
        if let savedRaw = UserDefaults.standard.string(forKey: themeKey),
           let savedTheme = AppTheme(rawValue: savedRaw) {
            self.currentTheme = savedTheme
        }
    }
    
    func selectTheme(_ theme: AppTheme) {
        self.currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
        applyToConnectedScenes()

        NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: nil)
    }

    /// Tinting the window is what makes a theme visible — it cascades to the tab bar,
    /// bar buttons and every other control that inherits tint.
    func applyToConnectedScenes() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.tintColor = currentTheme.mainColor }
    }
}
