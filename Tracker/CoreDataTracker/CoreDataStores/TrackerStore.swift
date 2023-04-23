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
        trackerCoreData.id = String(describing: tracker.id)
        trackerCoreData.color = tracker.color
//        let shcedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ", ")
//        trackerCoreData.schedule = shcedule
        trackerCoreData.schedule = tracker.schedule.toNumbersString()
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
        guard let id = self.id?.toUUID() else {
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
        // turn array string ["1", "2","4"] to [WeekDay] array
//        let scheduleArray = scheduleString
//            .split(separator: ",")
//            .map { Int($0.trimmingCharacters(in: .whitespaces)) }
//            .compactMap { WeekDay(rawValue: $0 ?? .bitWidth) }
        
        
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
extension String {
    func toUUID() -> UUID? {
        return UUID(uuidString: self)
    }
}
