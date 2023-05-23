import Foundation

enum TrackerType {
    case habit
    case occasional
}

struct Tracker {
    let id: String
    let name: String
    let emoji: String
    let color: String
    let schedule: String
    let isAttached: Bool
    
    init(id: String, name: String, emoji: String, color: String, schedule: String, isAttached: Bool = false) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.isAttached = isAttached
    }
}
