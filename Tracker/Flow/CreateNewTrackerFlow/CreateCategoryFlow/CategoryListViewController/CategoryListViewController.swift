//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 08.04.2023.
//

import UIKit

final class CategoryListViewController: FrameViewController {
    // MARK: - Call Back
    var trackerCategories: (([TrackerCategory]) -> Void)?
    
    // MARK: - Private properties
    private let placeholder = PlaceholderView(
        placeholder: .star,
        text: "Привычки и события\n можно объединить по смыслу"
    )
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(cellClass: CategoryTableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = -16
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    // MARK: - Data
    private var categories: [TrackerCategory]
    
    // MARK: - Init
    init(categories: [TrackerCategory]) {
        self.categories = categories
        categories.isEmpty ? placeholder.unhide() : placeholder.hide()
        super.init(
            title: "Категория",
            buttonCenter: ActionButton(colorType: .black, title: "Добавить категорию")
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // @objc
    override func handleButtonCenterTap() {
        let createNewCategoryViewController = CreateNewCategoryViewController(categories: categories)
        createNewCategoryViewController.delegate = self
        present(createNewCategoryViewController, animated: true)
    }
}

// MARK: - Private Methods
private extension CategoryListViewController {
    func initialise() {
        tableView.delegate = self
        tableView.dataSource = self
        
        container.addSubview(tableView)
        container.addSubview(placeholder)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInset)
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setCellCorners(in: tableView, at: indexPath)
        cell.configure(with: categories[indexPath.section].header)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
}

// MARK: - CreateNewCategoryViewControllerDelegate
extension CategoryListViewController: CreateNewCategoryViewControllerDelegate {
    func categoryNameDidEntered(categoryName name: String) {
        categories.append(TrackerCategory(header: name, trackers: []))
        trackerCategories?(categories)
    }
}
