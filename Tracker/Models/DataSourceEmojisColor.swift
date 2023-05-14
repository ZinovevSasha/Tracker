import Foundation

enum CollectionViewData {
    case emojiSection(items: [String])
    case colorSection(items: [CollectionViewColors])
    
    var title: String {
        switch self {
        case .emojiSection:
            return Localized.NewHabit.emoji
        case .colorSection:
            return Localized.NewHabit.color
        }
    }
}

struct EmojisAndColorData {
    let dataSource: [CollectionViewData] = [
        .emojiSection(items: [
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
    
    case color0 = "#FD4C49"
    case color1 = "#FF881E"
    case color2 = "#007BFA"
    case color3 = "#6E44FE"
    case color4 = "#33CF69"
    case color5 = "#E66DD4"
    case color6 = "#F9D4D4"
    case color7 = "#34A7FE"
    case color8 = "#46E69D"
    case color9 = "#35347C"
    case color10 = "#FF674D"
    case color11 = "#FF99CC"
    case color12 = "#F6C48B"
    case color13 = "#7994F5"
    case color14 = "#832CF1"
    case color15 = "#AD56DA"
    case color16 = "#8D72E6"
    case color17 = "#2FD058"
}
