import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: Set<Int>
    
    var stringID: String {
        String(describing: id)
    }
    
    var stringSchedule: String {
        schedule.toNumbersString()
    }
}
