import UIKit

final class CategoryListViewController: FrameViewController {
    // MARK: - Call Back
    var trackerCategories: (([TrackerCategory], String, Int?) -> Void)?
    
    // MARK: - Private properties
    private let placeholder = PlaceholderView(state: .recomendation)
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = UIConstants.topInset
        view.separatorColor = .myGray
        view.backgroundColor = .myWhite
        view.separatorStyle = .singleLine
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
   
    // MARK: - Data
    private var tempCategory: [TrackerCategory] = []
    private var lastRow: Int?
    
    // MARK: - Init
    init(tempCategory: [TrackerCategory], lastRow: Int?) {
        self.tempCategory = tempCategory
        self.lastRow = lastRow
        super.init(
            title: "Категория",
            buttonCenter: ActionButton(colorType: .black, title: "Добавить категорию")
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tempCategory.isEmpty {
            placeholder.state = .recomendation
        } else {
            placeholder.state = .invisible(animate: false)
        }
    }
    
    // MARK: - Private @objc target action methods
    override internal func handleButtonCenterTap() {
        let createNewCategoryViewController = CreateNewCategoryViewController()
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
            tableView.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: UIConstants.bottomInset
            )
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isImage = lastRow == indexPath.row
        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setCorners(in: tableView, at: indexPath)
        cell.configure(with: tempCategory[indexPath.row].header, setImage: isImage)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
            let header = tempCategory[indexPath.row].header
            lastRow = indexPath.row
            trackerCategories?(tempCategory, header, lastRow)
            tableView.reloadData()
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - CreateNewCategoryViewControllerDelegate
extension CategoryListViewController: CreateNewCategoryViewControllerDelegate {
    func isNameAvailable(name: String) -> Bool {
        !tempCategory.contains { $0.header == name }
    }
    
    func categoryNameDidEntered(categoryName name: String) {
        tempCategory.append(TrackerCategory(header: name, trackers: []))
        placeholder.state = .invisible(animate: false)
        tableView.reloadData()
    }
}
