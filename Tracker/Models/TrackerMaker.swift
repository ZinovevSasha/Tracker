import Foundation

struct TrackerMaker {
    func createTrackerFrom(
        userInput user: User,
        collectionData: [CollectionViewData],
        configuration: CreateTrackerViewController.Configuration,
        date: String
    ) -> TrackerCategory? {
        guard
            let categoryName = user.selectedCategory,
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
        
        switch configuration {
        case .oneRow:
            // Create occasional
            let occasional = Tracker(
                id: UUID().uuidString,
                name: name,
                color: color,
                emoji: emoji,
                date: date
            )
            return TrackerCategory(header: categoryName, trackers: [occasional])
        case .twoRows:
            // Create habit
            let habit = Tracker(
                id: UUID().uuidString,
                name: name,
                color: color,
                emoji: emoji,
                schedule: user.selectedWeekDay?.toNumbersString()
            )
            return (TrackerCategory(header: categoryName, trackers: [habit]))
        }
    }
}
