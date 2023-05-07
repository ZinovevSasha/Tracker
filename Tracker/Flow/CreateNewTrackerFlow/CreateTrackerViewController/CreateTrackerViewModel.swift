import Foundation

final class CreateTrackerViewModel {
    // MARK: - Public
//    @Observable var trackerCatefory: TrackerCategory?
    @Observable var onCreateAllowedStateChange: Bool = false
        
    // MARK: - Private
    // 1) Configuration
    private let trackerType: UserTracker.TrackerType

    // 2) Date for ocasional tracker
    private let date: String
    
    // MARK: - Public
    // 3) UserInput is public so that controller can store user input there
    var userTracker: UserTracker {
        didSet {
            switch trackerType {
            case .habit:
                onCreateAllowedStateChange = userTracker.isEnoughForHabit
            case .ocasional:
                onCreateAllowedStateChange = userTracker.isEnoughForOcasion
            }
        }
    }
    // 4) dataForTableView
    var dataForTableView: CategoryAndScheduleData
    // 5) dataForCollectionView
    let dataForCollectionView: [CollectionViewData]
    
    var categoryName: String {
        dataForTableView.categoryName
    }
    
    
    // MARK: - Init
    init(
        userTrackerType: UserTracker.TrackerType,
        userTracker: UserTracker,
        date: String,
        dataForTableView: CategoryAndScheduleData,
        dataForCollectionView: [CollectionViewData]
    ) {
        self.trackerType = userTrackerType
        self.userTracker = userTracker
        self.date = date
        self.dataForTableView = dataForTableView
        self.dataForCollectionView = dataForCollectionView
        
        // set name as last selected category name
        
    }
    
    convenience init(trackerType: UserTracker.TrackerType, date: String) {
        self.init(userTrackerType: trackerType,
                  userTracker: UserTracker(trackerBuilder: TrackerMaker()),
                  date: date,
                  dataForTableView: CategoryAndScheduleData(),
                  dataForCollectionView: EmojisAndColorData().dataSource)
    }
    
    func createButtonTapped() {
        switch trackerType {
        case .habit:
            if userTracker.isEnoughForHabit {
                userTracker.buildTracker()
            } else {
                
            }
        case .ocasional:
            if userTracker.isEnoughForOcasion {
                userTracker.buildTracker()
            } else {
                
            }
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
