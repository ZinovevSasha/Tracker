import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]
    
    init(
        name: String,
        color: String,
        emoji: String,
        schedule: [WeekDay]
    ) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

func ff() {
    let traker = Tracker(name: "Fd", color: "Fds", emoji: "fdsf", schedule: [.monday,.friday])
    let filteredTrackers = traker.schedule.filter { $0.rawValue == 2 }
}

enum WeekDay: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var dayShorthand: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    var sortValue: Int {
        switch self {
        case .monday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        case .sunday:
            return 7
        }
    }
    
    var fullDayName: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
}

enum CollectionViewColors: String {
    case color0
    case color1
    case color2
    case color3
    case color4
    case color5
    case color6
    case color7
    case color8
    case color9
    case color10
    case color11
    case color12
    case color13
    case color14
    case color15
    case color16
    case color17
}
