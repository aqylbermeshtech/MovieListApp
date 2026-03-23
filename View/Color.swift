//
//  Color.swift
//  MovieListApp
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
    static let appDarkTeal    = UIColor(hex: "02394A")
    static let midnightViolet   = UIColor(hex: "1f0318")
    static let graphite =        UIColor(hex:"39393A")
    static let appDustyDenim  = UIColor(hex: "748CAB")
    static let appTomato      = UIColor(hex: "F15946")
    static let alabasterGray = UIColor(hex: "CFDBD5")
    static let appSoftBlush   = UIColor(hex: "F4DBD8")
}
