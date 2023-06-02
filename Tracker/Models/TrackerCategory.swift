struct TrackerCategory {
    let header: String
    let trackers: [Tracker]
    let isLastSelected: Bool
}

extension TrackerCategory {
    init(coreData: TrackerCategoryCoreData) {
        self.header = coreData.header ?? ""
        self.isLastSelected = coreData.isLastSelected
        
        let trackerCoreDatas = coreData.trackers?.allObjects as? [TrackerCoreData] ?? []
        self.trackers = trackerCoreDatas.map { Tracker(coreData: $0) }
    }
}
