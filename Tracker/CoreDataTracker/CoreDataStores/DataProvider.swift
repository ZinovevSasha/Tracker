import Foundation
import UIKit
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
}

protocol DataProviderProtocol {
    var isEmpty: Bool { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func header(for section: Int) -> String
    func daysTracked(for indexPath: IndexPath) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func getCategories() -> [TrackerCategory]
    func addRecord(_ record: TrackerCategory) throws
    func deleteRecord(at indexPath: IndexPath) throws
    func fetchTrackersBy(name: String) throws
    func fetchTrackersBy(date: Date) throws
    func saveAsCompletedTracker(with indexPath: IndexPath, for day: Date) throws
    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: Date) -> Bool
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
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    // Delegate
    weak var delegate: DataProviderDelegate?
    
    // Fetch controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.fetchLimit = 50
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.header), ascending: true)
        ]
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
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?
            .persistentContainer.viewContext else {
                throw DataProviderError.contextUnavailable
        }
        
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
    }

    enum DataProviderError: Error {
        case contextUnavailable
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var isEmpty: Bool {
        guard let objects = fetchedResultsController.fetchedObjects else { return false }
        return objects.isEmpty ? true : false
    }
    
    var numberOfSections: Int {
        let numberOfSections = fetchedResultsController.sections?.count ?? .zero
        return numberOfSections
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let number = fetchedResultsController.sections?[section].numberOfObjects ?? .zero
        return number
    }
    
    func header(for section: Int) -> String {
        let header = fetchedResultsController.sections?[section].name ?? ""
        return header
    }
    
    func daysTracked(for indexPath: IndexPath) -> Int {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.getTrackedDaysNumberFor(tracker: tracker)
        } catch {
            print(error)
            return .zero
        }
    }
    
    func isTrackerCompletedForToday(_ indexPath: IndexPath, date: Date) -> Bool {
        let tracker = fetchedResultsController.object(at: indexPath)
        do {
            return try trackerRecordStore.isTrackerCompletedFor(selectedDay: date, tracker)
        } catch {
            print(error)
            return false
        }
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        try? fetchedResultsController.object(at: indexPath).tracker()
    }
    
    func addRecord(_ record: TrackerCategory) throws {
        guard let tracker = record.trackers.first else { return }
        // Create TrackerCoreData
        let trackersCoreData = try trackerStore.createTrackerCoreData(tracker)
        // Pass trackersCoreData as parametr to trackerCategoryStore
        try trackerCategoryStore.addCategory(with: record.header, and: trackersCoreData)
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        let record = fetchedResultsController.object(at: indexPath)
        try trackerStore.delete(record)
    }
    
    func getCategories() -> [TrackerCategory] {
        trackerCategoryStore.getAllCategories()
    }
    
    func fetchTrackersBy(name: String) throws {
        if !name.isEmpty {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(
                // [cd] case-insensitive ignore differences in letter case
                // [d] diacritic insensitive ignore differences in accent
                // "resume" but the text contains "résumé", the search will still match
                format: "name CONTAINS[cd] %@", name
            )
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
    }
    
    func fetchTrackersBy(date: Date) throws {
        let weekdayNumber = String(Date.currentWeekDayNumber(from: date))
        let selectedDate = Date.dateString(for: date)
        let currentDate = Date.dateString(for: Date())
        
        guard selectedDate != currentDate else {
            fetchedResultsController.fetchRequest.predicate = nil
            try fetchedResultsController.performFetch()
            isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
            return
        }
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.schedule),
            weekdayNumber
        )
        
        try fetchedResultsController.performFetch()
        isEmpty ? delegate?.noResultFound() : delegate?.resultFound()
    }
    
    func saveAsCompletedTracker(with indexPath: IndexPath, for day: Date) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        let selectedDay = Date.dateString(for: day)
        try? trackerRecordStore.removeTrackerRecordOrAdd(trackerCoreData, with: selectedDay)
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
            movedIndexes: movedItem)

        // Update delegate with indexes
        delegate?.didUpdate(update)
        
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
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath))
        @unknown default:
            break
        }
    }
}

/*
class Tracker: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var color: String
    @NSManaged var emoji: String
    @NSManaged var schedule: String
    @NSManaged var category: TrackerCategory?
    @NSManaged var records: Set<TrackerRecord>?
}

class TrackerCategory: NSManagedObject {
    @NSManaged var header: String
    @NSManaged var trackers: Set<Tracker>?
}

class TrackerRecord: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var date: String
    @NSManaged var tracker: Tracker?
}
*/

