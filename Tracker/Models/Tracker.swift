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
    
    var date: String?
    var schedule: String?
}
