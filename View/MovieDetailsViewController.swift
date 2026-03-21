import UIKit

final class MovieDetailViewController: UIViewController {

    private let viewModel: MovieDetailViewModel

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let ratingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupUI()
        configure()
    }

    private func setupUI() {
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            ratingLabel,
            descriptionLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func configure() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        ratingLabel.text = viewModel.rating

        if let url = viewModel.imageURL {
            ImageLoader.load(url: url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }
}
