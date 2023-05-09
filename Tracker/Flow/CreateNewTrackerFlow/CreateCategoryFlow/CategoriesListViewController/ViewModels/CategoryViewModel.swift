final class CategoryViewModel {
    var header: String
    var isLastSelectedCategory: Bool
    
    init(header: String, isLastSelectedCategory: Bool) {
        self.header = header
        self.isLastSelectedCategory = isLastSelectedCategory
    }
}
