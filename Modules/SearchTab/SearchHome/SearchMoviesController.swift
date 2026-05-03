//
//  SearchMoviesController.swift
//  MovieListApp
//
//  Created by Nurtore on 01.05.2026.
//

import UIKit

final class SearchMoviesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let menuItems = ["Release date", "Genre, country or language", "Service", "Most popular", "Highest Rated", "Most anticipated", "Coming soon", "Featured lists", "Official lists"]
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.text = "Browse by"
        label.textColor = .systemBackground
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .graphite
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    override func viewDidLoad() {
        view.backgroundColor = .black
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.backgroundColor = .clear
    }

    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.textColor = .systemBackground
        cell.backgroundColor = UIColor(white: 0.1, alpha: 1.0)

        let chevronImage = UIImage(systemName: "chevron.right")
        let accessoryView = UIImageView(image: chevronImage)

        accessoryView.tintColor = .systemBackground

        cell.accessoryView = accessoryView
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        cell.selectedBackgroundView = selectionView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
