import CoreData

final class TrackerRecordStore {
    enum TrackerStoreError: Error {
        case decodingErrorInvalidId
        case decodingErrorInvalidName
        case decodingErrorInvalidColor
        case decodingErrorInvalidEmoji
        case decodingErrorInvalidSchedule
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Public
extension TrackerRecordStore {
    func getTrackedDaysNumberForTracker(tracker: TrackerCoreData) throws -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.recordId), tracker.id ?? "")
        let trackerRecordsCoreData = try context.fetch(fetchRequest)
        return trackerRecordsCoreData.count
    }
    
    func addTrackerRecord(_ record: TrackerCoreData) throws {
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.recordId = record.id
        trackerRecord.date = Date.dateString(for: Date())
        trackerRecord.tracker = record
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
