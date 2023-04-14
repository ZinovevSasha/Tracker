import Foundation

enum WeekDay: Int, CaseIterable, Comparable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    static var array: [WeekDay] {
        WeekDay.allCases
    }
    
    static var count: Int {
        array.count
    }
    
    static func shortNameFor(_ dayNumber: Int) -> String? {
        let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        // check if the dayNumber is within the range of
        // valid indices for the days array (i.e., 0 to 6).
        guard 0..<days.count ~= dayNumber else { return nil }
        return days[dayNumber]
    }
    
    static func shortNameFor(_ day: Self) -> String? {
        shortNameFor(day.rawValue)
    }
    
    static func shortNamesFor(_ days: [Self]) -> String? {
        days.count == 7 ? "Каждый день" : days.compactMap { shortNameFor($0) }.joined(separator: ", ")
    }
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var fullDayName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}
