//
//  MovieDetailsViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import UIKit
import WebKit

final class MediaDetailsViewController: UIViewController {

    private let viewModel: MediaDetailsViewModel
    private let scrollView = UIScrollView()
    /// True once the poster has scrolled up behind the navigation bar.
    private var isBarCollapsed = false

    init(viewModel: MediaDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Runs edge to edge and up behind the navigation bar, so it carries no corner
    /// radius and sits outside the inset text stack.
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .graphiteSunken
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// "★ 7.9/10 · 2026 · Science Fiction"
    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 150)
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let videoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.text = "Trailer"
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let videoPlayerView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.clipsToBounds = true
        webView.layer.cornerRadius = 12
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let trailerPlaceholderView: UIView = {
        let container = UIView()
        container.backgroundColor = .graphiteSunken
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.alabasterGray.withAlphaComponent(0.16).cgColor
        container.isHidden = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let symbol = UIImage(
            systemName: "video.slash.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        )
        let iconView = UIImageView(image: symbol)
        iconView.tintColor = .appDustyDenim
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "No trailer yet"
        titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = .alabasterGray

        let subtitleLabel = UILabel()
        subtitleLabel.text = "We’ll show it here as soon as one is available"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .appDustyDenim
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.setCustomSpacing(16, after: iconView)
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .graphite
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        castCollectionView.register(ActorsCell.self, forCellWithReuseIdentifier: ActorsCell.identifier)
        setupUI()
        configure()
        bindViewModel()
        viewModel.fetchTrailer()
        viewModel.fetchActors()
        viewModel.fetchGenre()
    }
    
    private func configure() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.overview
        renderMetadata()

        if let url = viewModel.largeImageURL {
            ImageLoader.load(url: url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.onVideoUpdate = { [weak self] key in
            guard let self = self else { return }
            if let videoKey = key, let request = self.viewModel.youtubeRequest(for: videoKey) {
                self.videoPlayerView.isHidden = false
                self.trailerPlaceholderView.isHidden = true
                self.videoPlayerView.load(request)
            } else {
                self.videoPlayerView.isHidden = true
                self.trailerPlaceholderView.isHidden = false
            }
        }
        viewModel.onActorsUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.castCollectionView.reloadData()
            }
        }
        viewModel.onGenreUpdate = { [weak self] in
            DispatchQueue.main.async { self?.renderMetadata() }
        }
    }

    private func renderMetadata() {
        metadataLabel.attributedText = RatingFormatter.metadataLine(
            state: viewModel.ratingState,
            year: viewModel.year,
            genre: viewModel.genreName,
            font: metadataLabel.font
        )
    }
    
    private func loadYoutubeVideo(key: String) {
        let urlString = "https://www.youtube.com/embed/\(key)?enablejsapi=1&origin=https://www.themoviedb.org"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("https://www.themoviedb.org", forHTTPHeaderField: "Referer")
        videoPlayerView.load(request)
    }

    private func setupUI() {
        // The poster is pinned to the scroll view directly; only the text below it is
        // inset, which is what lets the artwork run edge to edge.
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            metadataLabel,
            descriptionLabel,
            castCollectionView,
            videoLabel,
            videoPlayerView,
            trailerPlaceholderView
        ])

        stack.axis = .vertical
        stack.spacing = 20
        stack.setCustomSpacing(10, after: titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Content starts at the very top of the screen, under the status and nav bars.
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            // TMDB posters are 2:3, so this shows the artwork uncropped.
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3.0 / 2.0),

            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            videoPlayerView.heightAnchor.constraint(equalTo: videoPlayerView.widthAnchor, multiplier: 9.0 / 16.0),
            trailerPlaceholderView.heightAnchor.constraint(equalTo: trailerPlaceholderView.widthAnchor, multiplier: 9.0 / 16.0),
            castCollectionView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // contentInsetAdjustmentBehavior is .never so the poster can reach the top, which
        // also means the tab bar's inset has to be applied by hand at the bottom.
        if scrollView.contentInset.bottom != view.safeAreaInsets.bottom {
            scrollView.contentInset.bottom = view.safeAreaInsets.bottom
        }
    }

    // MARK: - Navigation bar

    private static func transparentBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        return appearance
    }

    private static func opaqueBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .graphite
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        return appearance
    }

    private func applyBarAppearance(collapsed: Bool) {
        guard let bar = navigationController?.navigationBar else { return }
        let appearance = collapsed ? Self.opaqueBarAppearance() : Self.transparentBarAppearance()
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.tintColor = .white
        // The title only earns its place once the poster (which carries the name) is gone.
        navigationItem.title = collapsed ? viewModel.title : nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Transparent over the poster; collapses to opaque as it scrolls away.
        applyBarAppearance(collapsed: isBarCollapsed)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // The bar is shared with the rest of the tab, so hand it back opaque — this also
        // covers pushing onward to the actor screen, not just popping back.
        let opaque = Self.opaqueBarAppearance()
        navigationController?.navigationBar.standardAppearance = opaque
        navigationController?.navigationBar.scrollEdgeAppearance = opaque
        navigationController?.navigationBar.compactAppearance = opaque
    }
}

extension MediaDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // The cast collection view is also delegated to this object, and its horizontal
        // scrolling must not drive the navigation bar.
        guard scrollView === self.scrollView else { return }

        let barBottom = view.safeAreaInsets.top + (navigationController?.navigationBar.bounds.height ?? 44)
        let collapsed = scrollView.contentOffset.y > imageView.bounds.height - barBottom
        guard collapsed != isBarCollapsed else { return }

        isBarCollapsed = collapsed
        UIView.animate(withDuration: 0.2) { self.applyBarAppearance(collapsed: collapsed) }
    }
}

extension MediaDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.actors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActorsCell.identifier, for: indexPath) as? ActorsCell else {
            return UICollectionViewCell()
        }
        let actor = viewModel.actors[indexPath.item]
        cell.configure(with: actor)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel.actors.indices.contains(indexPath.item) else { return }
        let actor = viewModel.actors[indexPath.item]
        let actorVM = ActorViewModel(actorId: actor.id, name: actor.name)
        let actorVC = ActorViewController(viewModel: actorVM)
        navigationController?.pushViewController(actorVC, animated: true)
    }
}
