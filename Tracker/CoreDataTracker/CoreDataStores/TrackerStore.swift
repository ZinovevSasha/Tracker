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
    
    convenience init() throws {
        let context = try Context.getContext()
        self.init(context: context)
    }
}

// MARK: - Public
extension TrackerStore: TrackerStoreProtocol {
    func delete(_ record: TrackerCoreData) throws {
        context.delete(record)
        saveContext()
    }
    
    func createTrackerCoreData(_ tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(tracker: tracker, context: context)
        return trackerCoreData
    }
}

// MARK: - Private
private extension TrackerStore {
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
    convenience init(tracker: Tracker, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.schedule = tracker.schedule
        self.isAttached = tracker.isAttached
        self.type = tracker.type.rawValue
    }
    
    func tracker() throws -> Tracker {
        guard let id = self.id else {
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
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let type = self.type, let trackertype = UserTracker.TrackerType(rawValue: type) else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        return Tracker(
            id: id, name: name, emoji: emoji,
            color: color, schedule: schedule,
            isAttached: self.isAttached, type: trackertype)
    }
}
