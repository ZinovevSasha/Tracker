import Foundation

struct TrackerCategory: Hashable {
    let id: String
    let header: String
    let trackers: [Tracker]
    let isLastSelected: Bool
    
    init(id: String = UUID().uuidString, header: String, trackers: [Tracker], isLastSelected: Bool) {
        self.id = id
        self.header = header
        self.trackers = trackers
        self.isLastSelected = isLastSelected
    }
}

extension TrackerCategory {
    init(coreData: TrackerCategoryCD) {
        self.id = coreData.identifier ?? ""
        self.header = coreData.header ?? ""
        self.isLastSelected = coreData.isLastSelected
        
        let trackerCoreDatas = coreData.trackers?.allObjects as? [TrackerCD] ?? []
        self.trackers = trackerCoreDatas.map { Tracker(coreData: $0) }
    }
}
