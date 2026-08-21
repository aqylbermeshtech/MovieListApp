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
/// Two things make the reveal read as a curtain opening downward rather than the box
/// rearranging itself:
///
/// 1. The label is always laid out at its full height and pinned to the top only, so
///    its frame never changes — what animates is how much of it this view lets you
///    see. Pinning it top *and* bottom instead would let UILabel vertically centre the
///    text inside the growing box, so the paragraph would drift up while the box grew
///    down: movement in two directions at once.
/// 2. The fade dissolves over the same beat as the reveal. Removing it outright on tap
///    snapped the dimmed last line to full brightness while the box was still opening,
///    which read as a flash at the start of the animation.
final class ExpandableTextLabel: UIView {

    /// Invoked inside the expand/collapse animation. The owner should lay out whatever
    /// this view sits in — this block is in a scroll view whose content height moves
    /// with it, and only the owner can do that pass.
    var onToggle: (() -> Void)?

    /// Lines shown while collapsed.
    var collapsedLineLimit: Int = 4 {
        didSet { setNeedsLayout() }
    }

    /// What the text fades into. Defaults to the app background, which is the only
    /// thing this ever sits on today. It's a plain constant rather than a theme value
    /// — only `accent` follows the theme — so painting it is safe.
    var fadeColor: UIColor = .canvas {
        didSet { applyFadeColor() }
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
            measuredWidth = 0
            setNeedsLayout()
        }
    }

    var font: UIFont {
        get { label.font }
        set {
            label.font = newValue
            measuredWidth = 0
            setNeedsLayout()
        }
    }

    // MARK: - Views

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .textPrimary
        // Never changes: re-flowing the text on toggle would make it jump mid-animation
        // on top of everything else moving.
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Sits over the last line while collapsed. An overlay rather than a mask on the
    /// label, because a mask is sized from the view's final bounds and would sit at the
    /// wrong size for the whole animation — an overlay just rides the bottom edge down
    /// and fades out on the way.
    private let fadeView: GradientView = {
        let view = GradientView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var heightConstraint: NSLayoutConstraint!

    /// Height of the text if nothing limited it, at `measuredWidth`.
    private var fullTextHeight: CGFloat = 0
    /// The width the current measurement was taken at; a change invalidates it.
    private var measuredWidth: CGFloat = 0

    private var collapsedHeight: CGFloat {
        min(ceil(label.font.lineHeight * CGFloat(collapsedLineLimit)), fullTextHeight)
    }

    /// True when the text is genuinely longer than the collapsed limit. Everything —
    /// the fade, the tap, the button trait — hangs off this, so a two-line synopsis
    /// stays a plain paragraph with nothing to press.
    private var isTruncatable: Bool { fullTextHeight > collapsedHeight + 1 }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        // The label overflows this view while collapsed; the overflow is the part being
        // hidden, so it has to be clipped rather than drawn over the section below.
        clipsToBounds = true

        addSubview(label)
        addSubview(fadeView)

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .required - 1

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

            fadeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fadeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            fadeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fadeView.heightAnchor.constraint(equalToConstant: 34),

            heightConstraint
        ])

        applyFadeColor()
        fadeView.alpha = 0

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle)))
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // Re-measure only when the available width actually changes: on rotation or a
        // first pass, never on a frame of the reveal animation.
        guard bounds.width > 0, bounds.width != measuredWidth else { return }
        measuredWidth = bounds.width
        fullTextHeight = ceil(
            label.sizeThatFits(
                CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            ).height
        )
        updateHeight()
        fadeView.alpha = shouldShowFade ? 1 : 0
        updateAccessibility()
    }

    private var shouldShowFade: Bool { isTruncatable && !isExpanded }

    private func updateHeight() {
        let target = (isExpanded || !isTruncatable) ? fullTextHeight : collapsedHeight
        if heightConstraint.constant != target {
            heightConstraint.constant = target
        }
    }

    private func applyFadeColor() {
        fadeView.gradientLayer.colors = [
            fadeColor.withAlphaComponent(0).cgColor,
            fadeColor.cgColor
        ]
        fadeView.gradientLayer.locations = [0, 1]
    }

    private func updateAccessibility() {
        accessibilityTraits = isTruncatable ? .button : .staticText
        accessibilityHint = isTruncatable
            ? (isExpanded ? "Double tap to collapse" : "Double tap to read the rest")
            : nil
    }

    // MARK: - Toggle

    @objc private func toggle() {
        guard isTruncatable else { return }
        isExpanded.toggle()
        updateHeight()
        updateAccessibility()

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            // Both on the same beat: the box opens and the fade lifts together, so
            // there's no moment where the text brightens before it's uncovered.
            self.fadeView.alpha = self.shouldShowFade ? 1 : 0
            self.onToggle?()
        }
    }
}

/// A view whose backing layer is the gradient, so the gradient resizes with it instead
/// of needing its frame kept in sync by hand.
private final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}
