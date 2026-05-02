//
//  MovieListViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import UIKit

final class MovieListViewController: UIViewController {
    
    private let viewModel = MovieListViewModel()
    private let trendingView = TrendingMoviesGridView()
    private let topSwitcher = TopSegmentedControlView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        view.backgroundColor = .black
        
        setupUI()
        bindViewModel()

        viewModel.fetchContent(type: .movies)
    }
    
    private func setupNavigationBar() {
        title = "MoviesApp"
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
        view.addSubview(topSwitcher)
        view.addSubview(trendingView)
        
        topSwitcher.translatesAutoresizingMaskIntoConstraints = false
        trendingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topSwitcher.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            topSwitcher.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSwitcher.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    
            trendingView.topAnchor.constraint(equalTo: topSwitcher.bottomAnchor, constant: 10),
            trendingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trendingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trendingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        trendingView.onMovieSelected = { [weak self] media in
            let detailVM = MovieDetailViewModel(media: media)
            let detailVC = MovieDetailViewController(viewModel: detailVM)
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
        topSwitcher.onSegmentChanged = { [weak self] index in
            guard let type = ContentType(rawValue: index) else { return }
            self?.viewModel.fetchContent(type: type)
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.trendingView.update(with: self?.viewModel.content ?? [])
            }
        }
    }
}
