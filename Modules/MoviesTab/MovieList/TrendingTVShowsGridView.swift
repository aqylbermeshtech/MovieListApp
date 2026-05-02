//
//  TrendingTVShowsGridView.swift
//  MovieListApp
//
//  Created by Nurtore on 02.05.2026.
//

import UIKit

final class TrendingTVShowsGridView: UIView {
    
    var onTVShowSelected: ((Media) -> Void)?
    private var TVShows: [Media] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending TV Shows"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.minimumInteritemSpacing = 10

        layout.minimumLineSpacing = 15
        layout.sectionInset = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.identifier)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .graphite
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with tvShows: [Media]) {
        self.TVShows = tvShows
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.collectionView.reloadData()
        }
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension TrendingTVShowsGridView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(TVShows.count, 9)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as! MediaCell
        cell.configure(with: TVShows[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns: CGFloat = 3
        let spacingBetweenCells: CGFloat = 10

        let totalWidth = collectionView.frame.width
        var widthToCalculate: CGFloat = totalWidth
        
        if totalWidth <= 0 {
            if let windowScene = self.window?.windowScene {
                widthToCalculate = windowScene.screen.bounds.width - 20
            } else {
                widthToCalculate = 375
            }
        }
        
        let totalSpacing = (numberOfColumns - 1) * spacingBetweenCells
        let itemWidth = (widthToCalculate - totalSpacing) / numberOfColumns
        
        return CGSize(width: floor(itemWidth), height: floor(itemWidth * 1.5))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTVShowSelected?(TVShows[indexPath.item])
    }
}
