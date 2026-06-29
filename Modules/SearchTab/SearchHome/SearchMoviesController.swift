//
//  SearchMoviesController.swift
//  MovieListApp
//
//  Created by Nurtore on 01.05.2026.
//

import UIKit

final class SearchMoviesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = SearchMoviesViewModel()
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
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()
    }
    
    //MARK: - UI
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
        header.textLabel?.textColor = .white
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = viewModel.item(at: indexPath)
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
