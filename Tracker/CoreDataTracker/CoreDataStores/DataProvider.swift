import Foundation
import CoreData

// Struct for updates, will be sent to delegate to update collection
struct DataProviderUpdate {
    struct Move: Hashable {
        let oldIndexPath: IndexPath
        let newIndexPath: IndexPath
    }
    var insertedSection: IndexSet
    var deletedSection: IndexSet
    var insertedIndexes: IndexPath
    var deletedIndexes: IndexPath
    var updatedIndexes: IndexPath
    let movedIndexes: Set<Move>
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: DataProviderUpdate)
    func noResultFound()
    func resultFound()
    func place()
}

protocol DataProviderProtocol {
    var isEmpty: Bool { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func header(for section: Int) -> String
    func daysTracked(for indexPath: IndexPath) -> Int
    func getCategories() -> [TrackerCategory]
    func addTrackerCategory(_ category: TrackerCategory) throws
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func deleteTracker(at indexPath: IndexPath) throws
    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: String) -> Bool
    func saveAsCompletedTracker(with indexPath: IndexPath, for day: String) throws
    func fetchTrackersBy(name: String, weekDay: String) throws
    func fetchTrackersBy(weekDay: String) throws
    func attachTrackerAt(indexPath: IndexPath)
    func unattachTrackerAt(indexPath: IndexPath)
    func getCompletedTrackers() throws
    func getUnCompletedTrackers() throws
    func getTrackersForToday() throws
    func getAllTrackers() throws
}

final class DataProvider: NSObject {
    // Idexes for delegate
    private var insertedSection: IndexSet?
    private var deletedSection: IndexSet?
    private var insertedIndexes: IndexPath?
    private var deletedIndexes: IndexPath?
    private var updatedIndexes: IndexPath?
    private var movedIndexes: Set<DataProviderUpdate.Move>?
    
    // Context -> one for 3 stores
    private let context: NSManagedObjectContext
    // Stores
    private let trackerStore: TrackerStoreDataProviderProtocol
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
        fetchRequest.predicate = makePredicateBy(Date().weekDayString)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.isAttached), ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.header), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.header),
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
        self.trackerStore = TrackerStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var isEmpty: Bool {
        guard let objects = fetchedResultsController.fetchedObjects else { return false }
        return objects.isEmpty ? true : false
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? .zero
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? .zero
    }
    
    func header(for section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func daysTracked(for indexPath: IndexPath) -> Int {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.getTrackedDaysNumberFor(trackerWithId: tracker.id)
        } catch {
            return .zero
        }
    }
    
    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: String) -> Bool {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.isCompletedFor(date, trackerWithId: tracker.id)
        } catch {
            return false
        }
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return Tracker(coreData: trackerCoreData)
    }
    
    func addTrackerCategory(_ category: TrackerCategory) throws {
        guard let tracker = category.trackers.first else { return }
        let trackerCoreData = try trackerStore.createTrackerCoreData(tracker)
        try trackerCategoryStore.addTracker(toCategoryWithName: category.header, tracker: trackerCoreData)
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        try trackerStore.delete(tracker)
    }
    
    func saveAsCompletedTracker(with indexPath: IndexPath, for day: String) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        try? trackerRecordStore.removeOrAddRecordOf(tracker: trackerCoreData, forParticularDay: day)
    }
    
    func getCategories() -> [TrackerCategory] {
        trackerCategoryStore.getAllCategories()
    }
    
    func attachTrackerAt(indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        trackerCategoryStore.putToAttachedCategory(tracker: trackerCoreData)
    }
    
    func unattachTrackerAt(indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        trackerCategoryStore.putBackToOriginalCategory(tracker: trackerCoreData)
    }
    
    // Searching by name
    func fetchTrackersBy(name: String, weekDay: String) throws {
        if !name.isEmpty {
            fetchedResultsController.fetchRequest
                .predicate = makePredicateBy(name: name, weekDay: weekDay)
            try fetchedResultsController.performFetch()
            isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
        } else {
            fetchedResultsController.fetchRequest.predicate = makePredicateBy(weekDay)
            try fetchedResultsController.performFetch()
            isEmpty ? delegate?.place() : delegate?.resultFound()
        }
    }
    
    // Searching by weekDay
    func fetchTrackersBy(weekDay: String) throws {
        fetchedResultsController.fetchRequest.predicate = makePredicateBy(weekDay)
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func getAllTrackers() throws {
        fetchedResultsController.fetchRequest.predicate = nil
        try fetchedResultsController.performFetch()
    }

    func getCompletedTrackers() throws {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K.@count > 0",
            #keyPath(TrackerCoreData.trackerRecord))

        try fetchedResultsController.performFetch()       
    }

    func getUnCompletedTrackers() throws {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K.@count == 0",
            #keyPath(TrackerCoreData.trackerRecord))

        try fetchedResultsController.performFetch()
    }

    func getTrackersForToday() throws {
        fetchedResultsController.fetchRequest.predicate = makePredicateBy(Date().weekDayString)
        try fetchedResultsController.performFetch()
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
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSection = IndexSet()
        deletedSection = IndexSet()
        insertedIndexes = IndexPath()
        deletedIndexes = IndexPath()
        updatedIndexes = IndexPath()
        movedIndexes = Set<DataProviderUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedSectionIndexSet = insertedSection,
            let deletedSectionIndexSet = deletedSection,
            let insertedItem = insertedIndexes,
            let deletedItem = deletedIndexes,
            let updatedItem = updatedIndexes,
            let movedItem = movedIndexes else {
            return
        }
        
        let update = DataProviderUpdate(
            insertedSection: insertedSectionIndexSet,
            deletedSection: deletedSectionIndexSet,
            insertedIndexes: insertedItem,
            deletedIndexes: deletedItem,
            updatedIndexes: updatedItem,
            movedIndexes: movedItem
        )
        
        // Update delegate with indexes
        delegate?.didUpdate(update)
        isEmpty ? delegate?.place() : delegate?.resultFound()
        
        insertedSection = nil
        deletedSection = nil
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSection = IndexSet(integer: sectionIndex)
        case .delete:
            deletedSection = IndexSet(integer: sectionIndex)
        default:
            break
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            insertedIndexes = newIndexPath
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexes = indexPath
        case .update:
            guard let indexPath = indexPath else { return }
            updatedIndexes = indexPath
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(oldIndexPath: indexPath, newIndexPath: newIndexPath))
        @unknown default:
            break
        }
    }
}
