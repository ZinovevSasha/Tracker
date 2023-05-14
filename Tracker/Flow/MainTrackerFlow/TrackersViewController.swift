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
        return view
    }()
    let placeholderView = PlaceholderView(state: .question)
            
    // MARK: - UIConstants
    private enum UIConstants {
        static let trackerHeaderHeight: CGFloat = 30
        static let inset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let topInset: CGFloat = 13
        static let collectionToSearchViewOffset: CGFloat = 10
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
    
    private var currentDay = Date()
    private var weekDayNumber: String {
        String(Date.currentWeekDayNumber(from: currentDay))
    }
    private var dateString: String {
        Date.dateString(for: currentDay)
    }
    
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
        setupUI()
        setDelegates()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let isEmpty = dataProvider?.isEmpty, isEmpty {
            placeholderView.state = .question
        } else {
            placeholderView.state = .invisible(animate: false)
        }
    }
    
    // MARK: - @objc target action methods
    func handlePlusButtonTap() {
        let trackerCreationViewController = ChooseTrackerViewController(date: dateString)
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
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .myWhite
        view.addSubviews(headerView, searchView, collectionView, placeholderView)
    }
    
    func setDelegates() {
        searchView.delegate = self
        headerView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
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
        ])
        
        NSLayoutConstraint.activate([
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
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(
                equalTo: searchView.bottomAnchor,
                constant: UIConstants.collectionToSearchViewOffset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
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
        let tracker = dataProvider?.getTracker(at: indexPath)
        let daysTracked = dataProvider?.daysTracked(for: indexPath)
        let isCompletedForToday = dataProvider?.isTrackerCompletedForToday(indexPath, date: currentDay.todayString)
        cell.configure(with: tracker)
        cell.configure(with: daysTracked, isCompleted: isCompletedForToday)
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

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            try dataProvider?.deleteTracker(at: indexPath)
        } catch {
            print("🐳", error)
        }
    }
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func plusButtonTapped(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        do {
            try dataProvider?.saveAsCompletedTracker(with: indexPath, for: dateString)
        } catch {
            print("⛈️", error)
        }
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        currentDay = date
        do {
            try dataProvider?.fetchTrackersBy(weekDay: weekDayNumber)
            collectionView.reloadData()
        } catch {
            print("🏹", error)
        }
    }
}

// MARK: - SearchViewDelegate
extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        do {
            try dataProvider?.fetchTrackersBy(name: searchText, weekDay: weekDayNumber)
            collectionView.reloadData()
        } catch {
            print("😎", error)
        }
    }
}

// MARK: - DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func place() {
        placeholderView.state = .question
    }
    
    func noResultFound() {
        placeholderView.state = .noResult
    }
    
    func resultFound() {
        placeholderView.state = .invisible(animate: true)
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
