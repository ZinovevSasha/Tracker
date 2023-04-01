//
//  NewHabitCellModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.03.2023.
//

import UIKit

struct CreateTrackerModel {
    let title: String
    var colors: String?
    var emoji: String?
}

enum CreateTrackerSections {
    case sales([CreateTrackerModel])
    case category([CreateTrackerModel])
    case category2([CreateTrackerModel])
    case emoji([CreateTrackerModel])
    case colors([CreateTrackerModel])
    
    var items: [CreateTrackerModel] {
        switch self {
        case
        .sales(let items),
        .category(let items),
        .category2(let items),
        .emoji(let items),
        .colors(let items):
        return items
        }
    }
    
    var count: Int {
        items.count
    }
    
    var title: String {
        switch self {
        case .sales:
            return ""
        case .category:
            return ""
        case .category2:
            return ""
        case .emoji:
            return "Emoji"
        case .colors:
            return "Colors"
        }
    }
}

enum CollectionViewColors: String {
    case color0
    case color1
    case color2
    case color3
    case color4
    case color5
    case color6
    case color7
    case color8
    case color9
    case color10
    case color11
    case color12
    case color13
    case color14
    case color15
    case color16
    case color17
}

struct TrackerCreationData {
    let sections: [CreateTrackerSections] = [
        .sales([
            .init(title: "Введите название категории")
        ]),
        .category([
            .init(title: "Категория")
        ]),
        .category2([
            .init(title: "Расписание")
        ]),
        .emoji([
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂"),
            .init(title: "🙂")
        ]),
        .colors([
            .init(title: "", colors: CollectionViewColors.color0.rawValue),
            .init(title: "", colors: CollectionViewColors.color1.rawValue),
            .init(title: "", colors: CollectionViewColors.color2.rawValue),
            .init(title: "", colors: CollectionViewColors.color3.rawValue),
            .init(title: "", colors: CollectionViewColors.color4.rawValue),
            .init(title: "", colors: CollectionViewColors.color5.rawValue),
            .init(title: "", colors: CollectionViewColors.color6.rawValue),
            .init(title: "", colors: CollectionViewColors.color7.rawValue),
            .init(title: "", colors: CollectionViewColors.color8.rawValue),
            .init(title: "", colors: CollectionViewColors.color9.rawValue),
            .init(title: "", colors: CollectionViewColors.color10.rawValue),
            .init(title: "", colors: CollectionViewColors.color11.rawValue),
            .init(title: "", colors: CollectionViewColors.color12.rawValue),
            .init(title: "", colors: CollectionViewColors.color13.rawValue),
            .init(title: "", colors: CollectionViewColors.color14.rawValue),
            .init(title: "", colors: CollectionViewColors.color15.rawValue),
            .init(title: "", colors: CollectionViewColors.color16.rawValue),
            .init(title: "", colors: CollectionViewColors.color17.rawValue)
        ])
    ]
}
