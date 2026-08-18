//
//  RatingStar.swift
//  MovieListApp
//
//  Created by Nurtore on 18.08.2026.
//

import UIKit

/// The app's rating star, drawn as a vector rather than shipped as an image asset or
/// borrowed from the emoji font: it tints from the palette, stays crisp at any size,
/// and looks identical on every OS version.
enum RatingStar {

    /// Ratio of the inner (valley) radius to the outer (tip) radius. The textbook
    /// pentagram value is 0.382, which goes spindly at label sizes — 0.47 keeps the
    /// arms thick enough to read at 13pt.
    private static let innerRadiusRatio: CGFloat = 0.47

    private static let cache = NSCache<NSString, UIImage>()

    static func image(pointSize: CGFloat, color: UIColor = .appAmber) -> UIImage {
        let key = "\(pointSize)-\(color.hashValue)" as NSString
        if let cached = cache.object(forKey: key) { return cached }

        let size = CGSize(width: pointSize, height: pointSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            let path = starPath(in: CGRect(origin: .zero, size: size))
            color.setFill()
            color.setStroke()
            path.fill()
            // Stroking the same path with a round join softens the five tips and the
            // five valleys, which stops them aliasing into fuzz when drawn small.
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

    /// Renders a rating the way its confidence deserves. `compact` drops the vote count
    /// for narrow contexts like a grid cell, where "· 4 votes" would truncate the score.
    static func attributedRating(
        _ state: RatingState,
        font: UIFont,
        textColor: UIColor,
        starColor: UIColor = .appAmber,
        compact: Bool = false
    ) -> NSAttributedString {
        switch state {
        case let .rated(score, _):
            return scoreLine(score: score, font: font, textColor: textColor, starColor: starColor)

        case let .provisional(score, votes):
            // Dimmed so a 10.0 off one vote doesn't read as loudly as a real 10.0.
            let line = NSMutableAttributedString(attributedString: scoreLine(
                score: score,
                font: font,
                textColor: .appDustyDenim,
                starColor: starColor.withAlphaComponent(0.45)
            ))
            if !compact {
                line.append(NSAttributedString(
                    string: "  · \(votes) vote\(votes == 1 ? "" : "s")",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: font.pointSize * 0.85, weight: .regular),
                        .foregroundColor: UIColor.appDustyDenim
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
    private static func label(_ text: String, font: UIFont, symbol: String? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString()

        if let symbol = symbol,
           let image = UIImage(systemName: symbol)?
            .withTintColor(.appDustyDenim, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment()
            attachment.image = image
            let size = (font.pointSize * 0.95).rounded()
            attachment.bounds = CGRect(x: 0, y: (font.capHeight - size) / 2, width: size, height: size)
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: "  "))
        }

        result.append(NSAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: UIColor.appDustyDenim]
        ))
        return result
    }

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL yyyy"
        return formatter
    }()
}
