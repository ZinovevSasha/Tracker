import Foundation

struct TrackerMaker {
    func createHabitTracker(_ userMadeTracker: UserTracker) -> Tracker? {
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
        return Tracker(
            id: UUID().uuidString,
            name: name,
            emoji: emoji,
            color: color,
            schedule: schedule,
            type: .habit
        )
    }
    
    func createOcasionalTracker(_ userMadeTracker: UserTracker) -> Tracker? {
        // Check if required fields exist and unwrap them
        guard
            let name = userMadeTracker.name,
            let emoji = userMadeTracker.emoji,
            let color = userMadeTracker.color
        else {
            return nil
        }
        
        // Create tracker
        return Tracker(
            id: UUID().uuidString,
            name: name,
            emoji: emoji,
            color: color,
            schedule: WeekDay.allDaysOfWeek.toNumbersString(),
            type: .ocasional
        )
    }
}
