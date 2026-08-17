//
//  ThemeManager.swift
//  MovieListApp
//
//  Created by Nurtore on 02.07.2026.
//

import UIKit

// 1. Описываем доступные темы или палитры
enum AppTheme: String {
    case classic
    case neon
    case darkGold
    
    var mainColor: UIColor {
        switch self {
        case .classic: return .systemBlue
        case .neon: return .systemGreen
        case .darkGold: return UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .classic: return .systemGray
        case .neon: return .systemPurple
        case .darkGold: return .darkGray
        }
    }

    var displayName: String {
        switch self {
        case .classic: return "Classic Blue"
        case .neon: return "Neon Green"
        case .darkGold: return "Dark Gold"
        }
    }
}

// 2. Сам менеджер
final class ThemeManager {
    static let shared = ThemeManager()
    
    // Уведомление для всего приложения о смене темы
    static let themeDidChangeNotification = Notification.Name("ThemeDidChangeNotification")
    
    private let themeKey = "selected_app_theme"
    
    private(set) var currentTheme: AppTheme = .classic
    
    private init() {
        // Загружаем сохраненную тему при старте
        if let savedRaw = UserDefaults.standard.string(forKey: themeKey),
           let savedTheme = AppTheme(rawValue: savedRaw) {
            self.currentTheme = savedTheme
        }
    }
    
    func selectTheme(_ theme: AppTheme) {
        self.currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
        applyToConnectedScenes()

        // Оповещаем все живые экраны, что цвета изменились
        NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification, object: nil)
    }

    /// Tinting the window is what actually makes a theme visible: it cascades to the tab
    /// bar selection, bar buttons, switches and every other control that inherits tint.
    /// Without this the picker saved a value that changed nothing on screen.
    func applyToConnectedScenes() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.tintColor = currentTheme.mainColor }
    }
}
