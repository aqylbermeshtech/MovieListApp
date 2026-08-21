//
//  Color.swift
//  Movter
//
//  Created by Nurtore on 22.03.2026.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
extension UIColor {

    // MARK: - Neutral ramp
    //
    // Five steps carry the entire interface. Posters are the only saturated thing on
    // screen, so nothing in the chrome competes with them.

    /// App background.
    static let canvas        = UIColor(hex: "0A0A0B")
    /// Cards, wells and any surface sitting on the canvas.
    static let surface       = UIColor(hex: "151517")
    /// Hairline borders and separators.
    static let hairline      = UIColor(hex: "2A2A2E")
    /// Titles and body copy. Slightly off pure white, which glares against near-black.
    static let textPrimary   = UIColor(hex: "F5F5F7")
    /// Captions, metadata, disabled states.
    static let textSecondary = UIColor(hex: "8A8A8F")

    /// Muted red for destructive actions — the one place colour still means "careful".
    static let destructive   = UIColor(hex: "D96A5A")

    /// The single accent. Follows the selected theme, so ratings, the active tab and
    /// every other emphasis point stay in step with one another.
    static var accent: UIColor { ThemeManager.shared.currentTheme.mainColor }

    /// Drawn on top of `accent`. Every theme accent is light, so this is the canvas.
    static var onAccent: UIColor { .canvas }
}
