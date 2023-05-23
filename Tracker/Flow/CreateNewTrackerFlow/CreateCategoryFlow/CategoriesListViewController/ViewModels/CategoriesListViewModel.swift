import CoreData

protocol CategoriesListViewModelProtocol {
    var categories: [CategoryViewModel] { get }
    func getAllCategories()
    func isNameAvailable(name: String) -> Bool?
    func categoryNameEntered(name: String)
    func categorySelected(at indexPath: IndexPath)
}

final class CategoriesListViewModel {
    @Observable var categories: [CategoryViewModel] = []
    
    private var categoryName: String
    
    // Store
    private var categoryStore: TrackerCategoryStore?
    
    private var context: NSManagedObjectContext? {
        try? Context.getContext()
    }
        
    // MARK: - Init
    init(categoryName: String, categoryStore: TrackerCategoryStore? = nil) {
        self.categoryName = categoryName
        guard let context = context else { return }
        self.categoryStore = TrackerCategoryStore(context: context)
    }
}

// MARK: - Init
extension CategoriesListViewModel: CategoriesListViewModelProtocol {
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
            .filter { $0.header != "Attached" }
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
