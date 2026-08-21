//
//  SearchMoviesController.swift
//  Movter
//
//  Created by Nurtore on 01.05.2026.
//

import UIKit

final class SearchMoviesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = SearchMoviesViewModel()

    /// Typing fires a request per keystroke otherwise — this collapses a burst of them
    /// into one call once the user pauses.
    private var searchDebounce: DispatchWorkItem?
    private static let debounceInterval: TimeInterval = 0.4
    private let chevronImage = UIImage(systemName: "chevron.right")
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.estimatedRowHeight = 44.0
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .canvas
        setupNavigationBar()
        setupSearch()
        setupUI()
    }
    
    //MARK: - UI
    private func setupNavigationBar() {
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .canvas
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .textPrimary
    }
    
    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search films"
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.textColor = .textPrimary
        searchController.searchBar.tintColor = .textPrimary

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func showResults(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }

        // Don't stack duplicate result screens if the user keeps typing after a push.
        if let top = navigationController?.topViewController, top !== self { return }

        let resultsVC = MovieGridViewController(source: .search(trimmed), title: "“\(trimmed)”")
        navigationController?.pushViewController(resultsVC, animated: true)
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        header.textLabel?.textColor = .textPrimary
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = viewModel.item(at: indexPath)
        cell.textLabel?.textColor = .textPrimary
        cell.backgroundColor = .surface
        
        let accessoryView = UIImageView(image: chevronImage)
        accessoryView.tintColor = .textSecondary
        cell.accessoryView = accessoryView
        
        if cell.selectedBackgroundView == nil {
            let selectionView = UIView()
            selectionView.backgroundColor = .hairline
            cell.selectedBackgroundView = selectionView
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let target = viewModel.handleSelection(at: indexPath) else { return }

        switch target {
        case .subcategory(let title, let items):
            let subCategoryVC = SubcategoryViewController(title: title, items: items)
            navigationController?.pushViewController(subCategoryVC, animated: true)
            
        case .infoAction(let title, let description):
            print("Лог действия [\(title)]: \(description)")

        }
    }
}

extension SearchMoviesController: UISearchResultsUpdating, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        searchDebounce?.cancel()
        guard let text = searchController.searchBar.text,
              text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else { return }

        let work = DispatchWorkItem { [weak self] in self?.showResults(for: text) }
        searchDebounce = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.debounceInterval, execute: work)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // An explicit return shouldn't wait out the debounce.
        searchDebounce?.cancel()
        searchBar.resignFirstResponder()
        showResults(for: searchBar.text ?? "")
    }
}
