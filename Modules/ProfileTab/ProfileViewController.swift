//
//  ProfileViewController.swift
//  Movter
//
//  Created by Nurtore on 01.07.2026.
//

import UIKit
import SafariServices

final class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    private let headerView = UIView()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let memberSinceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 1
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
        view.backgroundColor = .canvas
        setupNavigationBar()
        setupTableView()
        configureData()
        setupHeaderLayout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Edit Profile may have changed the Firebase user.
        configureData()
        viewModel.rebuildSections()
        tableView.reloadData()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false

        // The system's grouped background doesn't match the graphite content.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .canvas
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .textPrimary
    }

    private func configureData() {
        nameLabel.text = viewModel.userName
        emailLabel.text = viewModel.userEmail
        avatarImageView.image = viewModel.avatarImage

        memberSinceLabel.text = viewModel.memberSinceText
        memberSinceLabel.isHidden = viewModel.memberSinceText == nil
    }

    private func bindViewModel() {
        viewModel.onNavigationRequired = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .editProfile:
                self.showEditProfile()
            case .notifications:
                self.navigationController?.pushViewController(
                    NotificationSettingsViewController(), animated: true
                )
            case .privacyPolicy:
                self.showPrivacyPolicy()
            case .changeTheme:
                self.showThemeSelectionAlert()
            case .logout:
                self.confirmLogout()
            }
        }
    }

    private func showEditProfile() {
        let editVC = EditProfileViewController()
        editVC.onSave = { [weak self] in
            self?.configureData()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func showPrivacyPolicy() {
        let safariVC = SFSafariViewController(url: ProfileViewModel.privacyPolicyURL)
        safariVC.preferredControlTintColor = ThemeManager.shared.currentTheme.mainColor
        present(safariVC, animated: true)
    }

    private func confirmLogout() {
        // `.alert`, not `.actionSheet`: as a centred popover a sheet drops its cancel
        // action, leaving a destructive confirm with no way out.
        let alert = UIAlertController(
            title: "Log Out",
            message: "You'll need to sign in again to get back to your profile.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try viewModel.signOut()
        } catch {
            presentAlert(title: "Couldn't log out", message: error.localizedDescription)
            return
        }

        guard let window = view.window else { return }
        let loginNav = UINavigationController(rootViewController: LoginViewController())
        window.rootViewController = loginNav
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    private func showThemeSelectionAlert() {
        let alert = UIAlertController(
            title: "Select App Theme",
            message: "One accent, used everywhere",
            preferredStyle: .actionSheet
        )

        // No checkmark: the row's detail text already shows the active theme, and
        // marking one would mean poking a private UIAlertAction key.
        for theme in [AppTheme.mono, .amber, .slate] {
            alert.addAction(UIAlertAction(title: theme.displayName, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.changeTheme(to: theme)
                self.tableView.reloadData()
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentCentred(alert)
    }

    /// Action sheets need an anchor on iPad or they crash on presentation.
    private func presentCentred(_ alert: UIAlertController) {
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupHeaderLayout() {
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel, memberSinceLabel])
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
        // Keeps the last row clear of the floating tab bar.
        tableView.contentInsetAdjustmentBehavior = .always

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[safe: section]?.options.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[safe: section]?.header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let option = viewModel.option(at: indexPath) else { return cell }

        let isDestructive = option.type == .logout
        let tint: UIColor = isDestructive ? .destructive : .textPrimary

        // `valueCell` right-aligns the detail text and keeps the chevron.
        var content = option.detail == nil
            ? cell.defaultContentConfiguration()
            : UIListContentConfiguration.valueCell()
        content.text = option.title
        content.textProperties.color = tint
        content.secondaryText = option.detail
        content.secondaryTextProperties.color = .textSecondary
        content.image = UIImage(systemName: option.iconName)
        content.imageProperties.tintColor = tint
        cell.contentConfiguration = content

        cell.backgroundColor = .surface
        cell.accessoryType = isDestructive ? .none : .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectOption(at: indexPath)
    }

    /// Grouped-table headers default to a dark grey that disappears against graphite.
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .textSecondary
        header.textLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
    }
}
