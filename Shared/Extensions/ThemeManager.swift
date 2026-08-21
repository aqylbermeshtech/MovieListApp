//
//  ThemeManager.swift
//  Movter
//
//  Created by Nurtore on 02.07.2026.
//

import UIKit

// 1. Описываем доступные темы или палитры
enum AppTheme: String {
    case mono
    case amber
    case slate

    /// The one saturated-ish colour in the interface. All three are deliberately
    /// low-chroma: posters supply the colour, the chrome stays out of the way.
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

// 2. Сам менеджер
final class ThemeManager {
    static let shared = ThemeManager()
    
    // Уведомление для всего приложения о смене темы
    static let themeDidChangeNotification = Notification.Name("ThemeDidChangeNotification")
    
    private let themeKey = "selected_app_theme"
    
    private(set) var currentTheme: AppTheme = .mono
    
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
