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
        let shcedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ", ")
        trackerCoreData.schedule = shcedule
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
        guard let schedule = self.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        // turn array string ["1", "2","4"] to [WeekDay] array
        let scheduleArray = schedule
            .split(separator: ",")
            .map { Int($0.trimmingCharacters(in: .whitespaces)) }
            .compactMap { WeekDay(rawValue: $0 ?? .bitWidth) }
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: scheduleArray)
    }
}
extension String {
    func toUUID() -> UUID? {
        return UUID(uuidString: self)
    }
}
//extension Array where Element == WeekDay {
//    // Function to return whether an array contains all days of the week
//    func containsAllDaysOfWeek() -> Bool {
//        let allDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
//        let selfSet = Set(self)
//        return allDays.isSubset(of: selfSet)
//    }
//}

extension Array where Element == WeekDay {
    // Function to check if an array contains all days of the week based on a condition
    func containsAllDaysOfWeekImproved(_ condition: (WeekDay) -> Bool) -> Bool {
        let allDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        return allDays.allSatisfy { day in
            self.contains(day) && condition(day)
        }
    }
}
