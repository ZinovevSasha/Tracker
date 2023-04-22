import Foundation

struct User {
    var selectedCategory: String?
    var selectedName: String?
    var selectedWeekDay: [WeekDay] = []
    var selectedEmoji: IndexPath?
    var selectedColor: IndexPath?
    
    var isUserGaveEnoughToCreateTracker: Bool {
        if selectedCategory != nil,
            selectedName != nil,
            selectedEmoji != nil,
            selectedColor != nil {
            return true
        } else {
            return false
        }
    }
    
    mutating func setCategory(_ selectedCategory: String?) {
        self.selectedCategory = selectedCategory
    }
    
    mutating func setTitle(_ title: String?) {
        self.selectedName = title
    }
    
    mutating func setWeekDay(_ weekDay: [WeekDay]) {
        self.selectedWeekDay = weekDay
    }

    mutating func setEmojiIndexPath(_ indexPath: IndexPath?) {
        self.selectedEmoji = indexPath
    }

    mutating func setColorIndexPath(_ indexPath: IndexPath?) {
        self.selectedColor = indexPath
    }
}
