import Foundation

protocol TrackerManagerProtocol {
    func getCategoryNameFor(trackerID: String) -> String?
    func getTrackerBy(id: String) -> TrackerCoreData?
    func getHeaderName() -> String?
    func getTrackedDaysNumberFor(id: String) -> Int?
    func isCompletedFor(date: String, trackerWithId id: String) -> Bool?
    func markAsTrackedFor(date: String?, trackerWithId id: String?) throws
    func createTracker(kind: Tracker.Kind, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?) throws
    func updateTracker(kind: Tracker.Kind, id: String?, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?, isAttached: Bool) throws
}

struct TrackerManagerImpl: TrackerManagerProtocol {
    // MARK: - Dependencies
    private var trackerCategoryStore: TrackerCategoryStoreProtocol? = {
        do {
            return try TrackerCategoryStore()
        } catch {
            return nil
        }
    }()
    
    private var trackerStore: TrackerStoreManagerProtocol? = {
        do {
            return try TrackerStore()
        } catch {
            return nil
        }
    }()
    
    private var trackerRecordStore: TrackerRecordStoreProtocol? = {
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
        
        var tracker: Tracker
        switch kind {
        case .habit:
            tracker = Tracker(
                id: UUID().uuidString,
                name: name,
                emoji: emoji,
                color: color,
                schedule: schedule,
                kind: kind
            )
        case .ocasional:
            tracker = Tracker(
                id: UUID().uuidString,
                name: name,
                emoji: emoji,
                color: color,
                schedule: WeekDay.allDaysOfWeek,
                kind: kind
            )
        }
        
        if let trackerCoreData = try trackerStore?.createTrackerCoreData(tracker) {
            try trackerCategoryStore?.addTracker(toCategoryWithName: categoryHeader, tracker: trackerCoreData)
        }
    }
    
    func updateTracker(kind: Tracker.Kind, id: String?, name: String?, emoji: String?, color: String?, schedule: Set<Int>?, categoryHeader: String?, isAttached: Bool) throws {
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
            isAttached: isAttached,
            kind: kind
        )
        
        if let category = try? trackerCategoryStore?.addCategory(with: categoryHeader) {
            try? trackerStore?.save(tracker: tracker, andUpdateItsCategory: category)
        }
    }
    
    func getCategoryNameFor(trackerID: String) -> String? {
        trackerStore?.getCategoryHeaderForTrackerWith(id: trackerID)
    }
    
    func getTrackedDaysNumberFor(id: String) -> Int? {
        trackerStore?.getTrackedDaysNumberFor(id: id)
    }
    
    func isCompletedFor(date: String, trackerWithId id: String) -> Bool? {
        try? trackerRecordStore?.isCompletedFor(date, trackerWithId: id)
    }
    
    func getTrackerBy(id: String) -> TrackerCoreData? {
        trackerStore?.getTrackerBy(id: id)
    }
    
    func getHeaderName() -> String? {
        trackerCategoryStore?.getNameOfLastSelectedCategory()
    }
    
    func markAsTrackedFor(date: String?, trackerWithId id: String?) throws {
        if let id, let date, let tracker = trackerStore?.getTrackerBy(id: id) {
            try trackerRecordStore?.removeOrAddRecordOf(tracker: tracker, forParticularDay: date)
        }
    }
}
