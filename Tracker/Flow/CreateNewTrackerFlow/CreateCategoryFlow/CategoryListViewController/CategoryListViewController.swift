import UIKit

final class CategoryListViewController: FrameViewController {
    // MARK: - Call Back
    var trackerCategories: (([TrackerCategory], String, Int?) -> Void)?
    
    // MARK: - Private properties
    private let placeholder = PlaceholderView(
        placeholder: .star,
        text: "Привычки и события\n можно объединить по смыслу"
    )
    
    deinit {
        print(String(describing: self))
    }
    
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
    private var categories: [TrackerCategory] {
        didSet {
            categories.isEmpty ? placeholder.unhide() : placeholder.hide()
        }
    }
    private var lastRow: Int?
    
    // MARK: - Init
    init(categories: [TrackerCategory], lastRow: Int?) {
        self.categories = categories
        self.lastRow = lastRow
        categories.isEmpty ? placeholder.unhide() : placeholder.hide()
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
        let isImage = lastRow == indexPath.row
        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setCorners(in: tableView, at: indexPath)
        cell.configure(with: categories[indexPath.row].header, setImage: isImage)
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
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
            let header = categories[indexPath.row].header
            lastRow = indexPath.row
            trackerCategories?(categories, header, lastRow)
            tableView.reloadData()
//            dismiss(animated: true)
            navigationController?.popViewController(animated: true)
        }
    }
}
// MARK: - CreateNewCategoryViewControllerDelegate
extension CategoryListViewController: CreateNewCategoryViewControllerDelegate {
    func categoryNameDidEntered(categoryName name: String) {
        categories.append(TrackerCategory(header: name, trackers: []))
//        let isPreviousExist = categories.count - 1 > 0
//        var indexPathLast = [IndexPath(row: categories.count - 1, section: .zero)]
//        var indexPathLastAndPrevious = [IndexPath(row: categories.count - 1, section: .zero)]
//        if isPreviousExist {
//            indexPathLastAndPrevious.append(IndexPath(row: categories.count - 2, section: .zero))
//        }
//        tableView.insertRows(at: indexPathLast, with: .automatic)
//        tableView.reloadRows(at: indexPathLastAndPrevious, with: .automatic)
        tableView.reloadData()
    }
}
