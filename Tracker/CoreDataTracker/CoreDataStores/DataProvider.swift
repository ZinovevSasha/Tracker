import Foundation
import CoreData


protocol DataProviderDelegate: AnyObject {    
    func noResultFound()
    func dataChanged()
    func resultFound()
    func place()
}

protocol DataProviderProtocol {
    func getCategories() -> [TrackerCategory]
    func addTrackerCategory(_ category: TrackerCategory) throws
    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: String) -> Bool
    
    func fetchTrackersBy(name: String, weekDay: String) throws
    func fetchTrackersBy(weekDay: String) throws
    func attachTrackerWith(id: String)
    func unattachTrackerWith(id: String)
    func deleteTrackerWith(id: String) throws
    func saveAsCompletedTrackerWith(id: String, for day: String) throws
    func daysTrackedForTrackerWith(id: String) -> Int
}

final class DataProvider: NSObject {
    // Context -> one for 3 stores
    private let context: NSManagedObjectContext
    // Stores
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    // PredicateBuilder
    private var predicateBuilder = PredicateBuilder<TrackerCoreData>()
    // Delegate
    weak var delegate: DataProviderDelegate?
    
    // Fetch controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.fetchLimit = 50
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.header), ascending: true),
            NSSortDescriptor(keyPath: "pinnedCategory.header", ascending: true, comparator: { (value1, value2) -> ComparisonResult in
                    if let header1 = value1 as? String, let header2 = value2 as? String {
                        if header1 == "Pinned" && header2 != "Pinned" {
                            return .orderedAscending
                        } else if header1 != "Pinned" && header2 == "Pinned" {
                            return .orderedDescending
                        } else {
                            return header1.compare(header2)
                        }
                    }
                    return .orderedSame
            }),
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let weekDay = String(Date().weekDayNumber)
        fetchRequest.predicate = makePredicateBy(weekDay)

        let sectionKeyPath = #keyPath(TrackerCoreData.category.header)
        
        
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionKeyPath,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - Init
    init(delegate: DataProviderDelegate?) throws {
        let context = try Context.getContext()
        
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStoreImpl(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        super.init()
        let controller = fetchedResultsController
        fetchedResultsController.performFetch()
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    func daysTrackedForTrackerWith(id: String) -> Int {
        do {
            return try trackerRecordStore.getTrackedDaysNumberForTrackerWith(id: id)
        } catch {
            print(error)
            return .zero
        }
    }
    
    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: String) -> Bool {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.isCompletedFor(date, trackerWithId: tracker.id)
        } catch {
            print(error)
            return false
        }
    }
    
    func addTrackerCategory(_ category: TrackerCategory) throws {
        guard let tracker = category.trackers.first else { return }
        let trackerCoreData = try trackerStore.createTrackerCoreData(tracker)
        try trackerCategoryStore.addTracker(toCategoryWithName: category.header, tracker: trackerCoreData)
    }
    
    func deleteTrackerWith(id: String) throws {
        try trackerStore.deleteTrackerWith(id: id)
    }
    
    func saveAsCompletedTrackerWith(id: String, for day: String) throws {
        if let tracker = trackerStore.getTrackerBy(id: id) {
            try? trackerRecordStore.removeTrackerOrAdd(tracker, forParticularDay: day)
        }
    }
    
    func getCategories() -> [TrackerCategory] {
        return trackerCategoryStore.getAllCategories()
    }
    
    func attachTrackerWith(id: String) {        
        trackerStore.pinTrackerWith(id: id)
    }
    
    func unattachTrackerWith(id: String) {
        trackerStore.unPinTrackerWith(id: id)
    }
    
    // Searching by name
    func fetchTrackersBy(name: String, weekDay: String) throws {
        if !name.isEmpty {
            fetchedResultsController.fetchRequest
                .predicate = makePredicateBy(name: name, weekDay: weekDay)
            try fetchedResultsController.performFetch()
//            isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
        } else {
            fetchedResultsController.fetchRequest.predicate = makePredicateBy(weekDay)
            try fetchedResultsController.performFetch()
//            isEmpty ? delegate?.place() : delegate?.resultFound()
        }
    }
    
    // Searching by weekDay
    func fetchTrackersBy(weekDay: String) throws {
        fetchedResultsController.fetchRequest.predicate = makePredicateBy(weekDay)
        try fetchedResultsController.performFetch()
//        isEmpty ? delegate?.place() : delegate?.resultFound()
    }
    
    // Private
    private func makePredicateBy(_ weekDay: String) -> NSPredicate {
        return predicateBuilder
            .addPredicate(.contains, keyPath: \.schedule, value: weekDay)
            .build()
    }
    
    private func makePredicateBy(name: String, weekDay: String) -> NSPredicate {
        return predicateBuilder
            .addPredicate(.contains, keyPath: \.name, value: name)
            .addPredicate(.contains, keyPath: \.schedule, value: weekDay)
            .build()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataChanged()
    }
}
