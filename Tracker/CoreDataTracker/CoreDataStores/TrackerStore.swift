import CoreData

protocol TrackerStoreProtocol {
    func delete(_ record: TrackerCoreData) throws
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData   
}

final class TrackerStore {
    private let context: NSManagedObjectContext
    private var predicateBuilder: PredicateBuilder<TrackerCoreData>
    
    init(context: NSManagedObjectContext,
         predicateBuilder: PredicateBuilder<TrackerCoreData> = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
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
    
    func getCategoryHeaderForTrackerWith(id: String) -> String? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: id)
            .build()
        let trackerCoreData = try? context.fetch(fetchRequest).first        
        return trackerCoreData?.lastCategory ?? trackerCoreData?.category?.header
    }
    
    func getTrackerBy(id: String) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: id).build()
        let trackerCoreData = try? context.fetch(fetchRequest).first
        return trackerCoreData
    }
    
    func getTrackedDaysNumberFor(id: String) -> Int? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: id).build()
        if let trackerCoreData = try? context.fetch(fetchRequest).first {
            return trackerCoreData.trackerRecord?.count
        } else {
            return nil
        }
    }
    
    func save(tracker: Tracker, andUpdateItsCategory category: TrackerCategoryCoreData) throws {
        if let trackerCoreData = getTrackerBy(id: tracker.id) {
            updateCoreData(tracker: trackerCoreData, with: tracker)
            if trackerCoreData.lastCategory != nil {
                trackerCoreData.lastCategory = category.header
            } else {
                trackerCoreData.category = category
            }
            saveContext()
        }
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
       
    func updateCoreData(tracker: TrackerCoreData, with newTracker: Tracker) {
        tracker.id = newTracker.id
        tracker.name = newTracker.name
        tracker.schedule = newTracker.schedule.toNumbersString()
        tracker.emoji = newTracker.emoji
        tracker.color = newTracker.color
        tracker.type = newTracker.kind.rawValue
        tracker.isAttached = newTracker.isAttached
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
        self.schedule = tracker.schedule.toNumbersString()
        self.isAttached = tracker.isAttached
        self.type = tracker.kind.rawValue
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
        guard let schedule = self.schedule,
                let scheduleSet = Set.fromString(schedule) else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let type = self.type, let trackertype = Tracker.Kind(rawValue: type) else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        return Tracker(
            id: id, name: name, emoji: emoji,
            color: color, schedule: scheduleSet,
            isAttached: self.isAttached, kind: trackertype)
    }
}
