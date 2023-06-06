import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: String?) throws -> Int
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool
    func removeOrAddRecordOf(tracker: TrackerCD, forParticularDay day: String) throws
}

extension TrackerRecordCD: Identible {}
struct TrackerRecordStore: Store {
    typealias EntityType = TrackerRecordCD
        
    let context: NSManagedObjectContext
    var predicateBuilder: PredicateBuilder<TrackerRecordCD>
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: PredicateBuilder<TrackerRecordCD> = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }
}

// MARK: - Public
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: String?) throws -> Int {
        guard let id = id else { return .zero }
        return getObjectBy(id: id)?.count ?? .zero
    }
    
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool {
        let fetchRequest = TrackerRecordCD.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: id ?? "")
            .addPredicate(.equalTo, keyPath: \.date, value: selectedDay)
            .build(type: .and)
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
            trackerRecord.id = tracker.id
            trackerRecord.date = day
            trackerRecord.tracker = tracker
        }
        save()
    }
}
