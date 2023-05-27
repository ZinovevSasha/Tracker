import Foundation

protocol TrackerManagerProtocol {
    func createTracker(kind: Tracker.Kind, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws
    func updateTracker(kind: Tracker.Kind, id: String?, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws
    func getCategoryNameFor(trackerID: String) -> String?
    func getTrackerBy(id: String) -> TrackerCoreData?
    func getHeaderName() -> String?
}

struct TrackerManagerImpl: TrackerManagerProtocol {
    // MARK: - Dependencies
    private var trackerCategoryStore: TrackerCategoryStore? = {
        do {
            return try TrackerCategoryStore()
        } catch {
            return nil
        }
    }()
    
    private var trackerStore: TrackerStore? = {
        do {
            return try TrackerStore()
        } catch {
            return nil
        }
    }()
    
    // MARK: - Public methods
    func createTracker(kind: Tracker.Kind, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws {
        guard let name = name,
              let emoji = emoji,
              let color = color,
              let schedule = schedule,
              let categoryHeader = categoryHeader else { return }
                
        let tracker = Tracker(
            id: UUID().uuidString,
            name: name,
            emoji: emoji,
            color: color,
            schedule: schedule,
            kind: kind
        )
        
        if let trackerCoreData = trackerStore?.createTrackerCoreData(tracker) {
            try trackerCategoryStore?.addTracker(toCategoryWithName: categoryHeader, tracker: trackerCoreData)
        }
    }
    
    func updateTracker(kind: Tracker.Kind, id: String?, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws {
        guard let id = id,
              let name = name,
              let emoji = emoji,
              let color = color,
              let schedule = schedule,
              let categoryHeader = categoryHeader else { return }
                
        let tracker = Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: schedule,
            kind: kind
        )
        try trackerStore?.save(tracker: tracker, categoryHeader: categoryHeader)
    }
    
    func getCategoryNameFor(trackerID: String) -> String? {
        trackerStore?.getCategoryHeaderForTrackerWith(id: trackerID)
    }
    
    func getTrackerBy(id: String) -> TrackerCoreData? {
        trackerStore?.getTrackerBy(id: id)
    }
    
    func getHeaderName() -> String? {
        trackerCategoryStore?.getNameOfLastSelectedCategory()
    }
}
