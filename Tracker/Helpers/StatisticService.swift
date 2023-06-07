enum TrackerEvent {
    case mainOpen(Event, Screen)
    case mainClose(Event, Screen)
    case mainAddTrackClick(Event, Screen, Item)
    case mainTrackClick(Event, Screen, Item)
    case mainFilterClick(Event, Screen, Item)
    case mainEditClick(Event, Screen, Item)
    case mainDeleteClick(Event, Screen, Item)

    var stringValue: String {
        switch self {
        case let .mainOpen(event, screen):
            return "\(event.rawValue)_\(screen.rawValue)"
        case let .mainClose(event, screen):
            return "\(event.rawValue)_\(screen.rawValue)"
        case let .mainAddTrackClick(event, screen, item):
            return "\(event.rawValue)_\(screen.rawValue)_\(item.rawValue)"
        case let .mainTrackClick(event, screen, item):
            return "\(event.rawValue)_\(screen.rawValue)_\(item.rawValue)"
        case let .mainFilterClick(event, screen, item):
            return "\(event.rawValue)_\(screen.rawValue)_\(item.rawValue)"
        case let .mainEditClick(event, screen, item):
            return "\(event.rawValue)_\(screen.rawValue)_\(item.rawValue)"
        case let .mainDeleteClick(event, screen, item):
            return "\(event.rawValue)_\(screen.rawValue)_\(item.rawValue)"
        }
    }
}

enum Event: String {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum Screen: String {
    case main = "Main"
}

enum Item: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}
