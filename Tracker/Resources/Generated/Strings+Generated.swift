// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Strings {
  public enum InfoPlist {
    /// Tracker
    public static let cfBundleDisplayName = Strings.tr("InfoPlist", "CFBundleDisplayName", fallback: "Tracker")
  }
  public enum Localizable {
    /// Plural format key: "%#@days@"
    public static func daysNumber(_ p1: Int) -> String {
      return Strings.tr("Localizable", "daysNumber", p1, fallback: "Plural format key: \"%#@days@\"")
    }
    /// Schedule
    public static let schedule = Strings.tr("Localizable", "schedule", fallback: "Schedule")
    public enum Alert {
      /// Cancel
      public static let cancel = Strings.tr("Localizable", "alert.cancel", fallback: "Cancel")
      /// Is this category no longer needed?
      public static let confirmationCategory = Strings.tr("Localizable", "alert.confirmationCategory", fallback: "Is this category no longer needed?")
      /// Are you sure you want to delete the tracker?
      public static let confirmationTracker = Strings.tr("Localizable", "alert.confirmationTracker", fallback: "Are you sure you want to delete the tracker?")
      /// Delete
      public static let delete = Strings.tr("Localizable", "alert.delete", fallback: "Delete")
    }
    public enum Category {
      /// Add category
      public static let addNew = Strings.tr("Localizable", "category.addNew", fallback: "Add category")
      /// Category
      public static let category = Strings.tr("Localizable", "category.category", fallback: "Category")
    }
    public enum Choosing {
      /// Creating a Tracker
      public static let tracker = Strings.tr("Localizable", "choosing.tracker", fallback: "Creating a Tracker")
      /// Habit
      public static let trackerType1 = Strings.tr("Localizable", "choosing.trackerType1", fallback: "Habit")
      /// Irregular event
      public static let trackerType2 = Strings.tr("Localizable", "choosing.trackerType2", fallback: "Irregular event")
    }
    public enum Context {
      /// Delete
      public static let delete = Strings.tr("Localizable", "context.delete", fallback: "Delete")
      /// Pin
      public static let pin = Strings.tr("Localizable", "context.pin", fallback: "Pin")
      /// Unpin
      public static let unpin = Strings.tr("Localizable", "context.unpin", fallback: "Unpin")
      /// Edit
      public static let update = Strings.tr("Localizable", "context.update", fallback: "Edit")
    }
    public enum Create {
      /// Cancel
      public static let cancel = Strings.tr("Localizable", "create.cancel", fallback: "Cancel")
      /// Category
      public static let category = Strings.tr("Localizable", "create.category", fallback: "Category")
      /// Color
      public static let color = Strings.tr("Localizable", "create.color", fallback: "Color")
      /// Create
      public static let createNew = Strings.tr("Localizable", "create.createNew", fallback: "Create")
      /// Emojis
      public static let emoji = Strings.tr("Localizable", "create.emoji", fallback: "Emojis")
      /// Enter the name of the tracker
      public static let enterName = Strings.tr("Localizable", "create.enterName", fallback: "Enter the name of the tracker")
      /// New habit
      public static let newHabit = Strings.tr("Localizable", "create.newHabit", fallback: "New habit")
      /// 38 character limit
      public static let restriction = Strings.tr("Localizable", "create.restriction", fallback: "38 character limit")
      /// Schedule
      public static let schedule = Strings.tr("Localizable", "create.schedule", fallback: "Schedule")
    }
    public enum Filters {
      /// All trackers
      public static let all = Strings.tr("Localizable", "filters.all", fallback: "All trackers")
      /// Completed
      public static let completed = Strings.tr("Localizable", "filters.completed", fallback: "Completed")
      /// Uncompleted
      public static let notCompleted = Strings.tr("Localizable", "filters.notCompleted", fallback: "Uncompleted")
      /// Filters
      public static let title = Strings.tr("Localizable", "filters.title", fallback: "Filters")
      /// Today trackers
      public static let today = Strings.tr("Localizable", "filters.today", fallback: "Today trackers")
    }
    public enum Main {
      /// Pinned
      public static let pinned = Strings.tr("Localizable", "main.pinned", fallback: "Pinned")
      /// Search
      public static let search = Strings.tr("Localizable", "main.search", fallback: "Search")
      /// Trackers
      public static let trackers = Strings.tr("Localizable", "main.trackers", fallback: "Trackers")
    }
    public enum NewCategory {
      /// This category already exists ☹️
      public static let alreadyExist = Strings.tr("Localizable", "newCategory.alreadyExist", fallback: "This category already exists ☹️")
      /// Enter category name
      public static let enterName = Strings.tr("Localizable", "newCategory.enterName", fallback: "Enter category name")
      /// New category
      public static let new = Strings.tr("Localizable", "newCategory.new", fallback: "New category")
      /// Ready
      public static let ready = Strings.tr("Localizable", "newCategory.ready", fallback: "Ready")
    }
    public enum Onboarding {
      /// That's technology!
      public static let enter = Strings.tr("Localizable", "onboarding.enter", fallback: "That's technology!")
      /// Track only what you want
      public static let greeting1 = Strings.tr("Localizable", "onboarding.greeting1", fallback: "Track only what you want")
      /// Even if it's not liters of water and yoga
      public static let greeting2 = Strings.tr("Localizable", "onboarding.greeting2", fallback: "Even if it's not liters of water and yoga")
    }
    public enum Placeholder {
      /// Nothing found
      public static let noResults = Strings.tr("Localizable", "placeholder.noResults", fallback: "Nothing found")
      /// There is nothing to analyze yet
      public static let noStatistic = Strings.tr("Localizable", "placeholder.noStatistic", fallback: "There is nothing to analyze yet")
      /// What are we going to track?
      public static let question = Strings.tr("Localizable", "placeholder.question", fallback: "What are we going to track?")
      /// Habits and events
      ///  can be combined in meaning
      public static let recomendation = Strings.tr("Localizable", "placeholder.recomendation", fallback: "Habits and events\n can be combined in meaning")
    }
    public enum Schedule {
      /// Every day
      public static let everyday = Strings.tr("Localizable", "schedule.everyday", fallback: "Every day")
      /// Fri
      public static let fri = Strings.tr("Localizable", "schedule.fri", fallback: "Fri")
      /// Friday
      public static let friday = Strings.tr("Localizable", "schedule.friday", fallback: "Friday")
      /// Mon
      public static let mon = Strings.tr("Localizable", "schedule.mon", fallback: "Mon")
      /// Monday
      public static let monday = Strings.tr("Localizable", "schedule.monday", fallback: "Monday")
      /// Ready
      public static let ready = Strings.tr("Localizable", "schedule.ready", fallback: "Ready")
      /// Sat
      public static let sat = Strings.tr("Localizable", "schedule.sat", fallback: "Sat")
      /// Saturday
      public static let saturday = Strings.tr("Localizable", "schedule.saturday", fallback: "Saturday")
      /// Sun
      public static let sun = Strings.tr("Localizable", "schedule.sun", fallback: "Sun")
      /// Sunday
      public static let sunday = Strings.tr("Localizable", "schedule.sunday", fallback: "Sunday")
      /// Thu
      public static let thu = Strings.tr("Localizable", "schedule.thu", fallback: "Thu")
      /// Thursday
      public static let thursday = Strings.tr("Localizable", "schedule.thursday", fallback: "Thursday")
      /// Tue
      public static let tue = Strings.tr("Localizable", "schedule.tue", fallback: "Tue")
      /// Tuesday
      public static let tuesday = Strings.tr("Localizable", "schedule.tuesday", fallback: "Tuesday")
      /// Wed
      public static let wed = Strings.tr("Localizable", "schedule.wed", fallback: "Wed")
      /// Wednesday
      public static let wednesday = Strings.tr("Localizable", "schedule.wednesday", fallback: "Wednesday")
    }
    public enum TabBar {
      /// Statistics
      public static let statistics = Strings.tr("Localizable", "tabBar.statistics", fallback: "Statistics")
      /// Trackers
      public static let trackers = Strings.tr("Localizable", "tabBar.trackers", fallback: "Trackers")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
