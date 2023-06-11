import CoreData

protocol TrackerCategoryStoreProtocol {
    func addCategory(with name: String) throws -> TrackerCategoryCD?
    func addTracker(toCategoryWithName name: String, tracker: TrackerCD) throws
    func remove(tracker: TrackerCD, fromCategoryWithName name: String)
    func getAllCategories() -> [TrackerCategory]
    func putToAttachedCategory(tracker: TrackerCD)
    func putBackToOriginalCategory(tracker: TrackerCD)
    func getNameOfLastSelectedCategory() -> String?
}

protocol TrackerCategoryListProtocol {
    func addCategory(with name: String) throws -> TrackerCategoryCD?
    func isNameAvailable(name: String) throws -> Bool
    func removeMarkFromLastSelectedCategory()
    func markCategoryAsLastSelected(categoryName: String)
    func getAllCategories() -> [TrackerCategory]
    func removeCategoryWith(name: String)
    func update(category: TrackerCategory, withNewName name: String)
    func addCategory(name: String)
}

struct TrackerCategoryStore: Store {
    typealias EntityType = TrackerCategoryCD
            
    let context: NSManagedObjectContext
    var predicateBuilder: TrackerCategoryPredicateBuilderProtocol
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: TrackerCategoryPredicateBuilderProtocol = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }

    init() {
        let context = Context.shared.context
        self.init(context: context)
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addTracker(toCategoryWithName name: String, tracker: TrackerCD) throws {
        if let category = getCategoryWith(name: name) {
            category.addToTrackers(tracker)
        } else {
            let category = TrackerCategoryCD(context: context)
            category.header = name
            category.addToTrackers(tracker)
        }
        save()
    }

    func addCategory(name: String) {
        let trackerCategory = TrackerCategory(id: UUID().uuidString, header: name, trackers: [], isLastSelected: false)
        TrackerCategoryCD(trackerCategory: trackerCategory, context: context)
        save()
    }
    
    func addCategory(with name: String) throws -> TrackerCategoryCD? {
        if let category = getCategoryWith(name: name) {
            return category
        } else {
            let category = TrackerCategoryCD(context: context)
            category.header = name
            save()
            return category
        }
    }
    
    func remove(tracker: TrackerCD, fromCategoryWithName name: String) {
        if let category = getCategoryWith(name: name) {
            category.removeFromTrackers(tracker)
            save()
        }
    }
    
    func removeCategoryWith(name: String) {
        if let category = getCategoryWith(name: name) {
            try? delete(category)
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
    
    func putToAttachedCategory(tracker: TrackerCD) {
        tracker.isAttached = true
        tracker.lastCategory = tracker.category?.header
        try? addTracker(toCategoryWithName: Strings.Localizable.Main.pinned, tracker: tracker)
    }
    
    func putBackToOriginalCategory(tracker: TrackerCD) {
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
      
    func update(category: TrackerCategory, withNewName name: String) {
        if let category = getObjectBy(id: category.id)?.first {
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
    ) throws -> [TrackerCategoryCD] {
        let fetchRequest = TrackerCategoryCD.fetchRequest()
        if let predicateClosure = predicateClosure {
            fetchRequest.predicate = predicateClosure()
        }
        
        let results = try context.fetch(fetchRequest)
        return results
    }

    func getCategoryWith(name: String) -> TrackerCategoryCD? {
        return try? fetchTrackerCategories(context: context) {
            predicateBuilder.buildPredicateCategory(name: name)
        }.first
    }
    
    func getLastSelectedCategory() -> TrackerCategoryCD? {
        return try? fetchTrackerCategories(context: context) {
            predicateBuilder.buildPredicateCategoryIsLastSelected()
        }.first
    }
}

extension TrackerCategoryCD: Identible {
    convenience init(trackerCategory: TrackerCategory, context: NSManagedObjectContext) {
        self.init(context: context)
        update(with: trackerCategory)
    }

    func update(with trackerCategory: TrackerCategory) {
        self.identifier = trackerCategory.id
        self.header = trackerCategory.header
        self.trackers = NSSet(array: trackerCategory.trackers)
        self.isLastSelected = trackerCategory.isLastSelected
    }
}

extension Array where Element == TrackerCategoryCD {
    func toTrackerCategories() -> [TrackerCategory] {
        return self.compactMap { category in
            TrackerCategory(coreData: category)
        }
    }
}
