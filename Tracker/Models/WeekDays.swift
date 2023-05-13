import Foundation

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    // create set of ints 0..<7
    static let allDaysOfWeek = Set(WeekDay.allCases.map { $0.rawValue })
    
    static var count: Int {
        allDaysOfWeek.count
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

extension WeekDay: Comparable {
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Set<Int> {
    func weekdayStringShort() -> String {
        if self == WeekDay.allDaysOfWeek {
            return "Каждый день"
        } else {
            return WeekDay
                .allCases // take all cases  from Mon to Sun
                .filter { self.contains($0.rawValue) } // check if set has any of weekDays
                .map { $0.abbreviationShort } // map(transform) to string
                .joined(separator: ", ") // joing with coma
        }
    }
    
    func toNumbersString() -> String {
        return self
            .filter { 0..<7 ~= $0 } // take only numbers from 0 to 6
            .sorted() // sort Comparable
            .map { String($0) } // map(transform) to string
            .joined(separator: ", ") // joing with coma
    }

    static func fromString(_ str: String) -> Set<Int>? {
        let maxElement = 6
        let elements = str
            .components(separatedBy: ", ") // turn to array of string numbers
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { 0...maxElement ~= $0 } // filter to have only numbers from 0..<7
        
        return Set(elements) // turn to set
    }
}
