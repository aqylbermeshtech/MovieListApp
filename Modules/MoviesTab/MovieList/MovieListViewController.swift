//
//  MovieListViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//

import UIKit
import SafariServices

final class MediaListViewController: UIViewController {
    
    private let viewModel = MediaListViewModel()
    private let trendingView = TrendingMediaGridView()
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
            let detailVM = MediaDetailsViewModel(media: media)
            let detailVC = MediaDetailsViewController(viewModel: detailVM)
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
        trendingView.onArticleSelected = { [weak self] article in
            guard let url = URL(string: article.webUrl) else { return }

                let safariVC = SFSafariViewController(url: url)
                safariVC.preferredControlTintColor = .systemBlue 
                self?.present(safariVC, animated: true)
        }
        
        topSwitcher.onSegmentChanged = { [weak self] index in
            guard let self = self, let type = ContentType(rawValue: index) else { return }
            switch type {
            case .movies:
                self.trendingView.setSectionTitle("Trending Movies")
            case .tvSeries:
                self.trendingView.setSectionTitle("Trending TV Shows")
            case .articles:
                self.trendingView.setSectionTitle("Latest Film News") 
            }

            self.viewModel.fetchContent(type: type)
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .media(let media):
                    self?.trendingView.update(with: media)
                case .articles(let articles):
                    self?.trendingView.updateArticles(with: articles)
                }
            }
        }
    }
}
