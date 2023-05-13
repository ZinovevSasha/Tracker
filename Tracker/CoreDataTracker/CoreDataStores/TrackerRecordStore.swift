import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(tracker: TrackerCoreData) throws -> Int
    func removeTrackerRecordOrAdd(_ record: TrackerCoreData, with day: String) throws
    func isTrackerCompletedForToday(_ tracker: TrackerCoreData) throws -> Bool
    func isTrackerCompletedFor(selectedDay: String, _ tracker: TrackerCoreData) throws -> Bool
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let predicate = PredecateBuilder<TrackerRecordCoreData>()
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Public
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackedDaysNumberFor(tracker: TrackerCoreData) throws -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.recordId, value: tracker.id ?? "").build()
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.count
    }
    
    func isTrackerCompletedForToday(_ tracker: TrackerCoreData) throws -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.recordId, value: tracker.id ?? "")
            .addPredicate(.equalTo, keyPath: \.date, value: Date.dateString(for: Date()))
            .build(type: .and)
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.first != nil ? true : false
    }

    func isTrackerCompletedFor(selectedDay: String, _ tracker: TrackerCoreData) throws -> Bool {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.recordId, value: tracker.id ?? "")
            .addPredicate(.equalTo, keyPath: \.date, value: selectedDay)
            .build(type: .and)
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.first != nil ? true : false
    }
    
    func removeTrackerRecordOrAdd(_ record: TrackerCoreData, with day: String) throws {
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
