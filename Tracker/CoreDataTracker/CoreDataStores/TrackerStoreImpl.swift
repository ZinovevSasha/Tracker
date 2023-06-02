import CoreData

protocol TrackerStoreProtocol {
    func deleteTrackerWith(id: String) throws
    func pinTrackerWith(id: String)
    func unPinTrackerWith(id: String)
    
    func createTrackerCoreData(_ tracker: Tracker) throws -> TrackerCoreData
    func getCategoryHeaderForTrackerWith(id: String) -> String?
    func getTrackerBy(id: String) -> TrackerCoreData?
    func save(tracker: Tracker, categoryHeader: String) throws
    func getTrackedDaysNumberFor(id: String) -> Int?
}

final class TrackerStoreImpl {
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
extension TrackerStoreImpl: TrackerStoreProtocol {
    func deleteTrackerWith(id: String) throws {
        if let tracker = getTrackerBy(id: id) {
            context.delete(tracker)
            saveContext()
        }
    }
    
    func pinTrackerWith(id: String) {
        if let tracker = getTrackerBy(id: id) {
            tracker.isPinned = true
            saveContext()
        }
    }
    
    func unPinTrackerWith(id: String) {
        if let tracker = getTrackerBy(id: id) {
            tracker.isPinned = false
            saveContext()
        }
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
        return trackerCoreData?.category?.header
    }
    
    func getTrackerBy(id: String) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: id).build()
        let trackerCoreData = try? context.fetch(fetchRequest).first
        return trackerCoreData
    }
    
    func update(tracker: Tracker) throws -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: tracker.id).build()
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            return updateCoreData(trackerCoreData: trackerCoreData, with: tracker)
        } else {
            return nil
        }
    }
    
    func save(tracker: Tracker, categoryHeader: String) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.id, value: tracker.id).build()
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            updateCoreData(trackerCoreData: trackerCoreData, with: tracker)
        }
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
}

// MARK: - Private
private extension TrackerStoreImpl {
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    
    func updateCoreData(trackerCoreData: TrackerCoreData, with newTracker: Tracker) -> TrackerCoreData {
        
        trackerCoreData.id = newTracker.id
        trackerCoreData.name = newTracker.name
        trackerCoreData.schedule = newTracker.schedule.toNumbersString()
        trackerCoreData.emoji = newTracker.emoji
        trackerCoreData.color = newTracker.color
        return trackerCoreData
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
        self.isPinned = tracker.isPinned
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
            isPinned: self.isPinned, kind: trackertype)
    }
}
