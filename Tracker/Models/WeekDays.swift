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
        case .monday: return Localized.NewHabit.monday
        case .tuesday: return Localized.NewHabit.tuesday
        case .wednesday: return Localized.NewHabit.wednesday
        case .thursday: return Localized.NewHabit.thursday
        case .friday: return Localized.NewHabit.friday
        case .saturday: return Localized.NewHabit.saturday
        case .sunday: return Localized.NewHabit.sunday
        }
    }
    
    var abbreviationShort: String {
        switch self {
        case .sunday: return Localized.NewHabit.sun
        case .monday: return Localized.NewHabit.mon
        case .tuesday: return Localized.NewHabit.tue
        case .wednesday: return Localized.NewHabit.wed
        case .thursday: return Localized.NewHabit.thu
        case .friday: return Localized.NewHabit.sat
        case .saturday: return Localized.NewHabit.sun
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
            return Localized.NewHabit.everyday
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
