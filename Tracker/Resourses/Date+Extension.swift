import Foundation

extension Date {
    static let dateFormatter = DateFormatter()
    
    static func dateString(for date: Date) -> String {
        Date.dateFormatter.dateFormat = "yyyy-MM-dd"
        return Date.dateFormatter.string(from: date)
    }
    
    static func  currentWeekDayNumber(from day: Date) -> Int {
        let calendar = Calendar(identifier: .coptic)
        let dayNumber = calendar.component(.weekday, from: day)
        return dayNumber
    }
}
