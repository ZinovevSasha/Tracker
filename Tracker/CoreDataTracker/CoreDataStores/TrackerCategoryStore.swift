import CoreData

protocol TrackerCategoryStoreProtocol {
    func addCategory(with name: String, and tracker: TrackerCoreData) throws
    func getAllCategories() -> [TrackerCategory]
}

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let predicateBuilder = PredecateBuilder<TrackerCategoryCoreData>()
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Public
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addCategory(with name: String, and tracker: TrackerCoreData) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.header, value: name)
            .build()
        let results = try context.fetch(fetchRequest)
        if let category = results.first {
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
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.header, value: name)
            .build()
        let results = try context.fetch(fetchRequest)
        if let category = results.first {
            // Category already exists
            return
        } else {
            // Category does not exist, create new category
            let category = TrackerCategoryCoreData(context: context)
            category.header = name            
        }
        saveContext()
    }
    
    func isNameAvailable(name: String) throws -> Bool {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = predicateBuilder
            .addPredicate(.equalTo, keyPath: \.header, value: name)
            .build()
        let results = try context.fetch(fetchRequest)
        if let category = results.first {
            return false
        } else {
            return true
        }
    }
    
    func getAllCategories() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let trackerCategoryCoreData = try context.fetch(fetchRequest)
            return try trackerCategoryCoreData.map { try convertToTrackerCategory($0) }
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Private
private extension TrackerCategoryStore {
    func convertToTrackerCategory(
        _ trackerCategoriesCoreData: TrackerCategoryCoreData
    ) throws -> TrackerCategory {
        // Get categories for catefory view controller
        let header = trackerCategoriesCoreData.header
        return TrackerCategory(
            header: header ?? "",
            trackers: []
        )
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}
