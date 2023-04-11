//
//  DataForCreateTrackerController.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.04.2023.
//

import Foundation

enum CollectionViewData {
    case firstSection(items: [String])
    case secondSection(items: [CollectionViewColors])
    
    var title: String {
        switch self {
        case .firstSection:
            return "Emojis"
        case .secondSection:
            return "Цвет"
        }
    }
}

struct DataForCollectionInCreateTrackerController {
    let dataSource: [CollectionViewData] = [
        .firstSection(items:  [
            "🙂", "😻", "🌺", "🐶", "❤️",
            "😱", "😇","😡", "🥶", "🤔",
            "🙌", "🍔", "🥦", "🏓", "🥇",
            "🎸", "🏝️", "😪"
        ]),
        .secondSection(items: CollectionViewColors.array)
    ]
}

enum CollectionViewColors: String, CaseIterable {
    static var array: [CollectionViewColors] {
        return CollectionViewColors.allCases
    }
    
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
