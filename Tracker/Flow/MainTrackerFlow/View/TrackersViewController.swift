import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let placeholderView = PlaceholderView(state: .question)
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    private let filterButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        view.setTitle(Strings.Localizable.Filters.title, for: .normal)
        view.titleLabel?.font = .regular17
        view.backgroundColor = .myBlue
        return view
    }()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .myWhite
        view.allowsSelection = true
        view.registerHeader(TrackerCollectionHeader.self)
        view.register(cellClass: TrackerCollectionViewCell.self)
        return view
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
    private var dataProvider: DataProviderProtocol?
    lazy var alertPresenter = AlertPresenter(presentingViewController: self)

    private var currentFilter: FiltersViewController.Filters = .forToday
    private var currentDay = Date()
    private var currentWeekdayString: String { currentDay.weekDayString }
    private var currentDateString: String { currentDay.dateString }

    init(dataProvider: DataProviderProtocol?) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        self.dataProvider?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
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
            filterButton.isHidden = true
        } else {
            placeholderView.state = .invisible(animate: false)
            filterButton.isHidden = false
        }
    }
    
    // MARK: - @objc target action methods
    func handlePlusButtonTap() {
        let trackerCreationViewController = ChooseTrackerViewController()
        present(trackerCreationViewController, animated: true)
    }
    
    @objc func hideKeyboard() {
        searchView.hideKeyboard()
    }
    
    @objc func filterTrackers() {
        let filtersVC = FiltersViewController(filter: currentFilter)
        filtersVC.filterSelected = { [weak self] filter in
            self?.currentFilter = filter
            self?.handle(filters: filter)
        }
        present(filtersVC, animated: true)
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        filterButton.addTarget(self, action: #selector(filterTrackers), for: .touchUpInside)
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .myWhite
        view.addSubviews(headerView, searchView, collectionView, placeholderView, filterButton)
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
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func handle(filters: FiltersViewController.Filters) {
        switch filters {
        case .all:
            try? dataProvider?.getAllTrackersFor(day: currentWeekdayString)
        case .forToday:
            currentDay = Date()
            headerView.setDate(date: Date())
            try? dataProvider?.getTrackersForToday()
        case .completed:
            try? dataProvider?.getCompletedTrackersFor(date: currentDateString)
        case .uncompleted:
            try? dataProvider?.getUnCompletedTrackersFor(date: currentDateString, weekDay: currentWeekdayString)
        }
        collectionView.reloadData()
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

        let isCompletedForToday = dataProvider?.isTrackerCompletedForToday(indexPath, date: currentDateString)

        cell.configure(with: tracker)
        cell.configure(with: daysTracked, isCompleted: isCompletedForToday)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: TrackerCollectionHeader = collectionView.dequeueHeader(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        header.configure(with: dataProvider?.header(for: indexPath.section) ?? "")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
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
    func didMarkTrackerCompleted(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        do {
            try dataProvider?.saveAsCompletedTracker(with: indexPath, for: currentDateString)
        } catch {
            print("⛈️", error)
        }
    }
    
    func didAttachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        dataProvider?.attachTrackerAt(indexPath: indexPath)
    }
    
    func didUnattachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        dataProvider?.unattachTrackerAt(indexPath: indexPath)
    }
    
    func didDeleteTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        alertPresenter.show(message: Strings.Localizable.Alert.confirmationTracker) { [weak self] in
            try? self?.dataProvider?.deleteTracker(at: indexPath)
        }
    }
    
    func didUpdateTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
            let tracker = dataProvider?.getTracker(at: indexPath) else { return }
        let updateTrackerViewModel = CreateTrackerViewModelImpl(
            trackerKind: tracker.kind, tracker: tracker, date: currentDateString)
        
        let updateTrackerViewController = CreateTrackerViewController(viewModel: updateTrackerViewModel)
        
        present(updateTrackerViewController, animated: true)
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        currentDay = date
        do {
            if currentFilter == .forToday {
                try dataProvider?.fetchTrackersBy(weekDay: currentWeekdayString)
                currentFilter = .all
                collectionView.reloadData()
            } else {
                handle(filters: currentFilter)
            }
        } catch {
            print("🏹", error)
        }
    }
}

// MARK: - SearchViewDelegate
extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        do {
            switch currentFilter {
            case .all:
                try dataProvider?.fetchTrackersBy(name: searchText, weekDay: currentWeekdayString)
            case .forToday:
                try dataProvider?.fetchTrackersBy(name: searchText, weekDay: Date().weekDayString)
            case .completed:
                try dataProvider?.getCompletedTrackersWithNameFor(
                    date: currentDateString, name: searchText)
            case .uncompleted:
                try dataProvider?.getUnCompletedTrackersWithNameFor(
                    date: currentDateString, weekDay: currentWeekdayString, name: searchText)
            }
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
        filterButton.isHidden = true
    }
    
    func resultFound() {
        placeholderView.state = .invisible(animate: true)
        filterButton.isHidden = false
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
            if !update.deletedSection.isEmpty {
                collectionView.deleteSections(update.deletedSection)
            }
            if !update.updatedIndexes.isEmpty {
                collectionView.reloadItems(at: [update.updatedIndexes])
            }
            if !update.movedIndexes.isEmpty {
                for move in update.movedIndexes {
                    collectionView.moveItem(
                        at: move.oldIndexPath,
                        to: move.newIndexPath
                    )
                }
            }
        } completion: { _ in
            for move in update.movedIndexes {
                if update.deletedSection.isEmpty && update.insertedSection.isEmpty {
                    self.collectionView.reloadItems(at: [move.newIndexPath])
                }
            }
        }
    }
}
