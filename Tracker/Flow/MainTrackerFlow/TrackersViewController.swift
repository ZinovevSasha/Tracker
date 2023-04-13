import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let placeholderView = PlaceholderView(placeholder: .star, text: "Что будем отслеживать?")
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .myWhite
        view.registerHeader(TrackerHeader.self)
        view.register(cellClass: TrackerCollectionViewCell.self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - UIConstants
    private enum UIConstants {
        static let trackerHeaderHeight: CGFloat = 30
        static let inset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let topInset: CGFloat = 13
        static let headerToSearchOffset: CGFloat = 7
        static let collectionToStackOffset: CGFloat = 34
        static let stackHeight: CGFloat = 115
        static let headerHeight: CGFloat = 72
        static let searchHeight: CGFloat = 36
        static let searchLeading: CGFloat = 8
        static let searchTrailing: CGFloat = -8
        static let cellSpacing: CGFloat = 9
        static let cellHeight: CGFloat = 148
        static let cellCount = 2
    }
    
    // MARK: - Notification
    private var trackerObserver: NSObjectProtocol?
    
    private func addObserver() {
        trackerObserver = NotificationCenter.default
            .addObserver(
                forName: TrackerMaker.myNotificationName,
                object: nil,
                queue: .main) { [weak self] notification in
                    guard let self = self else { return }
                    
                    let category = notification.userInfo?["c"] as? TrackerCategory
                    guard let category = category else { return }
                    self.data.categories.append(category)
            }
    }
    
    // MARK: - Models
    private var data = DataSource.shared
    private var currentDate = Date()
    
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
        setConstraints()
        addObserver()
    }
    
    // MARK: -  @objc target action methods
    func handlePlusButtonTap() {
        let trackerCreationViewController = ChooseTrackerViewController(categories: data.categories, from: self)
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
        searchView.delegate = self
        headerView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        data.delegate = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .myWhite
        view.addSubviews(headerView, searchView, collectionView, placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        searchView.translatesAutoresizingMaskIntoConstraints = false
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
        return data.visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let tracker = data.visibleCategories[indexPath.section].trackers[indexPath.row]
        let matchingTrackers = data.completedTrackers.filter { $0.id == tracker.id }
        cell.configure(with: matchingTrackers.count)
        cell.configure(with: data.visibleCategories[indexPath.section].trackers[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: TrackerHeader = collectionView.dequeueHeader(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        header.configure(with: data.visibleCategories[indexPath.section])
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
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let tracker = data.categories[indexPath.section].trackers[indexPath.row]
        
        if data.completedTrackersId.contains(tracker.id) {
            data.completedTrackers.remove(at: indexPath.row)
            data.completedTrackersId.remove(tracker.id)
        } else {
            let completedTracker = TrackerRecord(id: tracker.id, date: currentDate)
            data.completedTrackersId.insert(tracker.id)
            data.completedTrackers.append(completedTracker)
        }
        
        let matchingTrackers = data.completedTrackers.filter { $0.id == tracker.id }
        cell.configure(with: matchingTrackers.count)
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        currentDate = date
        data.showTrackerForDayOfWeek(currentDate)
    }
}

// MARK: - SearchViewDelegate
extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        if searchText.isEmpty {
            data.showTrackerForDayOfWeek(currentDate)
        } else {
            data.visibleCategories = data.searchTrackerWithName(name: searchText) ?? []
        }
    }
}

extension TrackersViewController: DataSourceDelegate {
    func updateTrackers() {
        collectionView.reloadData()
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func addTrackerCategory(_ category: TrackerCategory) {
        print("FFF")
    }
    
    func addTracker(_ tracker: Tracker) {
        print("FFF")
    }
    
    func isNameAvailable(name: String) -> Bool {
        true
    }
}
