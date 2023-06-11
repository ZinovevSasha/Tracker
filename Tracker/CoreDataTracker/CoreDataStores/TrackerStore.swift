import CoreData

protocol TrackerStoreManagerProtocol {
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCD
    func save(tracker: Tracker, andUpdateItsCategory category: TrackerCategoryCD) throws
    func getCategoryHeaderForTrackerWith(id: String) -> String?
    func getTrackedDaysNumberFor(id: String) -> Int?
    func getObjectBy(id: String) -> [TrackerCD]?
    func delete(_ entity: TrackerCD) throws
}

protocol TrackerStoreDataProviderProtocol {
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCD
    func delete(_ record: TrackerCD) throws
    var isAnyTrackers: Bool { get }
}

struct TrackerStore: Store {
    typealias EntityType = TrackerCD
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    init() {
        let context = Context.shared.context
        self.init(context: context)
    }
}

// MARK: - TrackerStoreManagerProtocol
extension TrackerStore: TrackerStoreManagerProtocol {
    func getCategoryHeaderForTrackerWith(id: String) -> String? {
        let trackerCoreData = getObjectBy(id: id)?.first
        return trackerCoreData?.lastCategory ?? trackerCoreData?.category?.header
    }
    
    func getTrackedDaysNumberFor(id: String) -> Int? {
        getObjectBy(id: id)?.first?.trackerRecord?.count
    }
    
    func save(tracker: Tracker, andUpdateItsCategory category: TrackerCategoryCD) throws {
        if let trackerCoreData = getObjectBy(id: tracker.id)?.first {
            trackerCoreData.update(with: tracker)
            if trackerCoreData.lastCategory != nil {
                trackerCoreData.lastCategory = category.header
            } else {
                trackerCoreData.category = category
            }
            save()
        }
    }
}

// MARK: - TrackerStoreDataProviderProtocol
extension TrackerStore: TrackerStoreDataProviderProtocol {
    func createTrackerCoreData(_ tracker: Tracker) -> TrackerCD {
        return TrackerCD(from: tracker, context: context)
    }

    var isAnyTrackers: Bool {
        let fetchRequest = TrackerCD.fetchRequest()
        let trackers = try? context.fetch(fetchRequest)
        if let trackers {
            return trackers.isEmpty ? false : true
        }
        return false
    }
}

extension TrackerCD: Identible {
    convenience init(from tracker: Tracker, context: NSManagedObjectContext) {
        self.init(context: context)
        update(with: tracker)
    }
    
    func update(with tracker: Tracker) {
        self.identifier = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.schedule = tracker.schedule.toNumbersString()
        self.isAttached = tracker.isAttached
        self.type = tracker.kind.rawValue
    }
}
