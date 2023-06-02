import CoreData

protocol TrackerStoreManagerProtocol {
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData
    func save(tracker: Tracker, andUpdateItsCategory category: TrackerCategoryCoreData) throws
    func getCategoryHeaderForTrackerWith(id: String) -> String?
    func getTrackedDaysNumberFor(id: String) -> Int?
    func getTrackerBy(id: String) -> TrackerCoreData?
}

protocol TrackerStoreDataProviderProtocol {
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData
    func delete(_ record: TrackerCoreData) throws
}

struct TrackerStore: Store {
    typealias EntityType = TrackerCoreData
    
    let context: NSManagedObjectContext
    var predicateBuilder: PredicateBuilder<TrackerCoreData>
    
    init(context: NSManagedObjectContext,
         predicateBuilder: PredicateBuilder<TrackerCoreData> = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }
}

// MARK: - Public
extension TrackerStore: TrackerStoreManagerProtocol {
    func getCategoryHeaderForTrackerWith(id: String) -> String? {
        let trackerCoreData = getTrackerBy(id: id)
        return trackerCoreData?.lastCategory ?? trackerCoreData?.category?.header
    }
    
    func getTrackedDaysNumberFor(id: String) -> Int? {
        getTrackerBy(id: id)?.trackerRecord?.count ?? nil
    }
    
    func save(tracker: Tracker, andUpdateItsCategory category: TrackerCategoryCoreData) throws {
        if let trackerCoreData = getTrackerBy(id: tracker.id) {
            trackerCoreData.update(with: tracker)
            if trackerCoreData.lastCategory != nil {
                trackerCoreData.lastCategory = category.header
            } else {
                trackerCoreData.category = category
            }
            save()
        }
    }
    
    func getTrackerBy(id: String) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: id).build()
        let trackerCoreData = try? context.fetch(fetchRequest).first
        return trackerCoreData
    }
}

extension TrackerStore: TrackerStoreDataProviderProtocol {
    func createTrackerCoreData(_ tracker: Tracker) -> TrackerCoreData {
        return TrackerCoreData(tracker: tracker, context: context)
    }
    
    func delete(_ record: TrackerCoreData) throws {
        context.delete(record)
        save()
    }
}

extension TrackerCoreData {
    convenience init(tracker: Tracker, context: NSManagedObjectContext) {
        self.init(context: context)
        update(with: tracker)
    }
    
    func update(with tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color
        self.schedule = tracker.schedule.toNumbersString()
        self.isAttached = tracker.isAttached
        self.type = tracker.kind.rawValue
    }
}
