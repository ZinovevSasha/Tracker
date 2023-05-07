import Foundation

struct TrackerMaker {
    func createTrackerFrom(
        _ userMadeTracker: UserTracker,
        withDate date: String?
    ) -> Tracker? {
        // Check if required fields exist and unwrap them
        guard
            let name = userMadeTracker.name,
            let emoji = userMadeTracker.emoji,
            let color = userMadeTracker.color
        else {
            return nil
        }

        let schedule = userMadeTracker.weekDay?.toNumbersString()
        
        // Create tracker
        return Tracker(id: UUID().uuidString, name: name, emoji: emoji, color: color, date: date, schedule: schedule)
    }
}
