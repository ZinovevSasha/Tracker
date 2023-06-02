import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackedDaysNumberForTrackerWith(id: String) throws -> Int
    func removeTrackerOrAdd(_ record: TrackerCoreData, forParticularDay day: String) throws
    func isCompletedForToday(trackerWithId id: String?) throws -> Bool
    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private var predicate = PredicateBuilder<TrackerRecordCoreData>()
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() throws {
        let context = try Context.getContext()
        self.init(context: context)
    }
}

// MARK: - Public
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackedDaysNumberForTrackerWith(id: String) throws -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.recordId, value: id).build()
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.count
    }
    
    func isCompletedForToday(trackerWithId id: String?) throws -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.recordId, value: id ?? "")
            .addPredicate(.equalTo, keyPath: \.date, value: Date.dateString(for: Date()))
            .build(type: .and)
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.first != nil ? true : false
    }

    func isCompletedFor(_ selectedDay: String, trackerWithId id: String?) throws -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.recordId, value: id ?? "")
            .addPredicate(.equalTo, keyPath: \.date, value: selectedDay)
            .build(type: .and)
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.first != nil ? true : false
    }
    
    func removeTrackerOrAdd(_ record: TrackerCoreData, forParticularDay day: String) throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let trackerRecordCoreData = try context.fetch(fetchRequest)
        
        if let trackerToRemoveIndex = trackerRecordCoreData.firstIndex(
            where: { $0.date == day && $0.recordId == record.id }) {
            // Remove the tracker record from the array
            context.delete(trackerRecordCoreData[trackerToRemoveIndex])
        } else {
            // Create new record
            let trackerRecord = TrackerRecordCoreData(context: context)
            trackerRecord.recordId = record.id
            trackerRecord.date = day
            trackerRecord.tracker = record
        }
        saveContext()
    }
}

// MARK: - Private
private extension TrackerRecordStore {
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}
