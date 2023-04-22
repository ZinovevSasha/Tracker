import CoreData
import UIKit

protocol TrackerStoreProtocol {
    func delete(_ record: TrackerCoreData) throws
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData
}

final class TrackerStore {
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
extension TrackerStore: TrackerStoreProtocol {
    func delete(_ record: TrackerCoreData) throws {
        context.delete(record)
        saveContext()
    }
    
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData {
        let tracker = updateExistingTracker(with: tracker)
        return tracker
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
    
    func updateExistingTracker(
        with tracker: Tracker
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
}
