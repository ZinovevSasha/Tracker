import CoreData

protocol CategoriesListViewModelProtocol {
    var categories: [CategoryViewModel] { get }
    func getAllCategories()
    func isNameAvailable(name: String) -> Bool?
    func categoryNameEntered(name: String)
    func categorySelected(at indexPath: IndexPath)
}

final class CategoriesListViewModel {
    var categoryHeader: ((String) -> Void)?
    
    @Observable var categories: [CategoryViewModel] = []
   
    // Store
    private var categoryStore: TrackerCategoryListProtocol?
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore? = nil) {
        self.categoryStore = try? TrackerCategoryStore()
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
                return CategoryViewModel(
                    header: $0.header,
                    isLastSelectedCategory: $0.isLastSelected)
            } ?? []
    }
    
    func isNameAvailable(name: String) -> Bool? {
        try? categoryStore?.isNameAvailable(name: name)
    }
    
    func categorySelected(at indexPath: IndexPath) {
        let categoryName = categories[indexPath.row].header
        categoryHeader?(categoryName)
        markCategoryWith(name: categoryName)
    }
    
    func markCategoryWith(name: String) {
        categoryStore?.removeMarkFromLastSelectedCategory()
        categoryStore?.markCategoryAsLastSelected(categoryName: name)
    }
}
