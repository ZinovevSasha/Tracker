import CoreData

protocol TrackerStoreProtocol {
    func delete(_ record: TrackerCoreData) throws
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData
}

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Public
extension TrackerStore: TrackerStoreProtocol {
    func delete(_ record: TrackerCoreData) throws {
        context.delete(record)
        saveContext()
    }
    
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = convertToTrackerCoreData(tracker)
        return trackerCoreData
    }
}

// MARK: - Private
private extension TrackerStore {
    func convertToTrackerCoreData(
        _ tracker: Tracker
    ) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.id = tracker.stringID
        trackerCoreData.color = tracker.color
        trackerCoreData.schedule = tracker.stringSchedule
        return trackerCoreData
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
}
extension TrackerCoreData {
    func tracker() throws -> Tracker {
        guard let id = toUUID(self.id) else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        guard let name = self.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = self.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = self.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let scheduleString = self.schedule,
            let schedule = Set.fromString(scheduleString) else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    func toUUID(_ string: String?) -> UUID? {
        return UUID(uuidString: string ?? "")
    }
}
