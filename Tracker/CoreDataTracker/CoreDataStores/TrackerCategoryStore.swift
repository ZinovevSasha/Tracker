import CoreData

protocol TrackerCategoryStoreProtocol {
    func addCategory(with name: String) throws -> TrackerCategoryCoreData?
    func addTracker(toCategoryWithName name: String, tracker: TrackerCoreData) throws
    func remove(tracker: TrackerCoreData, fromCategoryWithName name: String)
    func getAllCategories() -> [TrackerCategory]
    func putToAttachedCategory(tracker: TrackerCoreData)
    func putBackToOriginalCategory(tracker: TrackerCoreData)
    func getNameOfLastSelectedCategory() -> String?
}

protocol TrackerCategoryListProtocol {
    func addCategory(with name: String) throws -> TrackerCategoryCoreData?
    func isNameAvailable(name: String) throws -> Bool
    func removeMarkFromLastSelectedCategory()
    func markCategoryAsLastSelected(categoryName: String)
    func getAllCategories() -> [TrackerCategory]
    func removeCategoryWith(name: String)
    func updateCategoryWith(id: String, byNewName name: String)
    func addCategory(name: String)
}

struct TrackerCategoryStore: Store {
    typealias EntityType = TrackerCategoryCoreData
            
    let context: NSManagedObjectContext
    var predicateBuilder = PredicateBuilder<TrackerCategoryCoreData>()
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: PredicateBuilder<TrackerCategoryCoreData> = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addTracker(toCategoryWithName name: String, tracker: TrackerCoreData) throws {
        if let category = getCategoryWith(name: name) {
            category.addToTrackers(tracker)
        } else {
            let category = TrackerCategoryCoreData(context: context)
            category.header = name
            category.addToTrackers(tracker)
        }
        save()
    }

    func addCategory(name: String) {
        let trackerCategory = TrackerCategory(id: UUID().uuidString, header: name, trackers: [], isLastSelected: false)
        TrackerCategoryCoreData(trackerCategory: trackerCategory, context: context)
        save()
    }
    
    func addCategory(with name: String) throws -> TrackerCategoryCoreData? {
        if let category = getCategoryWith(name: name) {
            return category
        } else {
            let category = TrackerCategoryCoreData(context: context)
            category.header = name
            save()
            return category
        }
    }
    
    func remove(tracker: TrackerCoreData, fromCategoryWithName name: String) {
        if let category = getCategoryWith(name: name) {
            category.removeFromTrackers(tracker)
            save()
        }
    }
    
    func removeCategoryWith(name: String) {
        if let category = getCategoryWith(name: name) {
            context.delete(category)
            save()
        }
    }
    
    func getAllCategories() -> [TrackerCategory] {
        do {
            return try fetchTrackerCategories(context: context).toTrackerCategories()
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getNameOfLastSelectedCategory() -> String? {
        getLastSelectedCategory()?.header
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

// MARK: - TrackerCategoryListProtocol
extension TrackerCategoryStore: TrackerCategoryListProtocol {
    func isNameAvailable(name: String) throws -> Bool {
        return (getCategoryWith(name: name) != nil) ? false : true
    }
    
    func removeMarkFromLastSelectedCategory() {
        if let category = getLastSelectedCategory() {
            category.isLastSelected = false
            save()
        }
    }
    
    func markCategoryAsLastSelected(categoryName: String) {
        if let category = getCategoryWith(name: categoryName) {
            category.isLastSelected = true
            save()
        }
    }
      
    func updateCategoryWith(id: String, byNewName name: String) {
        if let category = getCategoryBy(id: id) {
            category.id = id
            category.header = name
            save()
        }
    }
}

// MARK: - Private
private extension TrackerCategoryStore {
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
    
    func getCategoryBy(id: String) -> TrackerCategoryCoreData? {
        return try? fetchTrackerCategories(context: context) {
            predicateBuilder.addPredicate(.equalTo, keyPath: \.id, value: id).build()
        }.first
    }
    
    func getCategoryWith(name: String) -> TrackerCategoryCoreData? {
        return try? fetchTrackerCategories(context: context) {
            predicateBuilder.addPredicate(.equalTo, keyPath: \.header, value: name).build()
        }.first
    }
    
    func getLastSelectedCategory() -> TrackerCategoryCoreData? {
        return try? fetchTrackerCategories(context: context) {
            NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerCategoryCoreData.isLastSelected),
                NSNumber(value: true)
            )
        }.first
    }
}

extension TrackerCategoryCoreData {
    convenience init(trackerCategory: TrackerCategory, context: NSManagedObjectContext) {
        self.init(context: context)
        update(trackerCategory: trackerCategory)
    }

    func update(trackerCategory: TrackerCategory) {
        self.id = trackerCategory.id
        self.header = trackerCategory.header
        self.trackers = NSSet(array: trackerCategory.trackers)
        self.isLastSelected = trackerCategory.isLastSelected
    }
}

extension Array where Element == TrackerCategoryCoreData {
    func toTrackerCategories() -> [TrackerCategory] {
        return self.compactMap { category in
            TrackerCategory(coreData: category)
        }
    }
}
