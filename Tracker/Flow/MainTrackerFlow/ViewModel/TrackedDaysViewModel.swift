import Combine

final class TrackedDaysViewModel {
    @Published var trackedDays: Int
    @Published var isTrackedForToday: Bool
    
    init(trackedDays: Int = 0, isTrackedForToday: Bool = false) {
        self.trackedDays = trackedDays
        self.isTrackedForToday = isTrackedForToday
    }
}

extension TrackedDaysViewModel: Hashable {
    static func == (lhs: TrackedDaysViewModel, rhs: TrackedDaysViewModel) -> Bool {
        return lhs.trackedDays == rhs.trackedDays && lhs.isTrackedForToday == rhs.isTrackedForToday
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackedDays)
        hasher.combine(isTrackedForToday)
    }
}
