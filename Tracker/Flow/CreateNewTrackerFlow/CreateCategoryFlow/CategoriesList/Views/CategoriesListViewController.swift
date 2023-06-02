import UIKit

final class CategoriesListViewController: FrameViewController {
    // MARK: - Private properties
    private let placeholder = PlaceholderView(state: .recomendation)
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.separatorStyle = .singleLine
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: CategoryTableViewCell.self)
        return view
    }()
    
    // MARK: UIConstants
    private enum UIConstants {
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = -16
    }
    
    private var viewModel: CategoriesListViewModelProtocol?
    
    func set(viewModel: CategoriesListViewModelProtocol) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind() {
        guard let viewModel = viewModel as? CategoriesListViewModel else { return }
        viewModel.$categories.bind { [weak self] categories in            
            self?.tableView.reloadData()
            if !categories.isEmpty {
                self?.placeholder.state = .invisible(animate: false)
            } else {
                self?.placeholder.state = .recomendation
            }
        }
    }
    
    // MARK: - Init
    init() {
        super.init(
            title: Localized.CategoryList.category,
            buttonCenter: ActionButton(colorType: .black, title: Localized.CategoryList.newCategory)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.getAllCategories()
        setupUI()
        setupLayout()
    }
    
    // MARK: - Private @objc target action methods
    override internal func handleButtonCenterTap() {
        let createNewCategoryViewController = CreateNewCategoryViewController()
        createNewCategoryViewController.delegate = self
        present(createNewCategoryViewController, animated: true)
    }
}

// MARK: - Private Methods
private extension CategoriesListViewController {
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        container.addSubviews(tableView, placeholder)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: UIConstants.bottomInset)
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categories.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setCorners(in: tableView, at: indexPath)
        cell.viewModel = viewModel?.categories[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.categorySelected(at: indexPath)
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let action1 = UIAction(title: "Update") { _ in
                // Handle action
            }
            let action2 = UIAction(title: "Delete") { _ in
                // Handle action
            }
            let menu = UIMenu(title: "", children: [action1, action2])
            return menu
        }
        
        return configuration
    }
}

// MARK: - CreateNewCategoryViewControllerDelegate
extension CategoriesListViewController: CreateNewCategoryViewControllerDelegate {
    func isNameAvailable(name: String) -> Bool? {
        viewModel?.isNameAvailable(name: name)
    }
    
    func categoryNameDidEntered(categoryName name: String) {
        viewModel?.categoryNameEntered(name: name)
    }
}
