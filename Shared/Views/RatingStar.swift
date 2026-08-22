//
//  RatingStar.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import UIKit

/// The rating star, drawn as a vector rather than an asset or the emoji glyph, so it
/// tints from the palette and looks identical on every OS version.
enum RatingStar {

    /// Inner/outer radius ratio. The textbook 0.382 goes spindly at label sizes.
    private static let innerRadiusRatio: CGFloat = 0.47

    private static let cache = NSCache<NSString, UIImage>()

    static func image(pointSize: CGFloat, color: UIColor = .accent) -> UIImage {
        let key = "\(pointSize)-\(color.hashValue)" as NSString
        if let cached = cache.object(forKey: key) { return cached }

        let size = CGSize(width: pointSize, height: pointSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            let path = starPath(in: CGRect(origin: .zero, size: size))
            color.setFill()
            color.setStroke()
            path.fill()
            // Round join softens the tips, which otherwise alias into fuzz when small.
            path.lineWidth = pointSize * 0.07
            path.lineJoinStyle = .round
            path.stroke()
        }.withRenderingMode(.alwaysOriginal)

        cache.setObject(image, forKey: key)
        return image
    }

    private static func starPath(in rect: CGRect) -> UIBezierPath {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // Inset by the stroke so the rounded tips stay inside the image bounds.
        let outerRadius = rect.width / 2 - rect.width * 0.045
        let innerRadius = outerRadius * innerRadiusRatio

        let path = UIBezierPath()
        for corner in 0..<5 {
            let tipAngle = -CGFloat.pi / 2 + CGFloat(corner) * 2 * .pi / 5
            let valleyAngle = tipAngle + .pi / 5

            let tip = CGPoint(
                x: center.x + cos(tipAngle) * outerRadius,
                y: center.y + sin(tipAngle) * outerRadius
            )
            let valley = CGPoint(
                x: center.x + cos(valleyAngle) * innerRadius,
                y: center.y + sin(valleyAngle) * innerRadius
            )

            corner == 0 ? path.move(to: tip) : path.addLine(to: tip)
            path.addLine(to: valley)
        }
        path.close()
        return path
    }
}

enum RatingFormatter {

    /// `compact` drops the vote count for narrow contexts like a grid cell.
    static func attributedRating(
        _ state: RatingState,
        font: UIFont,
        textColor: UIColor,
        starColor: UIColor = .accent,
        compact: Bool = false
    ) -> NSAttributedString {
        switch state {
        case let .rated(score, _):
            return scoreLine(score: score, font: font, textColor: textColor, starColor: starColor)

        case let .provisional(score, votes):
            // Dimmed so a 10.0 off one vote doesn't read as loudly as a real one.
            let line = NSMutableAttributedString(attributedString: scoreLine(
                score: score,
                font: font,
                textColor: .textSecondary,
                starColor: starColor.withAlphaComponent(0.45)
            ))
            if !compact {
                line.append(NSAttributedString(
                    string: "  · \(votes) vote\(votes == 1 ? "" : "s")",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: font.pointSize * 0.85, weight: .regular),
                        .foregroundColor: UIColor.textSecondary
                    ]
                ))
            }
            return line

        case .unrated:
            return label("Not rated", font: font)

        case let .upcoming(releaseDate):
            guard let releaseDate = releaseDate else {
                return label("Announced", font: font, symbol: "calendar")
            }
            return label(monthYearFormatter.string(from: releaseDate), font: font, symbol: "calendar")
        }
    }


    /// "★ 7.9/10 · 2026 · Science Fiction"; missing pieces drop with their separator.
    static func metadataLine(
        state: RatingState,
        year: String?,
        genre: String?,
        font: UIFont
    ) -> NSAttributedString {
        var chips: [NSAttributedString] = []

        switch state {
        case let .rated(score, _):
            chips.append(scoreChip(score: score, font: font, textColor: .textPrimary, starColor: .accent))
        case let .provisional(score, _):
            chips.append(scoreChip(
                score: score, font: font,
                textColor: .textSecondary,
                starColor: UIColor.accent.withAlphaComponent(0.45)
            ))
        case .unrated:
            chips.append(label("Not rated", font: font))
        case .upcoming:
            // The year already says "not out yet".
            break
        }

        if let year = year {
            chips.append(label(year, font: font, symbol: "calendar", textColor: .textPrimary))
        }
        if let genre = genre, !genre.isEmpty {
            chips.append(label(genre, font: font, symbol: "film", textColor: .textPrimary))
        }

        let separator = NSAttributedString(
            string: "   ·   ",
            attributes: [.font: font, .foregroundColor: UIColor.textSecondary]
        )
        let line = NSMutableAttributedString()
        for (index, chip) in chips.enumerated() {
            if index > 0 { line.append(separator) }
            line.append(chip)
        }
        return line
    }

    private static func scoreChip(
        score: Double,
        font: UIFont,
        textColor: UIColor,
        starColor: UIColor
    ) -> NSAttributedString {
        let line = NSMutableAttributedString(attributedString: scoreLine(
            score: score, font: font, textColor: textColor, starColor: starColor
        ))
        line.append(NSAttributedString(
            string: "/10",
            attributes: [.font: font, .foregroundColor: UIColor.textSecondary]
        ))
        return line
    }

    // MARK: - Pieces

    private static func scoreLine(
        score: Double,
        font: UIFont,
        textColor: UIColor,
        starColor: UIColor
    ) -> NSAttributedString {
        let starSize = (font.pointSize * 1.05).rounded()

        let attachment = NSTextAttachment()
        attachment.image = RatingStar.image(pointSize: starSize, color: starColor)
        attachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - starSize) / 2,
            width: starSize,
            height: starSize
        )

        let result = NSMutableAttributedString(attachment: attachment)
        result.append(NSAttributedString(
            string: String(format: "  %.1f", score),
            attributes: [.font: font, .foregroundColor: textColor]
        ))
        return result
    }

    /// A non-score state: muted text, optionally led by an SF Symbol.
    private static func label(
        _ text: String,
        font: UIFont,
        symbol: String? = nil,
        textColor: UIColor = .textSecondary
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()

        if let symbol = symbol,
           let image = UIImage(systemName: symbol)?
            .withTintColor(.textSecondary, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment()
            attachment.image = image
            let size = (font.pointSize * 0.95).rounded()
            attachment.bounds = CGRect(x: 0, y: (font.capHeight - size) / 2, width: size, height: size)
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: "  "))
        }

        result.append(NSAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: textColor]
        ))
        return result
    }

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL yyyy"
        return formatter
    }()
}

extension RatingFormatter {

    /// The user's own score, as "★ 8/10". Unlike `attributedRating` it never dims —
    /// a personal score has no vote count to hedge about.
    static func attributedPersonalScore(
        _ score: Int,
        font: UIFont,
        textColor: UIColor = .textPrimary,
        starColor: UIColor = .accent
    ) -> NSAttributedString {
        let starSize = (font.pointSize * 1.05).rounded()

        let attachment = NSTextAttachment()
        attachment.image = RatingStar.image(pointSize: starSize, color: starColor)
        attachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - starSize) / 2,
            width: starSize,
            height: starSize
        )

        let result = NSMutableAttributedString(attachment: attachment)
        result.append(NSAttributedString(
            string: "  \(score)",
            attributes: [.font: font, .foregroundColor: textColor]
        ))
        result.append(NSAttributedString(
            string: "/10",
            attributes: [.font: font, .foregroundColor: UIColor.textSecondary]
        ))
        return result
    }
}
