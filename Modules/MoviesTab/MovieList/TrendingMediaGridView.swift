//
//  TrendingMoviesGridView.swift
//  MovieListApp
//
//  Created by Nurtore on 01.05.2026.
//

import UIKit

final class TrendingMediaGridView: UIView {
    var onMovieSelected: ((Media) -> Void)?
    var onArticleSelected: ((Article) -> Void)?
    private var movies: [Media] = []
    private var articles: [Article] = []
    private var isShowingArticles: Bool = false
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending Movies"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.identifier)
        cv.register(ArticlesCell.self, forCellWithReuseIdentifier: "ArticleCell")
        cv.backgroundColor = .clear
        cv.isScrollEnabled = true
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

    func update(with movies: [Media]) {
        self.isShowingArticles = false
        self.movies = movies
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func updateArticles(with articles: [Article]) {
        self.isShowingArticles = true
        self.articles = articles
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setSectionTitle(_ title: String) {
        UIView.transition(with: titleLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.titleLabel.text = title
        }, completion: nil)
    }
}

extension TrendingMediaGridView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isShowingArticles ? articles.count : min(movies.count, 9)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isShowingArticles {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticlesCell
            let article = articles[indexPath.item]
            cell.configure(with: article)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as! MediaCell
            let media = movies[indexPath.item]
            cell.configure(with: media)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width
        if isShowingArticles {
            return CGSize(width: totalWidth, height: 380)
        } else {
            let numberOfColumns: CGFloat = 3
            let spacing: CGFloat = 10
            let itemWidth = (totalWidth - (numberOfColumns - 1) * spacing) / numberOfColumns
            return CGSize(width: floor(itemWidth), height: floor(itemWidth * 1.5))
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isShowingArticles {
            onArticleSelected?(articles[indexPath.item])
        } else {
            onMovieSelected?(movies[indexPath.item])
        }
    }
}
