import UIKit
import Combine

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    let placeholderView = PlaceholderView(state: .question)
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
    
    // MARK: - Dependencies
    private let viewModel: TrackerViewModel
    private var cancellables = Set<AnyCancellable>()
    private var alertPresenter: AlertPresenter?
    
    
    
    // MARK: - Init
    init(
        viewModel: TrackerViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        alertPresenter = AlertPresenter(presentingViewController: self)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        viewModel.$update
            .dropFirst()
            .sink { [weak self] update in
                self?.updateUI(batchUpdates: update)
            }.store(in: &cancellables)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDelegates()
        setupLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        viewModel.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - @objc target action methods
    func handlePlusButtonTap() {
        let trackerCreationViewController = ChooseTrackerViewController()
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
    
    func updateUI(batchUpdates: BatchUpdates?) {
        guard let batchUpdates else { return }        
        collectionView.performBatchUpdates({
            // sections update
            for section in batchUpdates.deleteSections {
                collectionView.deleteSections(IndexSet(integer: section))
            }
            for (fromIndex, toIndex) in batchUpdates.moveSections {
                collectionView.moveSection(fromIndex, toSection: toIndex)
            }
            for section in batchUpdates.insertSections {
                collectionView.insertSections(IndexSet(integer: section))
            }
            for section in batchUpdates.updateSections {
                collectionView.reloadSections(IndexSet(integer: section))
            }
           
            // items update
            for (section, indexPaths) in batchUpdates.deleteItems {
                collectionView.deleteItems(at: indexPaths.map { IndexPath(item: $0, section: section) })
            }
            for (section, indexPaths) in batchUpdates.insertItems {
                collectionView.insertItems(at: indexPaths.map { IndexPath(item: $0, section: section) })
            }
            for (section, indexPaths) in batchUpdates.updateItems {
                collectionView.reloadItems(at: indexPaths.map { IndexPath(item: $0, section: section) })
            }
            for (fromIndexPath, toIndexPath) in batchUpdates.moveItems {
                collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
            }
        }, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TrackerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let viewModel = viewModel.getTrackerCellViewModelFor(indexPath)
        cell.configure(with: viewModel)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: TrackerCollectionHeader = collectionView.dequeueHeader(
            ofKind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        let headerName = viewModel.header(for: indexPath.section)
        header.configure(with: headerName)
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
        viewModel.saveAsCompletedTrackerAt(indexPath: indexPath)
    }
    
    func didAttachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel.attachTrackerAt(indexPath: indexPath)
       // viewModel.dataChanged()
    }
    
    func didUnattachTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        viewModel.unattachTrackerAt(indexPath: indexPath)
        //viewModel.dataChanged()
    }
    
    func didDeleteTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        alertPresenter?.show(message: "Уверены что хотите удалить трекер?") { [weak self] in
            guard let self = self else { return }
            self.viewModel.deleteTrackerAt(indexPath: indexPath)
        }
    }
    
    func didUpdateTracker(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let tracker = viewModel.getTrackerAt(indexPath: indexPath) {
            let updateTrackerViewModel = CreateTrackerViewModelImpl(
                trackerKind: tracker.kind,
                tracker: tracker,
                date: viewModel.currentDateString
            )
            let updateTrackerViewController = CreateTrackerViewController(viewModel: updateTrackerViewModel)
            
            present(updateTrackerViewController, animated: true)
        }
    }
}

// MARK: - TrackerHeaderViewDelegate
extension TrackersViewController: TrackerHeaderViewDelegate {
    func datePickerValueChanged(date: Date) {
        viewModel.setCurrentDayTo(newDate: date)
        viewModel.fetchTrackerBy(weekDay: date.todayString)
    }
}

// MARK: - SearchViewDelegate
extension TrackersViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, textDidChange searchText: String) {
        viewModel.fetchTrackerBy(name: searchText, andWeekDay: viewModel.currentDateString)
    }
}
