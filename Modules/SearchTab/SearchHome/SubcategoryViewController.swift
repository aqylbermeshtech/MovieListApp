//
//  SubcategoryViewController.swift
//  MovieListApp
//
//  Created by Nurtore on 21.05.2026.
//

import UIKit

final class SubcategoryViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let items:[String]
    private let chevronImage = UIImage(systemName: "chevron.right")
    
    private let tableView = UITableView(frame:.zero, style:.plain)
    
    init(title:String, items:[String]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    required init?(coder: NSCoder) { fatalError() }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupTableView()
        
    }
        
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "subCell")
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCell", for: indexPath)

        cell.textLabel?.text = items[indexPath.row]
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
        
        let finalSelection = items[indexPath.row]
        let gridVC = MovieGridViewController(category: self.title ?? "", value: finalSelection)
        navigationController?.pushViewController(gridVC, animated: true)
    }
    
}
