import Foundation

struct TrackerMaker {
    func createHabitTracker(
        _ userMadeTracker: UserTracker
    ) -> Tracker? {
        // Check if required fields exist and unwrap them
        guard
            let name = userMadeTracker.name,
            let emoji = userMadeTracker.emoji,
            let color = userMadeTracker.color,
            let schedule = userMadeTracker.weekDay?.toNumbersString()
        else {
            return nil
        }

        // Create tracker
        return Tracker(id: UUID().uuidString, name: name, emoji: emoji, color: color, date: nil, schedule: schedule)
    }
    
    func createOcasionalTracker(
        _ userMadeTracker: UserTracker,
        withDate date: String?
    ) -> Tracker? {
        // Check if required fields exist and unwrap them
        guard
            let name = userMadeTracker.name,
            let emoji = userMadeTracker.emoji,
            let color = userMadeTracker.color,
            let date = date
        else {
            return nil
        }
        
        // Create tracker
        return Tracker(id: UUID().uuidString, name: name, emoji: emoji, color: color, date: date, schedule: nil)
    }
}
