final class CategoryViewModel {
    @Observable var header: String
    @Observable var isLastSelectedCategory: Bool
    
    init(header: String, isLastSelectedCategory: Bool) {
        self.header = header
        self.isLastSelectedCategory = isLastSelectedCategory
    }
}
