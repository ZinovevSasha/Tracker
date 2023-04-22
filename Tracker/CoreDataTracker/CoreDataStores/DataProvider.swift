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
    var updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: DataProviderUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func header(for section: Int) -> String
    func object(at indexPath: IndexPath) -> Tracker?
    func addRecord(_ record: TrackerCategory) throws
    func deleteRecord(at indexPath: IndexPath) throws
    func getCategories() -> [TrackerCategory]
}

final class DataProvider: NSObject {
    // Idexes for delegate
    private var insertedSection: IndexSet?
    private var deletedSection: IndexSet?
    private var insertedIndexes: IndexPath?
    private var deletedIndexes: IndexPath?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<DataProviderUpdate.Move>?
    
    // Context -> one for 3 stores
    private let context: NSManagedObjectContext
    // Stores
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
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
    
    enum TrackerStoreError: Error {
        case decodingErrorInvalidId
        case decodingErrorInvalidName
        case decodingErrorInvalidColor
        case decodingErrorInvalidEmoji
        case decodingErrorInvalidSchedule
    }
    
    // MARK: - Init
    init(delegate: DataProviderDelegate?) {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        let numberOfSections = fetchedResultsController.sections?.count ?? .zero
        print("numberOfSections is \(numberOfSections)")
        return numberOfSections
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let number = fetchedResultsController.sections?[section].numberOfObjects ?? .zero
        print("numberOfRowsInSection \(section) = \(number)")
        return number
    }
    
    func header(for section: Int) -> String {
        let header = fetchedResultsController.sections?[section].name ?? ""
        print("header for section \(section) is \(header)")
        return header
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let record = fetchedResultsController.object(at: indexPath)
        return try? tracker(from: record)
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
    
    // Private methods
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let idString = trackerCoreData.id,
              let id = UUID(uuidString: idString) else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let schedule = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        let shceduleArray = schedule
            .split(separator: ",")
            .map { Int($0.trimmingCharacters(in: .whitespaces)) }
            .compactMap { WeekDay(rawValue: $0 ?? .max) }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: shceduleArray)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSection = IndexSet()
        deletedSection = IndexSet()
        insertedIndexes = IndexPath()
        deletedIndexes = IndexPath()
        updatedIndexes = IndexSet()
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
        
        // Update delegate with indexes
        delegate?.didUpdate(DataProviderUpdate(
            insertedSection: insertedSectionIndexSet,
            deletedSection: deletedSectionIndexSet,
            insertedIndexes: insertedItem,
            deletedIndexes: deletedItem,
            updatedIndexes: updatedItem,
            movedIndexes: movedItem)
        )
        
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
            updatedIndexes?.insert(indexPath.item)
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
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var color: String
    @NSManaged var emoji: String
    @NSManaged var schedule: [WeekDay]
    @NSManaged var category: TrackerCategory?
    @NSManaged var records: Set<TrackerRecord>?
}

class TrackerCategory: NSManagedObject {
    @NSManaged var header: String
    @NSManaged var trackers: Set<Tracker>?
}

class TrackerRecord: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var tracker: Tracker?
}
*/
