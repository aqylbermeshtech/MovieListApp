//
//  SearchMoviesController.swift
//  MovieListApp
//
//  Created by Nurtore on 01.05.2026.
//

import UIKit

final class SearchMoviesController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let chevronImage = UIImage(systemName: "chevron.right")
    
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
        
        tv.estimatedRowHeight = 44.0
        tv.rowHeight = UITableView.automaticDimension
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        let accessoryView = UIImageView(image: chevronImage)
        accessoryView.tintColor = .lightGray
        
        cell.accessoryView = accessoryView
        
        if cell.selectedBackgroundView == nil {
            let selectionView = UIView()
            selectionView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            cell.selectedBackgroundView = selectionView
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        
        var subItems:[String] = []
        
        
        switch selectedItem {
        case "Release date":
            subItems = ["2026", "2025", "2024", "2023", "2022", "2020s", "2010s", "2000s"]
            
        case "Genre, country or language":
            subItems = ["Action", "Comedy", "Drama", "Sci-Fi", "Thriller", "Horror", "Animation"]
            
        case "Service":
            subItems = ["Netflix", "HBO Max", "Apple TV+", "Disney+", "Amazon Prime"]
            
        case "Most popular":
            subItems = ["Popular Today", "Popular This Week", "All Time Popular"]
            
        case "Highest Rated":
            subItems = ["Top 250 Movies", "Top IMDb", "Critically Acclaimed"]
            
        case "Most anticipated":
            subItems = ["Coming This Month", "Most Hyped 2026", "Trending Preorders"]
            
        case "Coming soon":
            subItems = ["Theaters This Friday", "Streaming Next Week", "Announced Projects"]
            
        case "Featured lists":
            subItems = ["Oscar Winners", "Cannes Festival", "Best of Marvel", "Christopher Nolan Collection"]
            
        case "Official lists":
            subItems = ["TMDB Top Rated", "Letterboxd Top 250", "App Users Choice"]
            
        case "New here?":
            print("Открыть экран-приветствие или онбординг")
            // На будущее:
            // let welcomeVC = WelcomeViewController()
            // navigationController?.pushViewController(welcomeVC, animated: true)
            return
            
        case "About Us":
            print("Открыть экран с информацией о команде")
            return
            
        case "Journal/Editorial":
            print("Открыть блог или статьи редакции")
            return
            
        case "Showdown Challenges":
            print("Открыть игровой режим / челленджи приложения")
            return
            
        case "Year in Review":
            print("Открыть итоги года для пользователя")
            return
            
        case "Contacts":
            print("Открыть экран обратной связи")
            return
            
        case "Social Accounts / Follow us":
            print("Открыть ссылки на Telegram / Instagram приложения")
            return
            
        case "Community Policy":
            print("Открыть документ с правилами сообщества")
            return
            
        default:
            break
        }
        
        if !subItems.isEmpty {
            let subCategoryVC = SubcategoryViewController(title: selectedItem, items: subItems)
            navigationController?.pushViewController(subCategoryVC, animated: true)
        } else {
            print("Конечная точка: \(selectedItem)")
        }
    }
}


