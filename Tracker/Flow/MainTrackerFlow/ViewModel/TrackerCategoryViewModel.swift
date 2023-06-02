import Combine

struct TrackerCategoryViewModel {
    let header: String
    let isLastSelected: Bool
    let trackers: [TrackerCellViewModel]
    
    static func from(_ category: TrackerCategory) -> TrackerCategoryViewModel {
        return TrackerCategoryViewModel(
            header: category.header,
            isLastSelected: category.isLastSelected,
            trackers: category.trackers.map { TrackerCellViewModel(tracker: $0) }
        )
    }
}

final class TrackerCellViewModel {
    // MARK: - Public
    @Published var trackedDaysViewModel = TrackedDaysViewModel()
            
    // MARK: - Dependencies
    private let tracker: Tracker
        
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    var id: String {
        tracker.id
    }
    
    var name: String {
        tracker.name
    }
    
    var color: String {
        tracker.color
    }
    
    var emoji: String {
        tracker.emoji
    }
    
    var isPinned: Bool {
        tracker.isPinned
    }
}
