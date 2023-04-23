import Foundation

extension Date {
    static let dateFormatter = DateFormatter()
    
    var weekdayNumber: Int {
        Date.currentWeekDayNumber(from: Date())
    }
    
    static func dateString(for date: Date) -> String {
        Date.dateFormatter.dateFormat = "yyyy-MM-dd"
        return Date.dateFormatter.string(from: date)
    }
    
    static func currentWeekDayNumber(from day: Date) -> Int {
        let calendar = Calendar(identifier: .coptic)
        // days will be from 0 to 6 (monday, sunday)
        let weekday = (calendar.component(.weekday, from: day) + 5) % 7
        return weekday
    }
}
