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
    var delegate: DataProviderDelegate? { get set }
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
    func getCompletedTrackersFor(date: String) throws
    func getUnCompletedTrackersFor(date: String, weekDay: String) throws
    func getTrackersForToday() throws
    func getAllTrackersFor(day: String) throws
    func getUnCompletedTrackersWithNameFor(date: String, weekDay: String, name: String) throws
    func getCompletedTrackersWithNameFor(date: String, name: String) throws
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
    private let trackerStore: TrackerStoreManagerProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    // PredicateBuilder
    private var predicateBuilder = PredicateBuilder<TrackerCD>()
    // Delegate
    weak var delegate: DataProviderDelegate?
    
    // Fetch controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.fetchLimit = 50
        fetchRequest.predicate = makePredicateBy(Date().weekDayString)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCD.isAttached), ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCD.category.header), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCD.name), ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCD.category.header),
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
    init(context: NSManagedObjectContext) {
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
        try trackerCategoryStore.addTracker(
            toCategoryWithName: category.header,
            tracker: TrackerCD(from: tracker, context: context)
        )
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

    func getAllTrackersFor(day: String) throws {
        fetchedResultsController.fetchRequest.predicate = makePredicateBy(day)
        try fetchedResultsController.performFetch()
    }

    func getCompletedTrackersWithNameFor(date: String, name: String) throws {
        if !name.isEmpty {
            let completed = NSPredicate(format: "ANY trackerRecord.date == %@", date)
            let name = predicateBuilder.addPredicate(.contains, keyPath: \.name, value: name).build()
            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [completed, name])
            try fetchedResultsController.performFetch()
            isEmpty ? delegate?.place() : delegate?.resultFound()
        } else {
            let completed = NSPredicate(format: "ANY trackerRecord.date == %@", date)
            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(
                type: .and, subpredicates: [completed])
            try fetchedResultsController.performFetch()
            isEmpty ? delegate?.place() : delegate?.resultFound()
        }
    }

    func getCompletedTrackersFor(date: String) throws {
        let completed = NSPredicate(format: "ANY trackerRecord.date == %@", date)
        fetchedResultsController.fetchRequest.predicate = completed
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func getUnCompletedTrackersWithNameFor(date: String, weekDay: String, name: String) throws {
        let forDayOfWeek = makePredicateBy(weekDay)
        let uncompleted = NSPredicate(format: "ANY trackerRecord.date != %@", date)
        let neverTracked = NSPredicate(format: "%K.@count == 0", #keyPath(TrackerCD.trackerRecord)
        )
        let name = predicateBuilder.addPredicate(.contains, keyPath: \.name, value: name).build()

        let dontTrackedAndForDayOfWeek = NSCompoundPredicate(
            type: .and,
            subpredicates: [neverTracked, forDayOfWeek, name])
        let uncompletedAndForDayOfWeek = NSCompoundPredicate(
            type: .and,
            subpredicates: [uncompleted, forDayOfWeek, name])

        let combinedPredicate = NSCompoundPredicate(
            type: .or,
            subpredicates: [uncompletedAndForDayOfWeek, dontTrackedAndForDayOfWeek])

        fetchedResultsController.fetchRequest.predicate = combinedPredicate
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func getUnCompletedTrackersFor(date: String, weekDay: String) throws {
        let forDayOfWeek = makePredicateBy(weekDay)
        let uncompleted = NSPredicate(format: "ANY trackerRecord.date != %@", date)
        let neverTracked = NSPredicate(format: "%K.@count == 0", #keyPath(TrackerCD.trackerRecord)
        )

        let dontTrackedAndForDayOfWeek = NSCompoundPredicate(type: .and, subpredicates: [neverTracked, forDayOfWeek])
        let uncompletedAndForDayOfWeek = NSCompoundPredicate(type: .and, subpredicates: [uncompleted, forDayOfWeek])

        let combinedPredicate = NSCompoundPredicate(
            type: .or,
            subpredicates: [uncompletedAndForDayOfWeek, dontTrackedAndForDayOfWeek])

        fetchedResultsController.fetchRequest.predicate = combinedPredicate
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
    }

    func getTrackersForToday() throws {
        fetchedResultsController.fetchRequest.predicate = makePredicateBy(Date().weekDayString)
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.place() : delegate?.resultFound()
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
        print(update)
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
