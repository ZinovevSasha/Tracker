//
//  TrackerMaker.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2023.
//

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
        tableData: [RowData],
        collectionData: [CollectionViewData]
    ) {
        guard
            let name = data.selectedName,
            let emojiIndexPath = data.selectedEmoji,
            let colorIndexPath = data.selectedColor
        else {
            return
        }
        
        let emojiSections = collectionData[emojiIndexPath.section]
        var emoji = ""
        switch emojiSections {
        case .firstSection(items: let items):
            emoji = items[emojiIndexPath.row]
        default:
            break
        }
        
        let colorSections = collectionData[colorIndexPath.section]
        var color = ""
        switch colorSections {
        case .secondSection(items: let items):
            color = items[colorIndexPath.row].rawValue
        default:
            break
        }
        
        
        category = TrackerCategory(
            header: "Здоровье",
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
