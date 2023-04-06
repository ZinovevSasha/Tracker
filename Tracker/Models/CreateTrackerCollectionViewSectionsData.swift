import Foundation

enum CreateTrackerCollectionViewSections {
    case trackerName([Text])
    case trackersCategory([Text])
    case trackerSchedule([Text])
    case trackerEmoji([Text])
    case trackerColor([Text])
        
    var items: [Text] {
        switch self {
        case
            .trackerName(let items),
            .trackersCategory(let items),
            .trackerSchedule(let items),
            .trackerEmoji(let items),
            .trackerColor(let items):
        return items
        }
    }

    var itemsCount: Int {
        items.count
    }
    
    var headerTitle: String {
        switch self {
        case .trackerName, .trackersCategory, .trackerSchedule:
            return ""
        case .trackerEmoji:
            return "Emoji"
        case .trackerColor:
            return "Colors"
        }
    }
}

struct Text {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
}

struct CreateTrackerCollectionViewSectionsData {
    let sections: [CreateTrackerCollectionViewSections] = [
        .trackerName([
            .init("Введите название категории")
        ]),
        .trackersCategory([
            .init("Категория")
        ]),
        .trackerSchedule([
            .init("Расписание")
        ]),
        .trackerEmoji([
            .init("🙂"),
            .init("😻"),
            .init("🌺"),
            .init("🐶"),
            .init("❤️"),
            .init("😱"),
            .init("👫"),
            .init("🥝"),
            .init("☎️"),
            .init("🪴"),
            .init("🪛"),
            .init("🔭"),
            .init("📙"),
            .init("📝"),
            .init("🖼️"),
            .init("🍏"),
            .init("🍇"),
            .init("🥦")
        ]),
        .trackerColor([
            .init(CollectionViewColors.color0.rawValue),
            .init(CollectionViewColors.color1.rawValue),
            .init(CollectionViewColors.color2.rawValue),
            .init(CollectionViewColors.color3.rawValue),
            .init(CollectionViewColors.color4.rawValue),
            .init(CollectionViewColors.color5.rawValue),
            .init(CollectionViewColors.color6.rawValue),
            .init(CollectionViewColors.color7.rawValue),
            .init(CollectionViewColors.color8.rawValue),
            .init(CollectionViewColors.color9.rawValue),
            .init(CollectionViewColors.color10.rawValue),
            .init(CollectionViewColors.color11.rawValue),
            .init(CollectionViewColors.color12.rawValue),
            .init(CollectionViewColors.color13.rawValue),
            .init(CollectionViewColors.color14.rawValue),
            .init(CollectionViewColors.color15.rawValue),
            .init(CollectionViewColors.color16.rawValue),
            .init(CollectionViewColors.color17.rawValue)
        ])
    ]
}
