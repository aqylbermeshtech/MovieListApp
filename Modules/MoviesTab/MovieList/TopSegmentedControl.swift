//
//  TopSegmentedControl.swift
//  MovieListApp
//
//  Created by Nurtore on 02.05.2026.
//

import UIKit

final class TopSegmentedControlView: UIView {
    var onSegmentChanged: ((Int) -> Void)?
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Movies", "TV Series", "Articles"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .surface
        sc.selectedSegmentTintColor = .accent
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.textSecondary,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        // The selected pill is filled with the accent, so its label has to be dark.
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.onAccent,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        sc.setTitleTextAttributes(normalAttributes, for: .normal)
        sc.setTitleTextAttributes(selectedAttributes, for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func handleSegmentChange() {
        onSegmentChanged?(segmentedControl.selectedSegmentIndex)
    }

    func updateTheme(with color: UIColor) {
        segmentedControl.selectedSegmentTintColor = color
    }
}
