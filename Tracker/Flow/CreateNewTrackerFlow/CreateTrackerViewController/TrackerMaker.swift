import Foundation

final class TrackerMaker {
    static let myNotificationName = Notification.Name("TrackerMaker")
    
    private(set) var category: TrackerCategory?
    
    private func postNotification() {
        NotificationCenter.default
            .post(
                name: TrackerMaker.myNotificationName,
                object: self,
                userInfo: ["c": category]
            )
    }
    
    func createTrackerFrom(
        userInputData data: User,
        categories: [TrackerCategory],
        tableData: [RowData],
        collectionData: [CollectionViewData]
    ) {
        guard
            let categoryName = data.selectedCategory,
            let name = data.selectedName,
            let emojiIndexPath = data.selectedEmoji,
            let colorIndexPath = data.selectedColor
        else {
            return
        }
        
        let header = categories[categoryName].header
        
        let emojiSections = collectionData[emojiIndexPath.section]
        var emoji = ""
        switch emojiSections {
        case .emojiSection(items: let items):
            emoji = items[emojiIndexPath.row]
        default:
            break
        }
        
        let colorSections = collectionData[colorIndexPath.section]
        var color = ""
        switch colorSections {
        case .colorSection(items: let items):
            color = items[colorIndexPath.row].rawValue
        default:
            break
        }
        
        
        category = TrackerCategory(
            header: header,
            trackers: [
                Tracker(
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: data.selectedWeekDay
                )
            ]
        )
        postNotification()
    }
}
