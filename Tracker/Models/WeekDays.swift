import Foundation

extension WeekDay: Comparable {
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    static var array: [WeekDay] {
        WeekDay.allCases
    }
    
    static var count: Int {
        array.count
    }
    
    var abbreviationLong: String {
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
    
    var abbreviationShort: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }
}

extension Array where Element == WeekDay {
    // Function to check if an array contains all days of the week
    func containsAllDaysOfWeek() -> Bool {
        let allDays: Set<WeekDay> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        return allDays.allSatisfy { day in
            self.contains(day)
        }
    }
}

extension Set where Element == Int {
    func sortedWeekdays() -> [WeekDay] {
        let weekdays = WeekDay.allCases.filter { self.contains($0.rawValue) }
        return weekdays.sorted { $0.rawValue < $1.rawValue }
    }
    
    func weekdayStringShort() -> String {
        let weekdays = WeekDay.allCases.filter { self.contains($0.rawValue) }
        if weekdays.containsAllDaysOfWeek() {
            return "Каждый день"
        } else if weekdays.isEmpty {
            return ""
        } else {
            let weekdayAbbreviations = weekdays.map { $0.abbreviationShort }
            return weekdayAbbreviations.joined(separator: ", ")
        }
    }
}
