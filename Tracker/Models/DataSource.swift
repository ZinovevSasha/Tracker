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

final class DataSource {
    static let shared = DataSource()
    private init() {}
    
    weak var delegate: DataSourceDelegate?
    
    var categories: [TrackerCategory] = [] {
        didSet {
            visibleCategories = categories
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
    func addTracker(_ newTracker: Tracker, toCategory categoryTitle: String) {
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
    func addCategory(title: String) {
        if !categories.contains(where: { $0.header == title }) {
            categories.append(TrackerCategory(header: title, trackers: []))
        }
    }
    
    func isTitleAvailable(title: String) -> Bool {
        return categories.contains(where: { $0.header == title })
    }
    
    func searchTrackerWithName(name: String) -> [TrackerCategory]? {
        let categories: [TrackerCategory]? = categories.compactMap { category in
            let trackerForDate = category.trackers.filter { $0.name.lowercased().contains(name.lowercased())
            }
            return trackerForDate.isEmpty ? nil :
            TrackerCategory(header: category.header, trackers: trackerForDate)
        }
        return categories
    }
    
    func categoryForWeekDay(_ day: Int) -> [TrackerCategory]? {
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
    
    func showTrackerForDayOfWeek(_ selectedDay: Date) {
        let today = Date.currentWeekDayNumber(from: Date())
        let selectedDay = Date.currentWeekDayNumber(from: selectedDay)
        if today != selectedDay {
            if let categoriesForWeekDay = categoryForWeekDay(selectedDay) {
                visibleCategories = categoriesForWeekDay
            }
        } else {
            visibleCategories = categories
        }
    }
}
