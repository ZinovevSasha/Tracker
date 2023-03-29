import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private properties
    private let headerView = TrackerHeaderView()
    private let searchView = SearchView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .myWhite
        view.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        view.register(TrackerCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeaderView.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let params = GeometryParams(
        cellCount: UIConstants.cellCount,
        leftInset: UIConstants.inset,
        rightInset: UIConstants.inset,
        spacing: UIConstants.cellSpacing
    )
    
    var categories: [TrackerCategory] = [
        TrackerCategory(
            header: "Бытовые дела",
            trackers: [
            Tracker(id: "1", name: "Поливать растения", color: .myBlue, emoji: "🪴", daysTracked: 0),
            Tracker(id: "1", name: "Выгулять собаку", color: .systemPink, emoji: "🐶", daysTracked: 0),
            Tracker(id: "1", name: "Поиграть в футбол", color: .systemYellow, emoji: "⚽️", daysTracked: 0)]
        ),
        TrackerCategory(
            header: "Спорт",
            trackers: [
            Tracker(id: "1", name: "Сходить в бассейн", color: .systemOrange, emoji: "🏊‍♂️", daysTracked: 0)])
    ]
    var completedTrackers: [TrackerRecord] = []
    var visibleCategories: [TrackerCategory] = []
    var currentDate = Date()
    
    // MARK: - UIConstants
    private enum UIConstants {
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
    }
}

// MARK: - Private methods
private extension TrackersViewController {
    func initialise() {
        collectionView.dataSource = self
        collectionView.delegate = self
        view.backgroundColor = .myWhite
        view.addSubviews(headerView, searchView, collectionView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        searchView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints() {
        let headerViewConstraints = [
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.topInset),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.inset),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIConstants.trailingInset),
            headerView.heightAnchor.constraint(equalToConstant: UIConstants.headerHeight),
        ]
        let searchViewConstraints = [
            searchView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: UIConstants.topInset),
            searchView.heightAnchor.constraint(equalToConstant: UIConstants.searchHeight),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.searchLeading),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIConstants.searchTrailing),
        ]
        let collectionViewConstraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: UIConstants.collectionToStackOffset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(
            headerViewConstraints +
            searchViewConstraints +
            collectionViewConstraints
        )
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()            
        }
        cell.configure(with: categories[indexPath.section].trackers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeaderView.identifier, for: indexPath) as? TrackerCategoryHeaderView else { return UICollectionReusableView() }
        header.configure(with: categories[indexPath.section])
        return header
    }
}

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
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}
