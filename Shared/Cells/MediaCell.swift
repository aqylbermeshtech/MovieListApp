//
//  MovieCell.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import UIKit

final class MediaCell: UICollectionViewCell {
    static let identifier = "MediaCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .surface
        iv.tintColor = .textSecondary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .textPrimary
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textPrimary
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        titleLabel.text = nil
        ratingLabel.attributedText = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, ratingLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fill

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 1.5)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with media: Media) {
        titleLabel.text = media.displayName
        ratingLabel.attributedText = RatingFormatter.attributedRating(
            media.ratingState,
            font: ratingLabel.font,
            textColor: .textPrimary,
            compact: true
        )
        if let url = media.fullPosterURL {
            ImageLoader.load(url: url) { [weak self] image in
                DispatchQueue.main.async {
                    guard let image = image else {
                        self?.showPosterPlaceholder()
                        return
                    }
                    self?.imageView.contentMode = .scaleAspectFill
                    self?.imageView.image = image
                }
            }
        } else {
            showPosterPlaceholder()
        }
    }

    /// Plenty of TMDB credits — talk-show appearances especially — ship without artwork.
    private func showPosterPlaceholder() {
        imageView.contentMode = .center
        imageView.image = UIImage(
            systemName: "film",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        )
    }
}
