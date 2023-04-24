import Foundation

struct TrackerMaker {
    func createTrackerFrom(userInput user: User, tableData: [RowData], collectionData: [CollectionViewData]) -> TrackerCategory? {
        guard let categoryName = user.selectedCategory,
              let name = user.selectedName,
              let emojiIndexPath = user.selectedEmoji,
              let colorIndexPath = user.selectedColor,
              case let .emojiSection(emojiItems) = collectionData[emojiIndexPath.section],
              case let .colorSection(colorItems) = collectionData[colorIndexPath.section]
        else {
            return nil
        }
        
        let emoji = emojiItems[emojiIndexPath.row]
        let color = colorItems[colorIndexPath.row].rawValue
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: user.selectedWeekDay
        )
        
        return TrackerCategory(header: categoryName, trackers: [tracker])
    }
}
