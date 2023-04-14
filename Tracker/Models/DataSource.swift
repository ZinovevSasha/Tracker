//
//  DataSource.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.04.2023.
//

import Foundation

protocol DataSourceDelegate: AnyObject {
    func updateTrackers()
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
            let notEmpty = categories.filter { !$0.trackers.isEmpty }
            visibleCategories = notEmpty
        }
    }
    
    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            delegate?.updateTrackers()
        }
    }
    var completedTrackers: [TrackerRecord] = []
    var completedTrackersId: Set<UUID> = []
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
            addTracker(tracker, toCategoryWithHeader: header)
        } else {
            print("Error adding Tracker")
        }
    }
    
    func getCategories() -> [TrackerCategory] {
        categories
    }
    
    func removeCategory(_ indexPath: IndexPath) {
        categories.remove(at: indexPath.section)
    }
    
    func removeTracker(_ indexPath: IndexPath) {
        categories.remove(at: indexPath.section).trackers[indexPath.row]
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
    
    //  Functions for search and dataPicker
    func showTrackerWithName(name: String) {
        let categories: [TrackerCategory]? = categories.compactMap { category in
            let trackerForDate = category.trackers.filter { $0.name.lowercased().contains(name.lowercased())
            }
            return trackerForDate.isEmpty ? nil :
            TrackerCategory(header: category.header, trackers: trackerForDate)
        }
        
        visibleCategories = categories ?? []
    }
    
    func showTrackerForDayOfWeek(_ selectedDay: Date) {
        let today = Date.currentWeekDayNumber(from: .init())
        let selectedDay = Date.currentWeekDayNumber(from: selectedDay)
        if today != selectedDay {
            if let categoriesForWeekDay = categoryForWeekDay(selectedDay) {
                visibleCategories = categoriesForWeekDay
            }
        } else {
            visibleCategories = categories
        }
    }
    
    // MARK: - Private
    private func addTracker(_ newTracker: Tracker, toCategoryWithHeader categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.header == categoryTitle }) {
            let category = categories[index]
            let newTrackers = category.trackers + [newTracker]
            let updatedCategory = TrackerCategory(header: categoryTitle, trackers: newTrackers)
            categories.remove(at: index)
            categories.insert(updatedCategory, at: index)
        } else {
            let category = TrackerCategory(header: categoryTitle, trackers: [newTracker])
            categories.append(category)
        }
    }
    
    private func categoryForWeekDay(_ day: Int) -> [TrackerCategory]? {
        let weekday = WeekDay(rawValue: day) ?? .sunday
        let categories: [TrackerCategory]? = categories.compactMap { category in
            let trackerForDate = category.trackers.filter {
                $0.schedule.contains(weekday)
            }
            return trackerForDate.isEmpty ? nil :
            TrackerCategory(header: category.header, trackers: trackerForDate)
        }
        return categories
    }
}
