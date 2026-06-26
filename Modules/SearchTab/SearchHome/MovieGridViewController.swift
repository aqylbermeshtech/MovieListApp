//
//  MovieGridViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 27.06.2026.
//


import UIKit

final class MovieGridViewController: UIViewController {
    
    private let filterCategory: String
    private let filterValue: String
    
    private var movies: [Media] = []
    private var currentPage = 1
    private var isFetching = false
    private var hasMorePages = true
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    init(category: String, value: String) {
        self.filterCategory = category
        self.filterValue = value
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = filterValue
        view.backgroundColor = .black
        
        setupCollectionView()
        fetchMovies(page: currentPage)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchMovies(page: Int) {
        guard !isFetching && hasMorePages else { return }
        isFetching = true

        NetworkService.shared.fetchDiscoverMovies(category: filterCategory, value: filterValue, page: page) { [weak self] newMovies in
            guard let self = self else { return }
            
            if newMovies.isEmpty {
                self.hasMorePages = false
            } else {
                self.movies.append(contentsOf: newMovies)
                self.currentPage += 1
                self.collectionView.reloadData()
            }
            
            self.isFetching = false
        }
    }
}

extension MovieGridViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as! MediaCell
        let media = movies[indexPath.item]
        cell.configure(with: media)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 10
        
        let itemWidth = (totalWidth - (numberOfColumns - 1) * spacing) / numberOfColumns
        return CGSize(width: floor(itemWidth), height: floor(itemWidth * 1.5))
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height

        if position > (contentHeight - screenHeight - 100) {
            fetchMovies(page: currentPage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.item]
        print("Нажат фильм: \(selectedMovie.title)")
    }
}
