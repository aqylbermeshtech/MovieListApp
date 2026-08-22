//
//  ScorePicker.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import UIKit

/// The 1–10 control the user scores a film with.
///
/// `value == 0` means "not scored yet" and is the starting state, so a score is always
/// a deliberate choice. `Review` only ever persists 1...10.
final class ScorePicker: UIControl {

    private static let starCount = 10
    private static let maximumStarSize: CGFloat = 30

    var value: Int = 0 {
        didSet {
            guard value != oldValue else { return }
            updateStars()
            accessibilityValue = accessibilityValueText
        }
    }

    private var starViews: [UIImageView] = []
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// Size the current images were drawn at; redraw only when it changes.
    private var renderedStarSize: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        starViews = (0..<Self.starCount).map { _ in
            let imageView = UIImageView()
            imageView.contentMode = .center
            return imageView
        }
        starViews.forEach { stack.addArrangedSubview($0) }
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        isAccessibilityElement = true
        accessibilityTraits = .adjustable
        accessibilityLabel = "Your score"
        accessibilityValue = accessibilityValueText

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.maximumStarSize + 8)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Sized from its slot so ten stars fit the narrowest phone.
        let slotWidth = bounds.width / CGFloat(Self.starCount)
        let starSize = min(Self.maximumStarSize, max(14, slotWidth - 6)).rounded()
        guard starSize != renderedStarSize else { return }
        renderedStarSize = starSize
        updateStars()
    }

    // MARK: - Rendering

    private func updateStars() {
        guard renderedStarSize > 0 else { return }
        let filled = RatingStar.image(pointSize: renderedStarSize, color: .accent)
        // A step above `hairline`, so the empty track reads as tappable.
        let empty = RatingStar.image(
            pointSize: renderedStarSize,
            color: UIColor.textSecondary.withAlphaComponent(0.3)
        )
        for (index, starView) in starViews.enumerated() {
            starView.image = index < value ? filled : empty
        }
    }

    @objc private func themeDidChange() {
        // `.accent` is rasterised into the image, so it can't repaint itself.
        updateStars()
    }

    // MARK: - Touch

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(for: touch)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(for: touch)
        return true
    }

    /// Drag scrubs the score; tapping alone would make an 8 an aiming exercise.
    private func updateValue(for touch: UITouch) {
        let x = touch.location(in: self).x
        let slotWidth = bounds.width / CGFloat(Self.starCount)
        guard slotWidth > 0 else { return }

        let newValue = Int((x / slotWidth).rounded(.up)).clamped(to: 1...Self.starCount)
        guard newValue != value else { return }

        value = newValue
        UISelectionFeedbackGenerator().selectionChanged()
        sendActions(for: .valueChanged)
    }

    // MARK: - Accessibility

    private var accessibilityValueText: String {
        value == 0 ? "Not scored" : "\(value) out of \(Self.starCount)"
    }

    override func accessibilityIncrement() {
        value = (value + 1).clamped(to: 1...Self.starCount)
        sendActions(for: .valueChanged)
    }

    override func accessibilityDecrement() {
        value = (value - 1).clamped(to: 1...Self.starCount)
        sendActions(for: .valueChanged)
    }
}
