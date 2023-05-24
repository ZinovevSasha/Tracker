import Foundation

struct Tracker {
    let id: String
    let name: String
    let emoji: String
    let color: String
    let schedule: String
    let isAttached: Bool
    let type: UserTracker.TrackerType
    
    init(id: String, name: String, emoji: String, color: String, schedule: String, isAttached: Bool = false, type: UserTracker.TrackerType) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.isAttached = isAttached
        self.type = type
    }
}
