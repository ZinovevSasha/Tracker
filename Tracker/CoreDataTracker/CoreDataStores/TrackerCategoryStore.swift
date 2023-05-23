import CoreData

protocol TrackerCategoryStoreProtocol {
    func addTracker(toCategoryWithName name: String, tracker: TrackerCoreData) throws
    func getAllCategories() -> [TrackerCategory]
    func putToAttachedCategory(tracker: TrackerCoreData)
    func putBackToOriginalCategory(tracker: TrackerCoreData)
}

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let predicateBuilder = PredecateBuilder<TrackerCategoryCoreData>()
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() throws {
        let context = try Context.getContext()
        self.init(context: context)
    }
}

// MARK: - Public
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addTracker(toCategoryWithName name: String, tracker: TrackerCoreData) throws {
        // Fetch all existing categories with the same name
        let categories = try fetchTrackerCategories(context: context) {
            self.predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: name).build()
        }
        
        if let category = categories.first {
            // Category already exists
            category.addToTrackers(tracker)
        } else {
            // Category does not exist, create new category
            let category = TrackerCategoryCoreData(context: context)
            category.header = name
            category.addToTrackers(tracker)
        }
        saveContext()
    }
    
    func addCategory(with name: String) throws {
        // Fetch all existing categories with the same name
        let categories = try fetchTrackerCategories(context: context) {
            self.predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: name).build()
        }
        
        // If a category with the same name already exists, return without doing anything
        if let category = categories.first {
            return
        }
        
        // Otherwise, create a new category with the given name and save it to the context
        let category = TrackerCategoryCoreData(context: context)
        category.header = name
        saveContext()
    }
    
    func isNameAvailable(name: String) throws -> Bool {
        // Fetch all existing categories with the same name
        let categories = try fetchTrackerCategories(context: context) {
            self.predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: name).build()
        }
        
        return (categories.first != nil) ? false : true
    }
    
    func getAllCategories() -> [TrackerCategory] {
        do {
            let categories = try fetchTrackerCategories(context: context)
            return try categories.map { try convertToTrackerCategory($0) }
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return []
        }
    }
    
    func putToAttachedCategory(tracker: TrackerCoreData) {
        tracker.isAttached = true
        tracker.lastCategory = tracker.category?.header
        try? addTracker(toCategoryWithName: "Attached", tracker: tracker)
    }
    
    func putBackToOriginalCategory(tracker: TrackerCoreData) {
        guard let lastCategory = tracker.lastCategory else { return }
        tracker.isAttached = false
        tracker.lastCategory = nil
        try? addTracker(toCategoryWithName: lastCategory, tracker: tracker)
    }
}

// MARK: - Private
private extension TrackerCategoryStore {
    func convertToTrackerCategory(_ category: TrackerCategoryCoreData) throws -> TrackerCategory {
        let header = category.header
        return TrackerCategory(
            header: header ?? "",
            trackers: []
        )
    }
    
    func fetchTrackerCategories(
        context: NSManagedObjectContext,
        withPredicate predicateClosure: (() -> NSPredicate)? = nil
    ) throws -> [TrackerCategoryCoreData] {
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        if let predicateClosure = predicateClosure {
            fetchRequest.predicate = predicateClosure()
        }
        
        let results = try context.fetch(fetchRequest)
        return results
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}
