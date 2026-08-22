//
//  FilmPickerViewController.swift
//  Movter
//
//  Created by Nurtore on 21.08.2026.
//

import UIKit

/// A catalogue title, or a name typed by hand.
enum FilmSelection {
    case catalogue(Media)
    case manual(title: String)
}

/// Search TMDB for the film being reviewed, with a hand-typed fallback for titles the
/// catalogue doesn't carry.
final class FilmPickerViewController: UIViewController {

    var onPick: ((FilmSelection) -> Void)?

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var results: [Media] = []
    private var pendingSearch: DispatchWorkItem?
    private var isSearching = false

    /// Bumped per keystroke so a slow response can't overwrite a newer one.
    private var currentSearchToken = 0

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .textSecondary
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        title = "Choose a Film"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search films"
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.searchTextField.textColor = .textPrimary
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = .hairline
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 96
        tableView.register(FilmResultCell.self, forCellReuseIdentifier: FilmResultCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(statusLabel)
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16)
        ])

        updateStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }

    // MARK: - Searching

    private var trimmedQuery: String {
        (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func scheduleSearch() {
        pendingSearch?.cancel()

        let query = trimmedQuery
        guard query.count >= 2 else {
            currentSearchToken += 1
            results = []
            isSearching = false
            spinner.stopAnimating()
            tableView.reloadData()
            updateStatus()
            return
        }

        // Debounced: one request per keystroke would burn the API budget.
        let work = DispatchWorkItem { [weak self] in self?.performSearch(query) }
        pendingSearch = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    private func performSearch(_ query: String) {
        currentSearchToken += 1
        let token = currentSearchToken
        isSearching = true
        spinner.startAnimating()
        updateStatus()

        NetworkService.shared.searchMovies(query: query, page: 1) { [weak self] page in
            guard let self = self, token == self.currentSearchToken else { return }
            self.isSearching = false
            self.spinner.stopAnimating()
            self.results = page?.items ?? []
            self.tableView.reloadData()
            self.updateStatus()
        }
    }

    private func updateStatus() {
        let query = trimmedQuery
        if isSearching {
            statusLabel.text = nil
        } else if query.isEmpty {
            statusLabel.text = "Search for the film you want to log."
        } else if query.count < 2 {
            statusLabel.text = "Keep typing…"
        } else if results.isEmpty {
            statusLabel.text = "Nothing found for “\(query)”."
        } else {
            statusLabel.text = nil
        }
        statusLabel.isHidden = statusLabel.text == nil
    }

    @objc private func cancelTapped() {
        close()
    }

    private func finish(with selection: FilmSelection) {
        onPick?(selection)
        close()
    }

    /// Dismisses from the presenter, not `self`: while the search bar is active the
    /// search controller is presented on top of this screen, so `self.dismiss` would
    /// only tear that down and leave the picker up.
    private func close() {
        searchController.searchBar.resignFirstResponder()
        let presenter = presentingViewController ?? self
        presenter.dismiss(animated: true)
    }
}

// MARK: - Search updating

extension FilmPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        scheduleSearch()
    }
}

// MARK: - Table

extension FilmPickerViewController: UITableViewDataSource, UITableViewDelegate {

    /// Section 1 is the hand-typed fallback, shown as soon as there's a name to add.
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? results.count : (trimmedQuery.isEmpty ? 0 : 1)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 96 : 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = .clear
            cell.textLabel?.text = "Add “\(trimmedQuery)” manually"
            cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            cell.textLabel?.textColor = .accent
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .default
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: FilmResultCell.identifier,
            for: indexPath
        ) as! FilmResultCell
        if let media = results[safe: indexPath.row] {
            cell.configure(with: media)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            finish(with: .manual(title: trimmedQuery))
        } else if let media = results[safe: indexPath.row] {
            finish(with: .catalogue(media))
        }
    }
}

/// A search hit: poster, title, year and TMDB score, to tell same-named films apart.
final class FilmResultCell: UITableViewCell {

    static let identifier = "FilmResultCell"

    private let posterView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.backgroundColor = .surface
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    /// Guards against a slow poster landing in a reused cell.
    private var posterURL: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = .surface
            return view
        }()

        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(posterView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            posterView.widthAnchor.constraint(equalToConstant: 48),
            posterView.heightAnchor.constraint(equalToConstant: 72),

            textStack.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterView.image = nil
        posterURL = nil
        titleLabel.text = nil
        metaLabel.attributedText = nil
    }

    func configure(with media: Media) {
        titleLabel.text = media.displayName
        metaLabel.attributedText = RatingFormatter.metadataLine(
            state: media.ratingState,
            year: media.year,
            genre: nil,
            font: .systemFont(ofSize: 13, weight: .regular)
        )

        guard let url = media.fullPosterURL else {
            posterView.image = UIImage(systemName: "film")
            posterView.tintColor = .textSecondary
            posterView.contentMode = .center
            return
        }
        posterView.contentMode = .scaleAspectFill
        posterURL = url
        ImageLoader.load(url: url) { [weak self] image in
            guard let self = self, self.posterURL == url else { return }
            self.posterView.image = image
        }
    }
}
