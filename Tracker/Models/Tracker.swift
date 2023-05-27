import Foundation

struct Tracker {
    enum Kind: String {
        case habit
        case ocasional
    }

    let id: String
    let name: String
    let emoji: String
    let color: String
    let schedule: Set<Int>
    let isAttached: Bool
    let kind: Kind
    
    init(id: String = UUID().uuidString, name: String, emoji: String, color: String, schedule: Set<Int>, isAttached: Bool = false, kind: Kind) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.isAttached = isAttached
        self.kind = kind
    }
}
