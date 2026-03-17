import UIKit

final class MovieListViewController: UIViewController {

    private let viewModel = MovieListViewModel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 250)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Movies"
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        collectionView.frame = view.bounds

        bindViewModel()
        viewModel.fetchMovies()
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
