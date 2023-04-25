import Foundation

enum TrackerType {
    case habit
    case occasional
}

protocol TrackerProtocol {
    // Define common behavior for all types of trackers
    var id: String { get }
    var name: String { get }
    var color: String { get }
    var emoji: String { get }
    var date: String? { get }
    var schedule: String? { get }
}

struct Tracker: TrackerProtocol {
    let id: String
    let name: String
    let color: String
    let emoji: String
    
    var date: String?
    var schedule: String?
    var type: TrackerType?
}
