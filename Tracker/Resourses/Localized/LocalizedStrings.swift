import Foundation

enum Localized {
    enum Onboarding {
        static let greeting1 = NSLocalizedString("onboarding.greeting1", comment: "")
        static let greeting2 = NSLocalizedString("onboarding.greeting2", comment: "")
        static let enter = NSLocalizedString("onboarding.enter", comment: "")
    }
    enum Main {
        static let search = NSLocalizedString("main.search", comment: "")
        static let trackers = NSLocalizedString("main.trackers", comment: "")
        static func numberOf(days: Int) -> String {
            String.localizedStringWithFormat(
                NSLocalizedString("daysNumber", comment: ""),
                days)
        }
    }
    enum Choosing {
        static let title = NSLocalizedString("choosing.tracker", comment: "")
        static let habit = NSLocalizedString("choosing.tracker.type1", comment: "")
        static let irregular = NSLocalizedString("choosing.tracker.type2", comment: "")
    }
    enum Placeholder {
        static let question = NSLocalizedString("placeholder.question", comment: "")
        static let noResults = NSLocalizedString("placeholder.noResults", comment: "")
        static let noStatistic = NSLocalizedString("placeholder.noStatistic", comment: "")
        static let recomendation = NSLocalizedString("placeholder.recomendation", comment: "")
    }
    enum TabBar {
        static let trackers = NSLocalizedString("tabBar.trackers", comment: "")
        static let statistics = NSLocalizedString("tabBar.statistics", comment: "")
    }
    enum NewHabit {
        static let newHabit = NSLocalizedString("create.new.habit", comment: "")
        static let enterName = NSLocalizedString("create.enter.name", comment: "")
        static let restriction = NSLocalizedString("create.restriction", comment: "")
        static let cancel = NSLocalizedString("create.cancel", comment: "")
        static let create = NSLocalizedString("create.create.new", comment: "")
        static let color = NSLocalizedString("create.color", comment: "")
        static let emoji = NSLocalizedString("create.emoji", comment: "")
        static let category = NSLocalizedString("create.category", comment: "")
        static let schedule = NSLocalizedString("create.schedule", comment: "")
        
        static let monday = NSLocalizedString("scheule.monday", comment: "")
        static let tuesday = NSLocalizedString("scheule.tuesday", comment: "")
        static let wednesday = NSLocalizedString("scheule.wednesday", comment: "")
        static let thursday = NSLocalizedString("scheule.thursday", comment: "")
        static let friday = NSLocalizedString("scheule.friday", comment: "")
        static let saturday = NSLocalizedString("scheule.saturday", comment: "")
        static let sunday = NSLocalizedString("scheule.sunday", comment: "")
        static let mon = NSLocalizedString("scheule.mon", comment: "")
        static let tue = NSLocalizedString("scheule.tue", comment: "")
        static let wed = NSLocalizedString("scheule.wed", comment: "")
        static let thu = NSLocalizedString("scheule.thu", comment: "")
        static let fri = NSLocalizedString("scheule.fri", comment: "")
        static let sat = NSLocalizedString("scheule.sat", comment: "")
        static let sun = NSLocalizedString("scheule.sun", comment: "")
        static let everyday = NSLocalizedString("scheule.everyday", comment: "")
    }
    
    enum CategoryList {
        static let category = NSLocalizedString("category.category", comment: "")
        static let newCategory = NSLocalizedString("category.add.new", comment: "")
    }
    
    enum NewCategory {
        static let enterName = NSLocalizedString("newCategory.enter.name", comment: "")
        static let existAlready = NSLocalizedString("newCategory.already.exist", comment: "")
        static let new = NSLocalizedString("newCategory.new", comment: "")
        static let ready = NSLocalizedString("newCategory.ready", comment: "")
    }
    enum Schedule {
        static let schedule = NSLocalizedString("schedule", comment: "")
        static let ready = NSLocalizedString("schedule.ready", comment: "")
    }
}
