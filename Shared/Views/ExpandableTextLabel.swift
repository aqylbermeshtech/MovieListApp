//
//  ExpandableTextLabel.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import UIKit

/// A block of text that shows a few lines, fades out at the cut, and opens to its full
/// length when tapped.
///
/// The fade is a mask on the label rather than a gradient view laid over it, so the
/// text dissolves into whatever is behind it instead of into one hard-coded colour —
/// which matters here, where the background is a theme value rather than a constant.
final class ExpandableTextLabel: UIView {

    /// Called after the expanded state flips, so the owner can animate the layout
    /// change. The view deliberately doesn't animate itself: it sits inside a scroll
    /// view whose content height moves with it, and only the owner knows that.
    var onToggle: (() -> Void)?

    /// Lines shown while collapsed.
    var collapsedLineLimit: Int = 4 {
        didSet { setNeedsLayout() }
    }

    private(set) var isExpanded = false

    var text: String? {
        get { label.text }
        set {
            label.text = newValue
            // A fresh title starts collapsed — carrying the previous one's expanded
            // state over to a different film would be arbitrary.
            isExpanded = false
            accessibilityLabel = newValue
            setNeedsLayout()
        }
    }

    var font: UIFont {
        get { label.font }
        set { label.font = newValue; setNeedsLayout() }
    }

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .textPrimary
        label.numberOfLines = 0
        // Clipping rather than an ellipsis: a "…" under a fade reads as two different
        // answers to the same question.
        label.lineBreakMode = .byClipping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fadeLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        // Mask alpha, not paint: opaque for most of the block, clear at the bottom edge.
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        gradient.locations = [0, 0.6, 1]
        return gradient
    }()

    /// True when the text is genuinely longer than the collapsed limit. Everything —
    /// the fade, the tap, the button trait — hangs off this, so a two-line synopsis
    /// stays a plain paragraph with nothing to press.
    private var isTruncatable = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle)))
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshTruncationState()

        guard !isExpanded, isTruncatable else {
            label.layer.mask = nil
            return
        }
        // The mask has to track the label as the block resizes, and implicit animation
        // would leave it lagging a frame behind during the expand.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fadeLayer.frame = label.bounds
        CATransaction.commit()
        label.layer.mask = fadeLayer
    }

    private func refreshTruncationState() {
        let limit = isExpanded ? 0 : collapsedLineLimit
        if label.numberOfLines != limit {
            label.numberOfLines = limit
        }

        let wasTruncatable = isTruncatable
        isTruncatable = measuredLineCount() > collapsedLineLimit

        if wasTruncatable != isTruncatable {
            accessibilityTraits = isTruncatable ? .button : .staticText
        }
        accessibilityHint = isTruncatable
            ? (isExpanded ? "Double tap to collapse" : "Double tap to read the rest")
            : nil
    }

    /// How many lines the text would take if nothing limited it. `sizeThatFits` can't
    /// answer this — it honours `numberOfLines`, which is exactly what's being tested.
    private func measuredLineCount() -> Int {
        guard let text = label.text, !text.isEmpty, bounds.width > 0 else { return 0 }
        let height = (text as NSString).boundingRect(
            with: CGSize(width: bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: label.font as Any],
            context: nil
        ).height
        return Int((height / label.font.lineHeight).rounded())
    }

    // MARK: - Toggle

    @objc private func toggle() {
        guard isTruncatable else { return }
        isExpanded.toggle()
        label.numberOfLines = isExpanded ? 0 : collapsedLineLimit
        // Drop the mask up front so the text is fully lit as it opens, rather than
        // fading back in once the animation has finished.
        if isExpanded { label.layer.mask = nil }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        onToggle?()
    }
}
