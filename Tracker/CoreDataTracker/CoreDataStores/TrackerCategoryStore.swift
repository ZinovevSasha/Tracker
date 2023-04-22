import CoreData

protocol TrackerCategoryStoreProtocol {
    func addCategory(with name: String, and tracker: TrackerCoreData) throws
    func getAllCategories() -> [TrackerCategory]
}

final class TrackerCategoryStore {
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
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addCategory(with name: String, and tracker: TrackerCoreData) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", name)
        
        do {
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
        } catch {
            print("Error adding tracker to category: \(error.localizedDescription)")
        }
    }
    
    func getAllCategories() -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            return try categories.map { try updateCategories($0) }
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Private
private extension TrackerCategoryStore {
    func updateCategories(
        _ trackerCategoriesCoreData: TrackerCategoryCoreData
    ) throws -> TrackerCategory {
        
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
