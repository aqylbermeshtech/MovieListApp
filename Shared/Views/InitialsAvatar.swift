//
//  InitialsAvatar.swift
//  MovieListApp
//
//  Created by Nurtore on 18.08.2026.
//

import UIKit

/// Draws a per-user avatar from their initials. The colour is derived from the name
/// itself, so the same account always gets the same avatar instead of everyone sharing
/// one grey placeholder glyph.
enum InitialsAvatar {

    private static let palette: [UIColor] = [
        .appTomato, .appDustyDenim, .appAmber, .appDarkTeal, .midnightViolet
    ]

    static func image(name: String?, email: String?, size: CGFloat) -> UIImage {
        let initials = self.initials(name: name, email: email)
        let background = color(for: name?.isEmpty == false ? name! : (email ?? ""))

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            background.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size * 0.38, weight: .semibold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]

            let textSize = (initials as NSString).size(withAttributes: attributes)
            let rect = CGRect(
                x: 0,
                y: (size - textSize.height) / 2,
                width: size,
                height: textSize.height
            )
            (initials as NSString).draw(in: rect, withAttributes: attributes)
        }
    }

    /// "Ada Lovelace" -> "AL", "ada" -> "A", no name -> first letter of the email.
    private static func initials(name: String?, email: String?) -> String {
        let words = (name ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .filter { !$0.isEmpty }

        if !words.isEmpty {
            return words.prefix(2)
                .compactMap { $0.first.map(String.init) }
                .joined()
                .uppercased()
        }
        if let first = email?.trimmingCharacters(in: .whitespaces).first {
            return String(first).uppercased()
        }
        return "?"
    }

    /// Stable across launches — `hashValue` is seeded per process, so sum the scalars.
    private static func color(for seed: String) -> UIColor {
        guard !seed.isEmpty else { return .appDustyDenim }
        let total = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[total % palette.count]
    }
}
