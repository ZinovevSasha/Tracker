import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: String?) throws -> Int
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool
    func removeOrAddRecordOf(tracker: TrackerCoreData, forParticularDay day: String) throws
}

struct TrackerRecordStore: Store {
    typealias EntityType = TrackerRecordCoreData
        
    let context: NSManagedObjectContext
    var predicateBuilder: PredicateBuilder<TrackerRecordCoreData>
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: PredicateBuilder<TrackerRecordCoreData> = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }
}

// MARK: - Public
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(trackerWithId id: String?) throws -> Int {
        return try getTrackerRecord(forID: id).count
    }
    
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.recordId, value: id ?? "")
            .addPredicate(.equalTo, keyPath: \.date, value: selectedDay)
            .build(type: .and)
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.first != nil ? true : false
    }
    
    func removeOrAddRecordOf(tracker: TrackerCoreData, forParticularDay day: String) throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let trackerRecordCoreData = try context.fetch(fetchRequest)
        
        if let trackerToRemoveIndex = trackerRecordCoreData.firstIndex(
            where: { $0.date == day && $0.recordId == tracker.id }) {
            // Remove the tracker record from the array
            context.delete(trackerRecordCoreData[trackerToRemoveIndex])
        } else {
            // Create new record
            let trackerRecord = TrackerRecordCoreData(context: context)
            trackerRecord.recordId = tracker.id
            trackerRecord.date = day
            trackerRecord.tracker = tracker
        }
        save()
    }
    
    // MARK: - Private
    private func getTrackerRecord(forID id: String?) throws -> [TrackerRecordCoreData] {
        guard let id = id else { return [] }
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.recordId, value: id).build()
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData
    }
}
