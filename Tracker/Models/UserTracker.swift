import Foundation

struct SelectedFields: OptionSet {
    let rawValue: Int
       
    static let name = SelectedFields(rawValue: 1 << 1)
    static let emoji = SelectedFields(rawValue: 1 << 2)
    static let color = SelectedFields(rawValue: 1 << 3)
    static let weekDay = SelectedFields(rawValue: 1 << 4)
    static let date = SelectedFields(rawValue: 1 << 5)
    static let categoryName = SelectedFields(rawValue: 1 << 6)
}

struct UserTracker {
    enum TrackerType: String {
        case habit
        case ocasional        
    }

    private let trackerBuilder: TrackerMaker
    private var selectedFields = SelectedFields()
    
    init(trackerBuilder: TrackerMaker = TrackerMaker()) {
        self.trackerBuilder = trackerBuilder
    }

    var name: String? {
        didSet {
            if name != nil {
                selectedFields.insert(.name)
            } else {
                selectedFields.remove(.name)
            }
        }
    }

    var weekDay: Set<Int>? {
        didSet {
            if weekDay != nil {
                selectedFields.insert(.weekDay)
            } else {
                selectedFields.remove(.weekDay)
            }
        }
    }

    var emoji: String? {
        didSet {
            if emoji != nil {
                selectedFields.insert(.emoji)
            } else {
                selectedFields.remove(.emoji)
            }
        }
    }

    var color: String? {
        didSet {
            if color != nil {
                selectedFields.insert(.color)
            } else {
                selectedFields.remove(.color)
            }
        }
    }
    
    var categoryName: String? {
        didSet {
            if categoryName != nil {
                selectedFields.insert(.categoryName)
            } else {
                selectedFields.remove(.categoryName)
            }
        }
    }
}

extension UserTracker {
    var isEnoughForHabit: Bool {
        return selectedFields.contains(.name)
            && selectedFields.contains(.weekDay)
            && selectedFields.contains(.emoji)
            && selectedFields.contains(.color)
            && selectedFields.contains(.categoryName)
    }
    
    var isEnoughForOcasion: Bool {
        return selectedFields.contains(.name)
            && selectedFields.contains(.emoji)
            && selectedFields.contains(.color)
            && selectedFields.contains(.categoryName)
    }
}

extension UserTracker {
    func createHabitTracker() -> Tracker? {
        trackerBuilder.createHabitTracker(self)
    }
    
    func createOcasionalTracker() -> Tracker? {
        trackerBuilder.createOcasionalTracker(self)
    }
}
