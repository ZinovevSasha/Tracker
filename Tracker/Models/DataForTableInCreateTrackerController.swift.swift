import Foundation

struct DataForTableInCreateTrackerController {
    private var category = RowData(title: "Категория", subtitle: "")
    private var schedule = RowData(title: "Расписание", subtitle: "")
    
    private let userDafaults = UserDefaults()
    enum Key: String {
        case categoryHeader
    }
    
    var categoryName: String {
        if let header = userDafaults.string(forKey: Key.categoryHeader.rawValue) {
            return header
        } else {
            return ""
        }
    }
    
    var oneRow: [RowData] {
        [RowData(title: "Категория", subtitle: categoryName)]
    }
    
    var twoRows: [RowData] {
        oneRow + [schedule]
    }
    
    
    
    mutating func addCategory(_ subtitle: String) {
        category.subtitle = subtitle
        userDafaults.set(subtitle, forKey: Key.categoryHeader.rawValue)
    }
    
    mutating func addSchedule(_ subtitle: String?) {
        guard let subtitle = subtitle else { return }
        schedule.subtitle = subtitle
    }
}

struct RowData {
    let title: String
    var subtitle: String
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
