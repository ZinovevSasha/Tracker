import Foundation

extension Date {
    /// A date formatter that can be reused to improve performance.
    private static let dateFormatter = DateFormatter()
    
    /// The day of the week represented as a number starting from 0 (Monday) to 6 (Sunday).
    private var weekDayNumber: Int {
        Date.currentWeekDayNumber(from: self)
    }
    
    var weekDayString: String {
        String(weekDayNumber)
    }
    
    /// A string representation of the date in the format "yyyy-MM-dd".
    var todayString: String {
        Date.dateString(for: self)
    }
    
    /// Returns a string representation of the specified date using the format "yyyy-MM-dd".
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A string representation of the date in the format "yyyy-MM-dd".
    static func dateString(for date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /// Returns the day of the week represented as a number starting from 0 (Monday) to 6 (Sunday).
    ///
    /// - Parameter day: The date to calculate the weekday for.
    /// - Returns: The day of the week represented as a number starting from 0 (Monday) to 6 (Sunday).
    static func currentWeekDayNumber(from day: Date) -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .current        
        let weekday = (calendar.component(.weekday, from: day) + 5) % 7
        return weekday
    }
}

