import Foundation

extension Date {
    static let dateFormatter = DateFormatter()
    
    var weekDayNumber: Int {
        Date.currentWeekDayNumber(from: self)
    }
    
    var todayString: String {
        Date.dateString(for: self)
    }
    
    static func dateString(for date: Date) -> String {
        Date.dateFormatter.dateFormat = "yyyy-MM-dd"
        return Date.dateFormatter.string(from: date)
    }
    
    static func currentWeekDayNumber(from day: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        // days will be from 0 to 6 (monday, sunday)
        let weekday = (calendar.component(.weekday, from: day) + 5) % 7
        return weekday
    }
}
