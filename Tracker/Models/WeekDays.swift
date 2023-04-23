import Foundation

extension WeekDay: Comparable {
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
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

extension Set where Element == Int {
    func weekdayStringShort() -> String {
        if self == WeekDay.allDaysOfWeek {
            return "Каждый день"
        } else if self.isEmpty {
            return "Нет выбранного расписания"
        } else {
            let weekdayAbbreviations = WeekDay.allCases
                .filter { self.contains($0.rawValue) }
                .map { $0.abbreviationShort }
            return weekdayAbbreviations.joined(separator: ", ")
        }
    }

    func toNumbersString() -> String {
        let maxElement = 6
        let elements = Array(self.filter { 0...maxElement ~= $0 }.sorted())
        return elements.map { String($0) }.joined(separator: ", ")
    }
    
    static func fromString(_ str: String) -> Set<Int>? {
        let maxElement = 6
        let elements = str.components(separatedBy: ", ")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { 0...maxElement ~= $0 }
        return Set(elements)
    }
}
