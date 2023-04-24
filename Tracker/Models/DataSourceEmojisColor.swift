import Foundation

enum CollectionViewData {
    case emojiSection(items: [String])
    case colorSection(items: [CollectionViewColors])
    
    var title: String {
        switch self {
        case .emojiSection:
            return "Emojis"
        case .colorSection:
            return "Цвет"
        }
    }
}

struct DataSourceEmojisColor {
    let dataSource: [CollectionViewData] = [
        .emojiSection(items:  [
            "🙂", "😻", "🌺", "🐶", "❤️",
            "😱", "😇","😡", "🥶", "🤔",
            "🙌", "🍔", "🥦", "🏓", "🥇",
            "🎸", "🏝️", "😪"
        ]),
        .colorSection(items: CollectionViewColors.array)
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
