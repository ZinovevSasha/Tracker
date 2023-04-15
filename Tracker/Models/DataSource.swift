//
//  DataSource.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.04.2023.
//

import Foundation

protocol DataSourceDelegate: AnyObject {
    func mainCategoriesIsEmpty()
    func mainCategoriesIsNotEmpty()
    func visibleCategoriesChanged()
    func visibleCategoriesInSearchEmpty()
    func visibleCategoriesInSearchIsNotEmpty()
    func visibleCategoriesInCalendarEmpty()
    func visibleCategoriesInCalendarIsNotEmpty()
}

protocol DataSourceProtocol {
    var categoriesCount: Int { get }
    func getCategories() -> [TrackerCategory]
    func isTitleAvailable(title: String)
    func addCategory(_ category: TrackerCategory)
    func getNumberOfTrackersForOneCategory(_ section: Int) -> Int
    func getTracker(for indexPath: IndexPath) -> Tracker
    func getHeaderOfCategory(_ indexPath: IndexPath) -> String
    func showTrackerWithName(name: String)
    func showTrackerForDayOfWeek(_ selectedDay: Date)
}

final class DataSource {
    weak var delegate: DataSourceDelegate?
    
    var categories: [TrackerCategory] = [] {
        didSet {
            visibleCategories = categories
        }
    }
    
    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            delegate?.visibleCategoriesChanged()
        }
    }
    var completedTrackers: [TrackerRecord] = []
    var completedTrackersId: Set<UUID> = []
    
    // Private properties
    private var indexPath: [IndexPath]?
}

extension DataSource {
    // Working with main storage
    func isTitleAvailable(title: String) -> Bool {
        !categories.contains { $0.header == title }
    }
    
    func addCategory(_ category: TrackerCategory) {
        let header = category.header
        let trackers = category.trackers
        if let tracker = trackers[safe: .zero] {
            delegate?.mainCategoriesIsNotEmpty()
            addTracker(tracker, toCategoryWithHeader: header)
        } else {
            print("Error adding Tracker")
        }
    }
    
    func getCategories() -> [TrackerCategory] {
        categories
    }
    
    // Working with Visible trackers
    var categoriesCount: Int {
        visibleCategories.count
    }
    
    func getNumberOfTrackersForOneCategory(_ section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func getTracker(for indexPath: IndexPath) -> Tracker {
        visibleCategories[indexPath.section].trackers[indexPath.row]
    }
    
    func getHeaderOfCategory(_ indexPath: IndexPath) -> String {
        visibleCategories[indexPath.section].header
    }
    
    var isTrackersPresent: Bool {
        visibleCategories.isEmpty
    }
        
    func showTrackersForWeekDay(_ selectedWeekDay: Date) {
        let today = Date.dateString(for: .init())
        let userDay = Date.dateString(for: selectedWeekDay)
        
        // Week day
        let weekDay = WeekDay.weekDay(date: selectedWeekDay)
        
        // check if today != user selected day
        if today != userDay {
            let visibleCategories = filterTrackerss(categories, matching: weekDay) {
                $0.schedule.contains($1)
            }
            
            if let visibleCategories {
                delegate?.visibleCategoriesInCalendarIsNotEmpty()
                self.visibleCategories = visibleCategories
            } else {
                delegate?.visibleCategoriesInCalendarEmpty()
                self.visibleCategories = []
            }
        } else {
            // show all categorie (Because for current day we show all categories)
            if !self.categories.isEmpty {
                delegate?.mainCategoriesIsNotEmpty()
                self.visibleCategories = self.categories
            } else {
                delegate?.mainCategoriesIsEmpty()
                self.categories = []
            }
        }
    }
    
    func showTrackerWithName(name: String) {
        let filteredByName = filterTrackerss(categories, matching: name) {
            $0.name.contains($1)
        }
        
        if let filteredByName {
            delegate?.visibleCategoriesInSearchIsNotEmpty()
            self.visibleCategories = filteredByName
        } else {
            self.visibleCategories = []
            delegate?.visibleCategoriesInSearchEmpty()
        }
    }
}

// MARK: - Private methods
private extension DataSource {
    func filterTrackerss<T>(_ categories: [TrackerCategory], matching value: T, filterFunction: (Tracker, T) -> Bool) -> [TrackerCategory]? {
        var filteredCategories: [TrackerCategory] = []

        for category in categories {
            let filteredTrackers = category.trackers.filter { filterFunction($0, value) }

            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(header: category.header, trackers: filteredTrackers))
            }
        }

        return !filteredCategories.isEmpty ? filteredCategories : nil
    }
    
    func addTracker(_ newTracker: Tracker, toCategoryWithHeader categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.header == categoryTitle }) {
            let category = categories[index]
            let newTrackers = category.trackers + [newTracker]
            let updatedCategory = TrackerCategory(header: categoryTitle, trackers: newTrackers)
            
            self.categories.remove(at: index)
            self.categories.insert(updatedCategory, at: index)
        } else {
            let category = TrackerCategory(header: categoryTitle, trackers: [newTracker])
            
            self.categories.append(category)
        }
    }
}
