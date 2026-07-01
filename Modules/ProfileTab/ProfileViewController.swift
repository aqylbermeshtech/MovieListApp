//
//  ProfileViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 01.07.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    private let headerView = UIView()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .systemGray4
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupHeaderLayout()
        setupTableView()
        configureData()
        bindViewModel()
    }
    
    private func setupNavigationBar() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureData() {
        nameLabel.text = viewModel.userName
        emailLabel.text = viewModel.userEmail
        avatarImageView.image = UIImage(systemName: viewModel.avatarSystemName)
    }
    
    private func bindViewModel() {
        viewModel.onNavigationRequired = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .editProfile:
                print("Навигация: Открыть экран редактирования")
            case .notifications:
                print("Навигация: Открыть настройки уведомлений")
            case .privacyPolicy:
                print("Навигация: Открыть Web-страницу с политикой")
                
            case .changeTheme:
                self.showThemeSelectionAlert()
                
            case .logout:
                print("Навигация: Сбросить rootViewController на LoginViewController")
            }
        }
    }
    
    private func showThemeSelectionAlert() {
        let alert = UIAlertController(title: "Select App Theme", message: "Choose your favorite accent color", preferredStyle: .actionSheet)
        
        let classicAction = UIAlertAction(title: "Classic Blue", style: .default) { [weak self] _ in
            self?.viewModel.changeTheme(to: .classic)
        }
        
        let neonAction = UIAlertAction(title: "Neon Green", style: .default) { [weak self] _ in
            self?.viewModel.changeTheme(to: .neon)
        }
        
        let goldAction = UIAlertAction(title: "Dark Gold", style: .default) { [weak self] _ in
            self?.viewModel.changeTheme(to: .darkGold)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(classicAction)
        alert.addAction(neonAction)
        alert.addAction(goldAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func setupHeaderLayout() {
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(avatarImageView)
        headerView.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),

            infoStack.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 14),
            infoStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            infoStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            infoStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])

        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = headerView.systemLayoutSizeFitting(targetSize,
                                                               withHorizontalFittingPriority: .required,
                                                               verticalFittingPriority: .fittingSizeLevel)
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: estimatedSize.height)
        tableView.tableHeaderView = headerView
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfOptions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let option = viewModel.option(at: indexPath.row)
        
        cell.textLabel?.text = option.title
        cell.imageView?.image = UIImage(systemName: option.iconName)
        cell.textLabel?.textColor = option.type == .logout ? .systemRed : .white
        cell.imageView?.tintColor = option.type == .logout ? .systemRed : .white
        cell.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        cell.accessoryType = option.type == .logout ? .none : .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectOption(at: indexPath.row)
    }
}
