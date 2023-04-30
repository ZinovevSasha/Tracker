import CoreData

final class CategoriesListViewModel {
    @Observable var categories: [CategoryViewModel] = []
    
    // Store
    private var categoryStore: TrackerCategoryStore?
    
    private var context: NSManagedObjectContext? {
        try? Context.getContext()
    }
    
    private var categoryName: String
    
    init(categoryName: String, categoryStore: TrackerCategoryStore? = nil) {
        self.categoryName = categoryName
        guard let context = context else { return }
        self.categoryStore = TrackerCategoryStore(context: context)
    }
}

extension CategoriesListViewModel {
    func categoryNameEntered(name: String) {
        do {
            try categoryStore?.addCategory(with: name)
            getAllCategories()
        } catch {
            print(error)
        }
    }
    
    func getAllCategories() {
        categories = categoryStore?.getAllCategories()
            .map {
                let isLastCelected = $0.header == categoryName
                return CategoryViewModel(
                    header: $0.header,
                    isLastSelectedCategory: isLastCelected)
            } ?? []
    }
    
    func isNameAvailable(name: String) -> Bool? {
        try? categoryStore?.isNameAvailable(name: name)
    }
    
    func categorySelected(at indexPath: IndexPath) {
        categories.forEach { $0.isLastSelectedCategory = false }
        categories[indexPath.row].isLastSelectedCategory = true
    }
}
