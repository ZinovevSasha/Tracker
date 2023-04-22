import Foundation

final class TrackerMaker {
    private(set) var category: TrackerCategory?
    
    func createTrackerFrom(
        userInput user: User,       
        tableData: [RowData],
        collectionData: [CollectionViewData]
    ) -> TrackerCategory? {
        guard
            let categoryName = user.selectedCategory,
            let name = user.selectedName,
            let emojiIndexPath = user.selectedEmoji,
            let colorIndexPath = user.selectedColor
        else {
            return nil
        }
        
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
        
        return TrackerCategory(
            header: categoryName,
            trackers: [
                Tracker(
                    id: UUID(),
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: user.selectedWeekDay
                )
            ]
        )
    }
}
