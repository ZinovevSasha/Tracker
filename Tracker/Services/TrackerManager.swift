import Foundation

protocol TrackerManagerProtocol {
    func createTracker(kind: Tracker.Kind, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws
    func updateTracker(kind: Tracker.Kind, id: String?, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws
    func getCategoryNameFor(trackerID: String) -> String?
    func getTrackerBy(id: String) -> TrackerCoreData?
    func getHeaderName() -> String?
    func getTrackedDaysNumberFor(id: String) -> Int?
    func isCompletedFor(date: String, trackerWithId id: String) -> Bool?
    func markAsTrackedFor(date: String?, trackerWithId id: String?) throws
    func removeTrackerWith(id: String)
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
    
    private var trackerStore: TrackerStoreImpl? = {
        do {
            return try TrackerStoreImpl()
        } catch {
            return nil
        }
    }()
    
    private var trackerRecordStore: TrackerRecordStore? = {
        do {
            return try TrackerRecordStore()
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
    
    func removeTrackerWith(id: String) {
        if let trackerCoreData = trackerStore?.getTrackerBy(id: id) {
            try? trackerCategoryStore?.removeTrackerFromCategory(withName: trackerCoreData.category?.header, tracker: trackerCoreData)
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
               
        if let trackerCoreData = try trackerStore?.update(tracker: tracker) {
            try trackerCategoryStore?.addTracker(toCategoryWithName: categoryHeader, tracker: trackerCoreData)
        }
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
    
    func getTrackedDaysNumberFor(id: String) -> Int? {
        trackerStore?.getTrackedDaysNumberFor(id: id)
    }
    
    func isCompletedFor(date: String, trackerWithId id: String) -> Bool? {
        try? trackerRecordStore?.isCompletedFor(date, trackerWithId: id)
    }
    
    func markAsTrackedFor(date: String?, trackerWithId id: String?) throws {
        if let id, let date, let tracker = trackerStore?.getTrackerBy(id: id) {
            try trackerRecordStore?.removeTrackerOrAdd(tracker, forParticularDay: date)
        }
    }
}
