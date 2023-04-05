//
//  Model.swift
//  Tracker
//
//  Created by Александр Зиновьев on 05.04.2023.
//

import Foundation

struct TrackerCreationHelper {
    var header: String?
    var trackerName: String?
    var trackerSchedule: [WeekDay] = []
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorsIndexPath: IndexPath?
    
    var isAllPropertiesFilled: Bool {
        if trackerName != nil,            
            selectedEmojiIndexPath != nil,
            selectedColorsIndexPath != nil {
            return true
        } else {
            return false
        }
    }
}
