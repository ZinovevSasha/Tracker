import Foundation
import CoreData

final class CreateTrackerViewModel {
    // MARK: - Public
    @Observable var isButtonAllowedToChangeState = false
    @Observable var isTrackersAddedToCoreData = false
    @Observable var isShakeOfButtonRequired = false
        
    // MARK: - Private
    // 1) Configuration
    private let trackerType: UserTracker.TrackerType
    
    // 2) Category Name
    var categoryName: String {
        dataForTableView.categoryName
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
        
    // 3) UserInput is public so that controller can store user input there
    var userTracker: UserTracker {
        didSet {
            switch trackerType {
            case .habit:
                isButtonAllowedToChangeState = userTracker.isEnoughForHabit
            case .ocasional:
                isButtonAllowedToChangeState = userTracker.isEnoughForOcasion
            }
        }
    }
    // 4) dataForTableView
    var dataForTableView: CategoryAndScheduleData
    // 5) dataForCollectionView
    let dataForCollectionView: [CollectionViewData]

    // MARK: - Init
    init(
        userTrackerType: UserTracker.TrackerType,
        userTracker: UserTracker,
        dataForTableView: CategoryAndScheduleData,
        dataForCollectionView: [CollectionViewData]
    ) {
        self.trackerType = userTrackerType
        self.userTracker = userTracker
        self.dataForTableView = dataForTableView
        self.dataForCollectionView = dataForCollectionView
    }
    
    convenience init(trackerType: UserTracker.TrackerType) {
        self.init(
            userTrackerType: trackerType,
            userTracker: UserTracker(),            
            dataForTableView: CategoryAndScheduleData(),
            dataForCollectionView: EmojisAndColorData().dataSource)
    }
    
    func createButtonTapped() {
        switch trackerType {
        case .habit:
            if userTracker.isEnoughForHabit {
                guard let tracker = userTracker.createHabitTracker() else { return }
                addTracker(tracker: tracker, trackerStore: trackerStore, categoryStore: trackerCategoryStore, isAdded: &isTrackersAddedToCoreData)
            } else {
                self.isShakeOfButtonRequired = true
            }
        case .ocasional:
            if userTracker.isEnoughForOcasion {
                guard let tracker = userTracker.createOcasionalTracker() else { return }
                addTracker(tracker: tracker, trackerStore: trackerStore, categoryStore: trackerCategoryStore, isAdded: &isTrackersAddedToCoreData)
            } else {
                self.isShakeOfButtonRequired = true
            }
        }
    }
    
    // Private
    private func addTracker(
        tracker: Tracker,
        trackerStore: TrackerStore?,
        categoryStore: TrackerCategoryStore?,
        isAdded:  inout Bool
    ) {
        if let trackerCoreData = trackerStore?.createTrackerCoreData(tracker) {
            try? trackerCategoryStore?.addTracker(toCategoryWithName: categoryName, tracker: trackerCoreData)
            isAdded = true
        }
    }
}

extension CreateTrackerViewModel {
    var numberOfRows: Int {
        switch trackerType {
        case .ocasional:
            return dataForTableView.oneRow.count
        case .habit:
            return dataForTableView.twoRows.count
        }
    }
    
    var dataForTable: [RowData] {
        switch trackerType {
        case .ocasional:
            return dataForTableView.oneRow
        case .habit:
            return dataForTableView.twoRows
        }
    }
    
    var numberOfCollectionSections: Int {
        dataForCollectionView.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        switch dataForCollectionView[section] {
        case .emojiSection(let items):
            return items.count
        case .colorSection(let items):
            return items.count
        }
    }
    
    func getSection(_ indexPath: IndexPath) -> CollectionViewData {
        dataForCollectionView[indexPath.section]
    }
}
