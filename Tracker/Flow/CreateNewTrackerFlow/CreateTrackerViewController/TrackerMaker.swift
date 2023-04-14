import Foundation

final class TrackerMaker {
    private(set) var category: TrackerCategory?
    
    func createTrackerFrom(
        userInputData data: User,
        categories: [TrackerCategory],
        tableData: [RowData],
        collectionData: [CollectionViewData]
    ) -> TrackerCategory? {
        guard
            let categoryName = data.selectedCategory,
            let name = data.selectedName,
            let emojiIndexPath = data.selectedEmoji,
            let colorIndexPath = data.selectedColor
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
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: data.selectedWeekDay
                )
            ]
        )
    }
}
