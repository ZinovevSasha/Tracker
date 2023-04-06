//
//  TrackerMaker.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2023.
//

import Foundation

final class TrackerMaker {
    static let myNotificationName = Notification.Name("TrackerMade")
    
    private(set) var category: TrackerCategory?
    
    private func postNotification() {
        NotificationCenter.default
            .post(
                name: TrackerMaker.myNotificationName,
                object: self,
                userInfo: ["c": category]
            )
    }
    
    func createTrackerWith(
        values: TrackerCreationHelper,
        sections: [CreateTrackerCollectionViewSections]
    ) {
        guard
            let name = values.trackerName,
            let indexPathEmoji = values.selectedEmojiIndexPath,
            let indexPathColor = values.selectedColorsIndexPath
        else {
            return
        }
        
        let color = sections[indexPathColor.section].items[indexPathColor.row].title
        let emoji = sections[indexPathEmoji.section].items[indexPathEmoji.row].title
        
        category = TrackerCategory(
            header: "Здоровье",
            trackers: [
                Tracker(
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: values.trackerSchedule
                )
            ]
        )
        postNotification()
    }
}