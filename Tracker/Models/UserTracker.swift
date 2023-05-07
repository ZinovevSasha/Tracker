import Foundation

struct SelectedFields: OptionSet {
    let rawValue: Int
    
    static let categoryName = SelectedFields(rawValue: 1 << 0)
    static let name = SelectedFields(rawValue: 1 << 1)
    static let emoji = SelectedFields(rawValue: 1 << 2)
    static let color = SelectedFields(rawValue: 1 << 3)
    static let weekDay = SelectedFields(rawValue: 1 << 4)
    static let date = SelectedFields(rawValue: 1 << 5)
}

struct UserTracker {
    enum TrackerType {
        case habit
        case ocasional
    }    
    
    
    private let trackerBuilder: TrackerMaker
    
    init(trackerBuilder: TrackerMaker) {
        self.trackerBuilder = trackerBuilder
    }

    var name: String? {
        didSet {
            if let name {
                selectedFields.insert(.name)
            } else {
                selectedFields.remove(.name)
            }
        }
    }

    var weekDay: Set<Int>? {
        didSet {
            if let weekDay {
                selectedFields.insert(.weekDay)
            } else {
                selectedFields.remove(.weekDay)
            }
        }
    }

    var emoji: String? {
        didSet {
            if let emoji {
                selectedFields.insert(.emoji)
            } else {
                selectedFields.remove(.emoji)
            }
        }
    }

    var color: String? {
        didSet {
            if let color {
                selectedFields.insert(.color)
            } else {
                selectedFields.remove(.color)
            }
        }
    }
    var selectedFields = SelectedFields()
}

extension UserTracker {
    var isEnoughForHabit: Bool {
        return selectedFields.contains(.categoryName)
            && selectedFields.contains(.name)
            && selectedFields.contains(.weekDay)
            && selectedFields.contains(.emoji)
            && selectedFields.contains(.color)
    }
    
    var isEnoughForOcasion: Bool {
        return selectedFields.contains(.categoryName)
            && selectedFields.contains(.name)
            && selectedFields.contains(.emoji)
            && selectedFields.contains(.color)
    }
}

extension UserTracker {
    func buildTracker() -> Tracker? {
        trackerBuilder.createTrackerFrom(self, withDate: "fdsf")
    }
}
