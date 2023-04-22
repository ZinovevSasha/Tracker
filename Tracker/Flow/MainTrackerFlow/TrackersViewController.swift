import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .myWhite
        view.allowsSelection = true
        view.registerHeader(TrackerHeader.self)
        view.register(cellClass: TrackerCollectionViewCell.self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let placeholderView = PlaceholderView(state: .star)
  
    // MARK: - UIConstants
    private enum UIConstants {
        static let trackerHeaderHeight: CGFloat = 30
        static let inset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let topInset: CGFloat = 13
        static let collectionToStackOffset: CGFloat = 34
        static let headerHeight: CGFloat = 72
        static let searchHeight: CGFloat = 36
        static let searchLeading: CGFloat = 8
        static let searchTrailing: CGFloat = -8
        static let cellSpacing: CGFloat = 9
        static let cellHeight: CGFloat = 148
        static let cellCount = 2
    }
    
    // MARK: - Models
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            return try DataProvider(delegate: self)
        } catch {
            print("Данные недоступны")
            return nil
        }
    }()
    
    // Layout of collection helper
    private let params = GeometryParams(
        cellCount: UIConstants.cellCount,
        cellSize: .zero,
        leftInset: UIConstants.inset,
        rightInset: UIConstants.inset,
        topInset: .zero,
        bottomInset: .zero,
        spacing: UIConstants.cellSpacing
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialise()
        setDelegates()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let isEmpty = dataProvider?.isEmpty, isEmpty {
            placeholderView.state = .star
        } else {
            placeholderView.state = .invisible
        }
    }
    
    // MARK: - @objc target action methods
    func handlePlusButtonTap() {
        let trackerCreationViewController = ChooseTrackerViewController(
            categories: dataProvider?.getCategories() ?? [],
            from: self
        )
        let navVc = UINavigationController(rootViewController: trackerCreationViewController)
        navVc.isNavigationBarHidden = true
        navVc.interactivePopGestureRecognizer?.isEnabled = true
        present(navVc, animated: true)
    }
    
    @objc func hideKeyboard() {
        searchView.hideKeyboard()
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func initialise() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .myWhite
        view.addSubviews(headerView, searchView, collectionView, placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        searchView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setDelegates() {
        searchView.delegate = self
        headerView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setConstraints() {
        let headerViewConstraints = [
            headerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: UIConstants.topInset),
            headerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.inset),
            headerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.trailingInset),
            headerView.heightAnchor.constraint(
                equalToConstant: UIConstants.headerHeight)
        ]
        let searchViewConstraints = [
            searchView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: UIConstants.topInset),
            searchView.heightAnchor.constraint(equalToConstant: UIConstants.searchHeight),
            searchView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: UIConstants.searchLeading),
            searchView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: UIConstants.searchTrailing)
        ]
        let collectionViewConstraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(
                equalTo: searchView.bottomAnchor,
                constant: UIConstants.collectionToStackOffset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        let placeholderImageViewConstraints = [
            placeholderView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(
            headerViewConstraints +
            searchViewConstraints +
            collectionViewConstraints +
            placeholderImageViewConstraints
        )
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataProvider?.numberOfSections ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider?.numberOfRowsInSection(section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let tracker = dataProvider?.object(at: indexPath)
        let daysTracked = dataProvider?.daysTracked(for: indexPath)
        cell.configure(with: tracker)
        cell.configure(with: daysTracked)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: TrackerHeader = collectionView.dequeueHeader(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        header.configure(with: dataProvider?.header(for: indexPath.section) ?? "")
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.emptySpaceWidth
        let width = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: width, height: UIConstants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return UIConstants.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: UIConstants.trackerHeaderHeight)
    }
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func plusButtonTapped(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        try? dataProvider?.saveTrackerAsCompleted(by: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            try dataProvider?.deleteRecord(at: indexPath)
        } catch {
            print(error)
        }
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        do {
            try dataProvider?.fetchTrackersBy(date: date)
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
}

// MARK: - SearchViewDelegate
extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        do {
            try dataProvider?.fetchTrackersBy(name: searchText)
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
}

// MARK: - CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func addTrackerCategory(_ category: TrackerCategory) {
        do {
            try dataProvider?.addRecord(category)
        } catch {
            print(error)
        }
    }
}

// MARK: - DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func noResultFound() {
        placeholderView.state = .noResult
    }
    
    func resultFound() {
        placeholderView.state = .invisible
    }
    
    func didUpdate(_ update: DataProviderUpdate) {
        collectionView.performBatchUpdates {
            if !update.insertedIndexes.isEmpty {
                collectionView.insertItems(at: [update.insertedIndexes])
            }
            if !update.insertedSection.isEmpty {
                collectionView.insertSections(update.insertedSection)
            }
            if !update.deletedIndexes.isEmpty {
                collectionView.deleteItems(at: [update.deletedIndexes])
            }
            if !update.deletedIndexes.isEmpty {
                collectionView.deleteSections(update.deletedSection)
            }
            if !update.updatedIndexes.isEmpty {
                collectionView.reloadItems(at: [update.updatedIndexes])
            }
        }
    }
}
