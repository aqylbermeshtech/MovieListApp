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
        let sc = UISegmentedControl(items: ["Movies", "TV Series", "Anime"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .systemBlue

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        
        sc.setTitleTextAttributes(normalAttributes, for: .normal)
        sc.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            // Привязываем контрол к краям нашей вью с небольшим отступом
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // MARK: - Actions
    @objc private func handleSegmentChange() {
        onSegmentChanged?(segmentedControl.selectedSegmentIndex)
    }
}
