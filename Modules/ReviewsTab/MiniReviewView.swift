//
//  MiniReviewView.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import UIKit

/// A compact score-and-opinion card for the details screen.
///
/// The short form of `ReviewEditorViewController`: no film picker, because the film is
/// whatever screen you're standing on, and no navigation, because rating something you
/// are already looking at shouldn't cost a modal. It writes to the same store, so an
/// opinion left here is the same record the Reviews tab lists and edits.
final class MiniReviewView: UIView {

    /// Score and opinion text, once the user commits them.
    var onSave: ((Int, String) -> Void)?

    private var hasExistingReview = false

    // MARK: - Views

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = .surface
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var scorePicker: ScorePicker = {
        let picker = ScorePicker()
        picker.addTarget(self, action: #selector(scoreChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let scoreValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .textSecondary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .textPrimary
        textView.backgroundColor = .canvas
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false

        // A text view has no return-key dismissal, so without this the keyboard can
        // strand the user halfway down a scrolling details screen.
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        toolbar.barStyle = .black
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        ]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a short opinion (optional)"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .accent
        config.baseForegroundColor = .onAccent
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 18, bottom: 11, trailing: 18)

        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        let scoreRow = UIStackView(arrangedSubviews: [scorePicker, scoreValueLabel])
        scoreRow.axis = .horizontal
        scoreRow.spacing = 10
        scoreRow.alignment = .center

        textView.addSubview(placeholderLabel)

        let stack = UIStackView(arrangedSubviews: [scoreRow, textView, saveButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(8, after: saveButton)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(card)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            // Three lines or so: enough for a real thought, short enough that it reads
            // as a note rather than the full editor.
            textView.heightAnchor.constraint(equalToConstant: 76),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 15)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )

        render()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configuration

    /// Shows the user's existing review, or an empty card if they haven't written one.
    func configure(with review: Review?) {
        hasExistingReview = review != nil
        scorePicker.value = review?.score ?? 0
        textView.text = review?.reviewText ?? ""
        statusLabel.text = nil
        render()
    }

    /// The text view is the only thing here that takes the keyboard.
    var isEditingOpinion: Bool { textView.isFirstResponder }

    // MARK: - State

    private func render() {
        let score = scorePicker.value
        scoreValueLabel.text = score == 0 ? "Tap to rate" : "\(score)/10"
        scoreValueLabel.textColor = score == 0 ? .textSecondary : .textPrimary

        placeholderLabel.isHidden = !textView.text.isEmpty

        // Same rule as the full editor: a score is required, the words are optional.
        let canSave = Review.scoreRange.contains(score)
        saveButton.isEnabled = canSave
        saveButton.configuration?.title = hasExistingReview ? "Update Review" : "Save Review"
        saveButton.configuration?.baseBackgroundColor = canSave ? .accent : .canvas
        saveButton.configuration?.baseForegroundColor = canSave ? .onAccent : .textSecondary

        statusLabel.isHidden = statusLabel.text == nil
    }

    func showSaved() {
        hasExistingReview = true
        statusLabel.text = "Saved to your reviews."
        render()
    }

    func showError(_ message: String) {
        statusLabel.text = message
        render()
    }

    func setSaving(_ isSaving: Bool) {
        saveButton.configuration?.showsActivityIndicator = isSaving
        if isSaving { saveButton.configuration?.title = nil }
        saveButton.isEnabled = !isSaving && Review.scoreRange.contains(scorePicker.value)
        if !isSaving { render() }
    }

    // MARK: - Actions

    @objc private func scoreChanged() {
        // Any change invalidates a previous "Saved" note — it no longer describes
        // what's on screen.
        statusLabel.text = nil
        render()
    }

    @objc private func saveTapped() {
        guard Review.scoreRange.contains(scorePicker.value) else { return }
        dismissKeyboard()
        onSave?(scorePicker.value, textView.text)
    }

    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }

    @objc private func themeDidChange() {
        render()
    }
}

// MARK: - Text view

extension MiniReviewView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        statusLabel.text = nil
        render()
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        let current = textView.text ?? ""
        guard let range = Range(range, in: current) else { return true }
        return current.replacingCharacters(in: range, with: text).count
            <= ReviewEditorViewModel.maxReviewLength
    }
}
