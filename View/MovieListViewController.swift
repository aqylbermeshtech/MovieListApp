//
//  MovieListViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import UIKit

final class MovieListViewController: UIViewController {
    
    private let viewModel = MovieListViewModel()
    private let trendingView = TrendingGridView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupTrendingView()
        bindViewModel() 
        
        viewModel.fetchMovies()
    }
    
    private func setupTrendingView() {
        view.addSubview(trendingView)
        trendingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trendingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trendingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trendingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trendingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        trendingView.onMovieSelected = { [weak self] movie in
            let detailVM = MovieDetailViewModel(movie: movie)
            let detailVC = MovieDetailViewController(viewModel: detailVM)
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.trendingView.update(with: self?.viewModel.movies ?? [])
            }
        }
    }
}
