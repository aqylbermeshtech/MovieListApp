//
//  SearchMoviesController.swift
//  MovieListApp
//
//  Created by Nurtore on 01.05.2026.
//

import UIKit

final class SearchMoviesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let sections: [(title: String, items: [String])] = [
        (
            title: "Browse by",
            items: ["Release date", "Genre, country or language", "Service", "Most popular", "Highest Rated", "Most anticipated", "Coming soon", "Featured lists", "Official lists"]
        ),
        (
            title: "MoviesApp",
            items: ["New here?", "About Us", "Journal/Editorial", "Showdown Challenges", "Year in Review", "Contacts", "Social Accounts / Follow us", "Community Policy"]
        )
    ]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private func setupNavigationBar() {
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    override func viewDidLoad() {
        view.backgroundColor = .black
        setupSearchBar()
        setupNavigationBar()
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            // Прикрепляем таблицу прямо к safeArea, так как заголовки секций теперь внутри таблицы
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }

    // MARK: - TableView Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        header.textLabel?.textColor = .white

        header.textLabel?.frame = header.bounds
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        let chevronImage = UIImage(systemName: "chevron.right")
        let accessoryView = UIImageView(image: chevronImage)
        accessoryView.tintColor = .lightGray

        cell.accessoryView = accessoryView
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        cell.selectedBackgroundView = selectionView
        //hello okdsksdfsf
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = sections[indexPath.section].items[indexPath.row]
    }
}

extension SearchMoviesController: UISearchBarDelegate {
    
}
