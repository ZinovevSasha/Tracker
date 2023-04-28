import Foundation

struct User {
    var selectedCategory: String?
    var selectedName: String?
    var selectedWeekDay: Set<Int>?
    var selectedEmoji: IndexPath?
    var selectedColor: IndexPath?
    
    enum TrackerFields {
        case category, name, weekDay, emoji, color
    }
    
    func isUserGaveEnoughToCreateTracker(of type: TrackerType) -> Bool {
        var errorFields = Set<TrackerFields>()
        
        if selectedCategory?.isEmpty ?? true {
            errorFields.insert(.category)
        }
        if selectedName?.isEmpty ?? true {
            errorFields.insert(.name)
        }
        if selectedEmoji?.isEmpty ?? true {
            errorFields.insert(.emoji)
        }
        if selectedColor?.isEmpty ?? true {
            errorFields.insert(.color)
        }
        
        if type == .habit {
            if selectedWeekDay?.isEmpty ?? true {
                errorFields.insert(.weekDay)
            }
        }
        return errorFields.isEmpty
    }
}

extension User {
    mutating func setCategory(_ selectedCategory: String?) {
        self.selectedCategory = selectedCategory
    }
    
    mutating func setTitle(_ title: String?) {
        self.selectedName = title
    }
    
    mutating func setWeekDay(_ weekDay: Set<Int>) {
        self.selectedWeekDay = weekDay
    }

    mutating func setEmojiIndexPath(_ indexPath: IndexPath?) {
        self.selectedEmoji = indexPath
    }

    mutating func setColorIndexPath(_ indexPath: IndexPath?) {
        self.selectedColor = indexPath
    }
}
