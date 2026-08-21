//
//  MovieGridViewController.swift
//  Movter
//
//  Created by Nurtore on 27.06.2026.
//

import UIKit

/// Where a grid of results comes from — a browse selection or a typed query.
enum MediaQuerySource {
    case discover(DiscoverQuery)
    case search(String)
    /// A browse row with no TMDB filter behind it, so the screen can say so plainly
    /// instead of listing the entire catalogue as if it were a curated result.
    case unsupported
}

final class MovieGridViewController: UIViewController {

    private let source: MediaQuerySource

    private var movies: [Media] = []
    private var currentPage = 1
    private var isFetching = false
    private var hasMorePages = true
    private var didFail = false

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 10

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.identifier)
        cv.contentInsetAdjustmentBehavior = .always
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .textSecondary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(source: MediaQuerySource, title: String) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    /// Browse entry point: resolves the category/value pair into a real query.
    convenience init(category: String, value: String) {
        let query = DiscoverQuery.make(category: category, value: value)
        self.init(source: query.map(MediaQuerySource.discover) ?? .unsupported, title: value)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        setupUI()

        if case .unsupported = source {
            showEmptyState("This list isn’t available yet.\nIt needs curated data the app doesn’t have.")
            return
        }
        loadingIndicator.startAnimating()
        fetchNextPage()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)
        collectionView.delegate = self
        collectionView.dataSource = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func showEmptyState(_ text: String) {
        emptyLabel.text = text
        emptyLabel.isHidden = false
        collectionView.isHidden = true
        loadingIndicator.stopAnimating()
    }

    // MARK: - Loading

    private func fetchNextPage() {
        guard !isFetching, hasMorePages else { return }
        isFetching = true
        let page = currentPage

        let handler: (MediaPage?) -> Void = { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            self.loadingIndicator.stopAnimating()

            guard let result = result else {
                // Only surface a failure if there's nothing on screen already; a failed
                // page 3 shouldn't wipe out the two pages the user is looking at.
                self.hasMorePages = false
                if self.movies.isEmpty {
                    self.didFail = true
                    self.showEmptyState("Couldn’t load results.\nCheck your connection and try again.")
                }
                return
            }

            self.movies.append(contentsOf: result.items)
            self.hasMorePages = !result.isLastPage
            self.currentPage += 1

            if self.movies.isEmpty {
                self.showEmptyState(self.noResultsText)
            } else {
                self.collectionView.isHidden = false
                self.emptyLabel.isHidden = true
                self.collectionView.reloadData()
            }
        }

        switch source {
        case let .discover(query):
            NetworkService.shared.fetchDiscover(query: query, page: page, completion: handler)
        case let .search(text):
            NetworkService.shared.searchMovies(query: text, page: page, completion: handler)
        case .unsupported:
            isFetching = false
        }
    }

    private var noResultsText: String {
        if case let .search(text) = source {
            return "No films match “\(text)”."
        }
        return "Nothing here yet."
    }
}

extension MovieGridViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as? MediaCell,
              let media = movies[safe: indexPath.item] else {
            return UICollectionViewCell()
        }
        cell.configure(with: media)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 10
        let width = (collectionView.bounds.width - (columns - 1) * spacing) / columns
        // Poster is 1.5x its width; the rest covers the title and the rating line.
        return CGSize(width: floor(width), height: floor(width * 1.5) + 58)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height
        guard remaining < 400 else { return }
        fetchNextPage()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let media = movies[safe: indexPath.item] else { return }
        let detailVC = MediaDetailsViewController(viewModel: MediaDetailsViewModel(media: media))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
