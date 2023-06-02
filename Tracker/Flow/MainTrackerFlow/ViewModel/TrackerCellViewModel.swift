//import Combine
//
//final class TrackerCellViewModel {    
//    // MARK: - Public
//    @Published var trackedDaysViewModel = TrackedDaysViewModel()
//            
//    // MARK: - Dependencies
//    private let tracker: Tracker
//        
//    init(tracker: Tracker) {
//        self.tracker = tracker
//    }
//    
//    var id: String {
//        tracker.id
//    }
//    
//    var name: String {
//        tracker.name
//    }
//    
//    var color: String {
//        tracker.color
//    }
//    
//    var emoji: String {
//        tracker.emoji
//    }
//    
//    var isPinned: Bool {
//        tracker.isPinned
//    }
//}
//
//extension TrackerCellViewModel: Hashable {
//    static func == (lhs: TrackerCellViewModel, rhs: TrackerCellViewModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
