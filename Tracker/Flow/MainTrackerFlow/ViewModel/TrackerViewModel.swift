import Foundation
import Combine

final class TrackerViewModel {
     var categoryViewModels: [TrackerCategoryViewModel] = []
    @Published var update: BatchUpdates?
    
    var currentDateString: String {
        Date.dateString(for: currentDay)
    }
    
    private var currentDay = Date()
   
    // MARK: - Models
    private lazy var dataProvider: DataProvider? = {
        do {
            return try DataProvider(delegate: self)
        } catch {
            print("Данные недоступны")
            return nil
        }
    }()
    
    deinit {
        print("FDFSAFASFAS")
    }
    
    private let diffCalculator: DiffCalculator
    
    init(diffCalculator: DiffCalculator) {
        self.diffCalculator = diffCalculator
        print("init viewModel")
    }
    
    func loadData() {
        dataChanged()
    }
    
    private var weekDayNumber: String {
        String(Date.currentWeekDayNumber(from: currentDay))
    }
    
    func numberOfSections() -> Int {
      return categoryViewModels.count
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
      return categoryViewModels[section].trackers.count
    }

    func itemAtIndexPath(_ indexPath: IndexPath) -> TrackerCellViewModel {
      return categoryViewModels[indexPath.section].trackers[indexPath.item]
    }
    
    func header(for section: Int) -> String {
        return categoryViewModels[section].header        
    }
           
    func deleteTrackerAt(indexPath: IndexPath) {
        do {
            try dataProvider?.deleteTrackerWith(id: getId(at: indexPath) )
        } catch {
            print("🐳", error)
        }
    }
    
    func saveAsCompletedTrackerAt(indexPath: IndexPath) {
        do {
            try dataProvider?.saveAsCompletedTrackerWith(
                id: getId(at: indexPath),
                for: currentDateString
            )
            updateDynamicCellViewModelAt(indexPath: indexPath)
        } catch {
            print("⛈️", error)
        }
    }
    
    func attachTrackerAt(indexPath: IndexPath) {
        dataProvider?.attachTrackerWith(id: getId(at: indexPath) )
    }
    
    func unattachTrackerAt(indexPath: IndexPath) {        
        dataProvider?.unattachTrackerWith(id: getId(at: indexPath) )
    }
    
    func getId(at indexPath: IndexPath) -> String {
        let tracker = categoryViewModels[indexPath.section].trackers[indexPath.row]
        return tracker.id
    }
    
    func getTrackerAt(indexPath: IndexPath) -> Tracker? {
        return Tracker(name: "", emoji: "", color: "", schedule: [1], kind: .habit)
    }
        
    func setCurrentDayTo(newDate date: Date) {
        currentDay = date
    }
    
    func fetchTrackerBy(weekDay: String) {
        do {
            try dataProvider?.fetchTrackersBy(weekDay: weekDayNumber)
            
        } catch {
            print("🏹", error)
        }
    }
    
    func fetchTrackerBy(name: String, andWeekDay weekDay: String) {
        do {
            try dataProvider?.fetchTrackersBy(name: name, weekDay: weekDayNumber)
            
        } catch {
            print("😎", error)
        }
    }
    
    func getTrackerCellViewModelFor(_ indexPath: IndexPath) -> TrackerCellViewModel? {
        return categoryViewModels[indexPath.section].trackers[indexPath.row]        
    }
                
    func updateDynamicCellViewModelAt(indexPath: IndexPath) {
        let trackerCellViewModel = categoryViewModels[indexPath.section].trackers[indexPath.row]
        if let daysTracked = dataProvider?.daysTrackedForTrackerWith(id: getId(at: indexPath)),
           let isCompletedForToday = dataProvider?.isTrackerCompletedForToday(indexPath, date: currentDay.todayString) {
            trackerCellViewModel.trackedDaysViewModel = TrackedDaysViewModel(trackedDays: daysTracked, isTrackedForToday: isCompletedForToday)
        }
    }
}

// MARK: - DataProviderDelegate
extension TrackerViewModel: DataProviderDelegate {
    // Update category view models and calculate the difference
    func dataChanged() {
        if let categories = dataProvider?.getCategories(), !categories.isEmpty,
           let trackers = categories.first?.trackers, !trackers.isEmpty {
            let pinnedTrackers = getPinnedTrackers(from: categories)
            let nonPinnedCategories = getNonPinnedCategories(from: categories)
            let pinnedCategory = getPinnedCategory(from: pinnedTrackers)
            let allCategories = getAllCategories(pinnedCategory: pinnedCategory, nonPinnedCategories: nonPinnedCategories)
            let newCategoryViewModels = getCategoryViewModels(from: allCategories)
            let newUpdate = DiffCalculatorr().calculateDiff(oldData: categoryViewModels, newData: newCategoryViewModels)
            
            self.categoryViewModels = newCategoryViewModels
            self.update = newUpdate
        }
    }
    
    func place() {
        //placeholderView.state = .question
    }
    
    func noResultFound() {
        //placeholderView.state = .noResult
    }
    
    func resultFound() {
        //placeholderView.state = .invisible(animate: true)
    }
    
    
    // Get pinned trackers
    func getPinnedTrackers(from categories: [TrackerCategory]) -> [Tracker] {
        return categories.flatMap { $0.trackers.filter { $0.isPinned } }
    }

    // Get non-pinned categories
    func getNonPinnedCategories(from categories: [TrackerCategory]) -> [TrackerCategory] {
        return categories.compactMap { category in
            let nonPinnedTrackers = category.trackers.filter { !$0.isPinned }
            if !nonPinnedTrackers.isEmpty {
                return TrackerCategory(header: category.header, trackers: nonPinnedTrackers, isLastSelected: false)
            } else {
                return nil
            }
        }
    }

    // Create a pinned category if there are any pinned trackers
    func getPinnedCategory(from pinnedTrackers: [Tracker]) -> TrackerCategory? {
        if !pinnedTrackers.isEmpty {
            return TrackerCategory(header: "Attached", trackers: pinnedTrackers, isLastSelected: false)
        } else {
            return nil
        }
    }

    // Combine all categories into a single array
    func getAllCategories(pinnedCategory: TrackerCategory?, nonPinnedCategories: [TrackerCategory]) -> [TrackerCategory] {
        if let pinnedCategory = pinnedCategory {
            return [pinnedCategory] + nonPinnedCategories
        } else {
            return nonPinnedCategories
        }
    }

    // Convert categories to view models
    func getCategoryViewModels(from categories: [TrackerCategory]) -> [TrackerCategoryViewModel] {
        return categories.compactMap { category in
            TrackerCategoryViewModel.from(category)
        }
    }

    // Calculate the difference between old and new data
    func getUpdate(oldData: [TrackerCategoryViewModel], newData: [TrackerCategoryViewModel]) -> BatchUpdates {
        return diffCalculator.calculateDiff(oldData: oldData, newData: newData)
    }
}

