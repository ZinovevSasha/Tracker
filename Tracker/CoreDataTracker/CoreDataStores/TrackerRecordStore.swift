import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: String?) throws -> Int
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool
    func removeOrAddRecordOf(tracker: TrackerCD, forParticularDay day: String) throws
    func getNumberOfCompletedTrackers() -> Int
    func getAllRecords() -> [TrackerRecordCD]?
}

extension TrackerRecordCD: Identible {}
struct TrackerRecordStore: Store {
    typealias EntityType = TrackerRecordCD
        
    let context: NSManagedObjectContext
    var predicateBuilder: TrackerRecordPredicateBuilderProtocol
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: TrackerRecordPredicateBuilderProtocol = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }

    init() {
        let context = Context.shared.context
        self.init(context: context)
    }
}

// MARK: - Public
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: String?) throws -> Int {
        guard let id = id else { return .zero }
        return getObjectBy(id: id)?.count ?? .zero
    }

    func getNumberOfCompletedTrackers() -> Int {
        let fetchRequest = TrackerRecordCD.fetchRequest()
        let trackerRecordsCoreData = try? context.fetch(fetchRequest)
        return trackerRecordsCoreData?.count ?? .zero
    }
    
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool {
        guard let id = id else { return false }
        let fetchRequest = TrackerRecordCD.fetchRequest()
        let predicate = predicateBuilder.buildPredicateIsCompletedFor(selectedDate: selectedDay, trackerWithId: id)
        fetchRequest.predicate = predicate
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.first != nil ? true : false
    }
    
    func removeOrAddRecordOf(tracker: TrackerCD, forParticularDay day: String) throws {
        let fetchRequest = TrackerRecordCD.fetchRequest()
        let trackerRecordCoreData = try context.fetch(fetchRequest)
        
        if let trackerToRemoveIndex = trackerRecordCoreData.firstIndex(
            where: { $0.date == day && $0.id == tracker.id }) {
            // Remove the tracker record from the array
            context.delete(trackerRecordCoreData[trackerToRemoveIndex])
        } else {
            // Create new record
            let trackerRecord = TrackerRecordCD(context: context)
            trackerRecord.identifier = tracker.identifier
            trackerRecord.date = day
            trackerRecord.tracker = tracker
        }
        save()
    }

    func getAllRecords() -> [TrackerRecordCD]? {
        let request = TrackerRecordCD.fetchRequest()
        return try? context.fetch(request)
    }
}
