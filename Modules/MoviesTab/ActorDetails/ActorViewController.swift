//
//  ActorViewController.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import UIKit

final class ActorViewController: UIViewController {

    private let viewModel: ActorViewModel

    private static let collapsedBiographyLines = 6

    init(viewModel: ActorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Views

    private let scrollView = UIScrollView()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 70
        iv.backgroundColor = .surface
        iv.tintColor = .textSecondary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let birthplaceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let biographyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .textPrimary
        label.numberOfLines = ActorViewController.collapsedBiographyLines
        return label
    }()

    private lazy var readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read more", for: .normal)
        button.setTitleColor(.accent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.addTarget(self, action: #selector(toggleBiography), for: .touchUpInside)
        return button
    }()

    private let filmographyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.text = "Filmography"
        label.textColor = .textPrimary
        return label
    }()

    private let emptyFilmographyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private lazy var filmographyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 10

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        // The whole screen is one scroll view, so the grid lays itself out at full
        // height instead of scrolling independently.
        cv.isScrollEnabled = false
        cv.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .textPrimary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private var filmographyHeightConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        title = viewModel.name

        filmographyCollectionView.delegate = self
        filmographyCollectionView.dataSource = self

        setupUI()
        render()

        loadingIndicator.startAnimating()
        viewModel.onUpdate = { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.render()
            self?.filmographyCollectionView.reloadData()
            self?.view.setNeedsLayout()
        }
        viewModel.load()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Item size depends on the grid's final width, so the content height is only
        // knowable after layout. Guarded to avoid re-triggering layout forever.
        let height = filmographyCollectionView.collectionViewLayout.collectionViewContentSize.height
        if abs(filmographyHeightConstraint.constant - height) > 0.5 {
            filmographyHeightConstraint.constant = height
        }
    }

    // MARK: - Rendering

    @objc private func themeDidChange() {
        readMoreButton.setTitleColor(.accent, for: .normal)
        filmographyCollectionView.reloadData()
    }

    private func render() {
        title = viewModel.name
        nameLabel.text = viewModel.name

        subtitleLabel.text = viewModel.subtitleText
        subtitleLabel.isHidden = viewModel.subtitleText == nil

        birthplaceLabel.text = viewModel.birthplaceText
        birthplaceLabel.isHidden = viewModel.birthplaceText == nil

        biographyLabel.text = viewModel.biographyText
        readMoreButton.isHidden = !(viewModel.hasBiography && isBiographyTruncated)

        filmographyLabel.text = viewModel.filmographyCountText
        emptyFilmographyLabel.text = viewModel.emptyFilmographyText
        // Only an actor with a genuinely empty filmography should see this — not everyone
        // during the frame between first render and the fetch completing.
        emptyFilmographyLabel.isHidden = !viewModel.hasLoaded || !viewModel.credits.isEmpty
        filmographyCollectionView.isHidden = viewModel.credits.isEmpty

        if let url = viewModel.profileURL {
            ImageLoader.load(url: url) { [weak self] image in
                DispatchQueue.main.async {
                    guard let image = image else {
                        self?.showProfilePlaceholder()
                        return
                    }
                    // The placeholder switches to .center, so restore the fill mode or the
                    // full-size portrait renders at native scale inside the 140pt circle.
                    self?.profileImageView.contentMode = .scaleAspectFill
                    self?.profileImageView.image = image
                }
            }
        } else {
            showProfilePlaceholder()
        }
    }

    private func showProfilePlaceholder() {
        profileImageView.image = UIImage(
            systemName: "person.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .regular)
        )
        profileImageView.contentMode = .center
    }

    /// True when the biography needs more room than the collapsed line limit allows.
    private var isBiographyTruncated: Bool {
        guard let text = biographyLabel.text, biographyLabel.bounds.width > 0 else { return true }
        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: biographyLabel.bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: biographyLabel.font as Any],
            context: nil
        )
        let lineHeight = biographyLabel.font.lineHeight
        return bounding.height > lineHeight * CGFloat(Self.collapsedBiographyLines) + 1
    }

    @objc private func toggleBiography() {
        let isCollapsed = biographyLabel.numberOfLines != 0
        biographyLabel.numberOfLines = isCollapsed ? 0 : Self.collapsedBiographyLines
        readMoreButton.setTitle(isCollapsed ? "Read less" : "Read more", for: .normal)
    }

    // MARK: - Layout

    private func setupUI() {
        let photoContainer = UIView()
        photoContainer.addSubview(profileImageView)

        let stack = UIStackView(arrangedSubviews: [
            photoContainer,
            nameLabel,
            subtitleLabel,
            birthplaceLabel,
            biographyLabel,
            readMoreButton,
            filmographyLabel,
            emptyFilmographyLabel,
            filmographyCollectionView
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(24, after: birthplaceLabel)
        stack.setCustomSpacing(24, after: readMoreButton)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // The scroll view runs to the bottom of the screen, so the tab bar's safe-area
        // inset has to become content inset or the last grid row sits under the tab bar.
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(stack)
        view.addSubview(loadingIndicator)

        filmographyHeightConstraint = filmographyCollectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            profileImageView.topAnchor.constraint(equalTo: photoContainer.topAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: photoContainer.bottomAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: photoContainer.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 140),
            profileImageView.heightAnchor.constraint(equalToConstant: 140),

            filmographyHeightConstraint,

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Filmography grid

extension ActorViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.credits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as? MediaCell,
              let credit = viewModel.credit(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        cell.configure(with: credit.asMedia)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 10
        let width = (collectionView.bounds.width - (columns - 1) * spacing) / columns
        // Poster is 1.5x its width; the rest covers the two-line title and the rating.
        return CGSize(width: floor(width), height: floor(width * 1.5) + 58)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let credit = viewModel.credit(at: indexPath.item) else { return }
        let detailVM = MediaDetailsViewModel(media: credit.asMedia)
        let detailVC = MediaDetailsViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
