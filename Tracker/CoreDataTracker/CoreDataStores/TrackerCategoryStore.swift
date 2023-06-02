import CoreData

protocol TrackerCategoryStoreProtocol {
    func addTracker(toCategoryWithName name: String, tracker: TrackerCoreData) throws
    func getAllCategories() -> [TrackerCategory]    
}

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let predicateBuilder = PredicateBuilder<TrackerCategoryCoreData>()
        
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
        let categories = try fetchTrackerCategories(context: context) { [weak self] in
            guard let self = self else {
                return NSPredicate()
            }
            return self.predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: name).build()
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
    
    func removeTrackerFromCategory(withName name: String?, tracker: TrackerCoreData) throws {
        guard let name = name else { return }
        let categories = try fetchTrackerCategories(context: context) {
            self.predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: name).build()
        }
        if let category = categories.first {
            category.removeFromTrackers(tracker)
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
    
    func markCategoryAsLastSelected(categoryName: String) {
        let categories = try? fetchTrackerCategories(context: context) {
            self.predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: categoryName).build()
        }
        
        if let category = categories?.first {
            category.isLastSelected = true
        }
        saveContext()
    }
    
    func removeMarkFromLastSelectedCategory() {
        let categories = try? fetchTrackerCategories(context: context) {
            NSPredicate(format: "%K == %@",
                        #keyPath(TrackerCategoryCoreData.isLastSelected),
                        NSNumber(value: true)
            )
        }
        if let category = categories?.first {
            category.isLastSelected = false
        }
        saveContext()
    }
    
    func getNameOfLastSelectedCategory() -> String? {
        let categories = try? fetchTrackerCategories(context: context) {
            NSPredicate(format: "%K == %@",
                        #keyPath(TrackerCategoryCoreData.isLastSelected),
                        NSNumber(value: true)
            )
        }
        if let category = categories?.first {
            return category.header
        }
        return nil
    }
}

// MARK: - Private
private extension TrackerCategoryStore {
    func convertToTrackerCategory(_ category: TrackerCategoryCoreData) throws -> TrackerCategory {
        if let trackersCoreData = category.trackers?.allObjects as? [TrackerCoreData] {
            let trackers = try trackersCoreData.map { try $0.tracker() }
            return TrackerCategory(
                header: category.header ?? "",
                trackers: trackers,
                isLastSelected: category.isLastSelected
            )
        } else {
            return TrackerCategory(
                header: category.header ?? "",
                trackers: [],
                isLastSelected: category.isLastSelected
            )
        }
        
        
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
