import UIKit

final class MovieListViewController: UIViewController {
    private let viewModel = MovieListViewModel()
    
    let allData = ["Hail Mary", "Inception", "Jojo Bizzare Adventures", "Jango unchained"]
    
    let searchVC = SearchResultsViewController()
    
    lazy var searchController : UISearchController = {
        let sc = UISearchController(searchResultsController: searchVC)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.hidesNavigationBarDuringPresentation = false
        sc.searchBar.placeholder = "Search Movies"
        sc.searchBar.searchBarStyle = .minimal
        return sc
    }()
    
    private let trendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending"
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 300)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        cv.backgroundColor = .black
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isPagingEnabled = true
        title = "Movies"
        view.backgroundColor = .graphite
        setupUI()
        collectionView.delegate = self
        collectionView.dataSource = self
        bindViewModel()
        viewModel.fetchMovies()
        definesPresentationContext = true
    }
    
    func setupUI() {
        let searchBar = searchController.searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        view.addSubview(trendingLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 56),

            trendingLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trendingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trendingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 325)
        ])
    }
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension MovieListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCell.identifier,
            for: indexPath
        ) as! MovieCell

        let movie = viewModel.movie(at: indexPath.item)
        cell.configure(with: movie)

        return cell
    }
}

extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movie(at: indexPath.item)
        let vc = MovieDetailViewController(viewModel: MovieDetailViewModel(movie: movie))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MovieListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            return
        }
        let filtered = allData.filter { $0.lowercased().contains(text) }

        if let resultsController = searchController.searchResultsController as? SearchResultsViewController {
            resultsController.filteredData = filtered
        }
    }
}

