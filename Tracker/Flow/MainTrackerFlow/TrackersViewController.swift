import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let placeholderView = PlaceholderView()
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .myWhite
        view.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        view.register(
            TrackerCollectionSectionCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionSectionCategoryHeaderView.identifier
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    // MARK: - Models
    var categories: [TrackerCategory] = [] {
        didSet {
            visibleCategories = categories
        }
    }
    
    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            visibleCategories.isEmpty ? placeholderView.unhide() : placeholderView.hide()
            collectionView.reloadData()
        }
    }
    var completedTrackers: [TrackerRecord] = []
    var completedTrackersId: Set<UUID> = []
    var currentDate = Date()
    
    private let params = GeometryParams(
        cellCount: UIConstants.cellCount,
        leftInset: UIConstants.inset,
        rightInset: UIConstants.inset,
        spacing: UIConstants.cellSpacing
    )
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        setConstraints()
        addObserver()
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
                    self.categories.append(category)
            }
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func initialise() {
        searchView.delegate = self
        headerView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
    
    func  currentWeekDayNumber(from day: Date) -> Int {
        let calendar = Calendar(identifier: .coptic)
        let dayNumber = calendar.component(.weekday, from: day)
        return dayNumber
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let matchingTrackers = completedTrackers.filter { $0.id == tracker.id }
        
        cell.configure(with: matchingTrackers.count)
        cell.configure(with: visibleCategories[indexPath.section].trackers[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionSectionCategoryHeaderView.identifier,
            for: indexPath) as? TrackerCollectionSectionCategoryHeaderView
        else {
            return UICollectionReusableView()
        }
        header.configure(with: visibleCategories[indexPath.section])
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
        UIEdgeInsets(top: .zero, left: params.leftInset, bottom: .zero, right: params.rightInset)
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
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        if completedTrackersId.contains(tracker.id) {
            completedTrackers.remove(at: indexPath.row)
            completedTrackersId.remove(tracker.id)
        } else {
            let completedTracker = TrackerRecord(id: tracker.id, date: currentDate)
            completedTrackersId.insert(tracker.id)
            completedTrackers.append(completedTracker)
        }
        
        let matchingTrackers = completedTrackers.filter { $0.id == tracker.id }
        cell.configure(with: matchingTrackers.count)
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        currentDate = date
        let today = currentWeekDayNumber(from: Date())
        let selectedDay = currentWeekDayNumber(from: currentDate)
        
        if today != selectedDay {
            guard
                let sortedForDayOfWeek = makeCategoriesWithTrackersForExactDay(
                    categories: categories,
                    day: selectedDay
                )
            else {
                return
            }
            visibleCategories = sortedForDayOfWeek
        } else {
            visibleCategories = categories
        }
    }
    
    private func makeCategoriesWithTrackersForExactDay(
        categories: [TrackerCategory],
        day: Int
    ) -> [TrackerCategory]? {
        let weekday = WeekDay(rawValue: day) ?? .sunday
        let categories: [TrackerCategory]? = categories.compactMap { category in
            let trackerForDate = category.trackers.filter {
                $0.schedule.contains(weekday)
            }
            return trackerForDate.isEmpty ? nil :
            TrackerCategory(header: category.header, trackers: trackerForDate)
        }
        return categories
    }
    
    func handlePlusButtonTap() {
        let trackerCreationViewController = ChooseTrackerViewController()
        present(trackerCreationViewController, animated: true)
    }
}

extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        let today = currentWeekDayNumber(from: Date())
        let selectedDay = currentWeekDayNumber(from: currentDate)
        
        if searchText.isEmpty {
            if today != selectedDay {
                guard
                    let sortedForDayOfWeek = makeCategoriesWithTrackersForExactDay(
                        categories: categories,
                        day: selectedDay
                    )
                else {
                    return
                }
                visibleCategories = sortedForDayOfWeek
            } else {
                visibleCategories = categories
            }
        } else {
            visibleCategories = searchTrackerWithName(name: searchText) ?? []
        }
        collectionView.reloadData()
    }
    
    private func searchTrackerWithName(name: String) -> [TrackerCategory]? {
        let categories: [TrackerCategory]? = categories.compactMap { category in
            let trackerForDate = category.trackers.filter { $0.name.lowercased().contains(name.lowercased())
            }
            return trackerForDate.isEmpty ? nil :
            TrackerCategory(header: category.header, trackers: trackerForDate)
        }
        return categories
    }
}
