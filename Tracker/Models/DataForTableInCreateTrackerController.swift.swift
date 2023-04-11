//
//  File.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.04.2023.
//

import Foundation

struct DataForTableInCreateTrackerController {
    private var category = RowData(title: "Category", subtitle: "")
    private var schedule = RowData(title: "Schedule", subtitle: "")
    
    var oneRow: [RowData] {
        [category]
    }
    
    var twoRows: [RowData] {
        [category, schedule]
    }
    
    mutating func addCategory(subtitle: String) {
        category.subtitle = subtitle
    }
    
    mutating func addSchedule(subtitle: String) {
        schedule.subtitle = subtitle
    }
}

struct RowData {
    let title: String
    var subtitle: String
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}




