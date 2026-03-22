import UIKit
import WebKit

final class MovieDetailViewController: UIViewController {

    private let viewModel: MovieDetailViewModel
    private let scrollView = UIScrollView()

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private let imageView: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 12
            iv.backgroundColor = .systemGray6
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()

        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 28, weight: .bold)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        private let ratingLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = .systemYellow
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        private let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    private let videoPlayerView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appDustyDenim

        setupUI()
        configure()
        bindViewModel() // 3. Bind the data
        viewModel.fetchTrailer()
    }
    private func configure() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.overview
        ratingLabel.text = String(format: "%.1f ⭐", viewModel.voteAverage)
        
        if let url = viewModel.imageURL {
            ImageLoader.load(url: url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.onVideoUpdate = { [weak self] key in
            guard let self = self, let videoKey = key else {
                self?.videoPlayerView.isHidden = true // Hide if no trailer exists
                return
            }
            self.loadYoutubeVideo(key: videoKey)
        }
    }
    
    private func loadYoutubeVideo(key: String) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(key)?autoplay=1&origin=https://www.themoviedb.org") else { return }
        videoPlayerView.load(URLRequest(url: url))
    }
    

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            ratingLabel,
            descriptionLabel,
            videoPlayerView
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            imageView.heightAnchor.constraint(equalToConstant: 450),
            videoPlayerView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}

