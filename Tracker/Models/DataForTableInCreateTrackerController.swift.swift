import Foundation

struct DataForTableInCreateTrackerController {
    private var category = RowData(title: "Категория", subtitle: "")
    private var schedule = RowData(title: "Расписание", subtitle: "")
    
    var oneRow: [RowData] {
        [category]
    }
    
    var twoRows: [RowData] {
        [category, schedule]
    }
    
    mutating func addCategory(_ subtitle: String) {
        category.subtitle = subtitle
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
