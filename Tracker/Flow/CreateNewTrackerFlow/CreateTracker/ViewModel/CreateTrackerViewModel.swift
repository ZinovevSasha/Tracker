import Foundation
import CoreData

final class CreateTrackerViewModel {          
    @Observable var isButtonAllowedToChangeState = false
    @Observable var isTrackersAddedToCoreData = false
    @Observable var isShakeOfButtonRequired = false
    
    var userTracker: UserTracker  {
        didSet {
            switch trackerType {
            case .habit:
                isButtonAllowedToChangeState = userTracker.isEnoughForHabit
            case .ocasional:
                isButtonAllowedToChangeState = userTracker.isEnoughForOcasion
            }
        }
    }
    
    private lazy var trackerCategoryStore: TrackerCategoryStore? = {
        do {
            return try TrackerCategoryStore()
        } catch {
            return nil
        }
    }()
    
    private lazy var trackerStore: TrackerStore? = {
        do {
            return try TrackerStore()
        } catch {
            return nil
        }
    }()
    
    private let trackerType: UserTracker.TrackerType
    private(set) var isUpdatingScreen: Bool
    var dataSource: DataSource
    
    init(trackerType: UserTracker.TrackerType,
         dataSource: DataSource = DataSource(),
         userTracker: UserTracker = UserTracker(),
         isUpdatingScreen: Bool = false
    ) {
        self.trackerType = trackerType
        self.dataSource = dataSource
        self.userTracker = userTracker
        self.isUpdatingScreen = isUpdatingScreen
        getCategoryName()
    }
    
    var categoryName: String {
        dataSource.categoryName
    }
    
    var numberOfTableViewRows: Int {
        switch trackerType {
        case .ocasional:
            return dataSource.oneRow.count
        case .habit:
            return dataSource.twoRows.count
        }
    }
    
    var dataForTablView: [TableData] {
        switch trackerType {
        case .ocasional:
            return dataSource.oneRow
        case .habit:
            return dataSource.twoRows
        }
    }
    
    var numberOfCollectionSections: Int {
        dataSource.collectionView.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        switch dataSource.collectionView[section] {
        case .emojiSection(let items):
            return items.count
        case .colorSection(let items):
            return items.count
        }
    }
    
    func getSection(_ indexPath: IndexPath) -> CollectionViewData {
        dataSource.collectionView[indexPath.section]
    }
    
    func createButtonTapped() {
        switch trackerType {
        case .habit:
            if userTracker.isEnoughForHabit {
                guard let tracker = userTracker.createHabitTracker() else { return }
                addTracker(tracker: tracker, trackerStore: trackerStore, categoryStore: trackerCategoryStore, categoryName: categoryName, isAdded: &isTrackersAddedToCoreData)
            } else {
                self.isShakeOfButtonRequired = true
            }
        case .ocasional:
            if userTracker.isEnoughForOcasion {
                guard let tracker = userTracker.createOcasionalTracker() else { return }
                addTracker(tracker: tracker, trackerStore: trackerStore, categoryStore: trackerCategoryStore, categoryName: categoryName, isAdded: &isTrackersAddedToCoreData)
            } else {
                self.isShakeOfButtonRequired = true
            }
        }
    }
    
    func addCategory(name: String) {
        dataSource.addCategory(name)
        userTracker.categoryName = name
    }
    
    // Private
    private func addTracker(
        tracker: Tracker,
        trackerStore: TrackerStore?,
        categoryStore: TrackerCategoryStore?,
        categoryName: String,
        isAdded:  inout Bool
    ) {
        if let trackerCoreData = trackerStore?.createTrackerCoreData(tracker) {
            try? trackerCategoryStore?.addTracker(toCategoryWithName: categoryName, tracker: trackerCoreData)
            isAdded = true
        }
    }
    
    func getCategoryName() {
        if let header = trackerCategoryStore?.getNameOfLastSelectedCategory() {
            dataSource.addCategory(header)
            userTracker.categoryName = header
        }
    }
}
