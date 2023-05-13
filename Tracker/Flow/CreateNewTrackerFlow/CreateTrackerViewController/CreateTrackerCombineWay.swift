////
////  CreateTrackerCombineWay.swift
////  Tracker
////
////  Created by Александр Зиновьев on 09.05.2023.
////
//
//import Foundation
//import CoreData
//import Combine
//
//final class CreateTrackerViewModel {
//    // MARK: - Inputs
//    @Published var trackerName: String?
//    @Published var trackerEmoji: String?
//    @Published var trackerColor: String?
//    @Published var trackerDate: String?
//    @Published var trackerWeekDay: Set<Int>?
//    
//    // MARK: - Outputs
//    @Published var canCreateTracker = false
//    @Published var trackerCreated = false
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        Publishers.CombineLatest3($trackerName, $trackerEmoji, $trackerColor)
//            .map { name, emoji, color in
//                name != nil && color != nil && emoji != nil
//            }
//            .assign(to: \.canCreateTracker, on: self)
//            .store(in: &cancellables)
//    }
//    
//    func createTracker() {
//        guard canCreateTracker else {
//            return
//        }
//        
//        let tracker = Tracker(id: "", name: "", emoji: "", color: "")
//        trackerCreated = true
//    }
//        
//    // MARK: - Private
//    
//    // 4) dataForTableView
//    var dataForTableView = CategoryAndScheduleData.init()
//    // 5) dataForCollectionView
//    let dataForCollectionView = EmojisAndColorData().dataSource
//    // 1) Configuration
//    private let trackerType: UserTracker.TrackerType = .habit
//    
//    // 2) Category Name
//    var categoryName: String {
//        dataForTableView.categoryName
//    }
//    // 3) Date for ocasional tracker
//    private let date: String = "Date()"
//    
//    private lazy var trackerCategoryStore: TrackerCategoryStore? = {
//        do {
//            return try TrackerCategoryStore()
//        } catch {
//            return nil
//        }
//    }()
//}
//
//extension CreateTrackerViewModel {
//    var numberOfRows: Int {
//        switch trackerType {
//        case .ocasional:
//            return dataForTableView.oneRow.count
//        case .habit:
//            return dataForTableView.twoRows.count
//        }
//    }
//    
//    var dataForTable: [RowData] {
//        switch trackerType {
//        case .ocasional:
//            return dataForTableView.oneRow
//        case .habit:
//            return dataForTableView.twoRows
//        }
//    }
//    
//    var numberOfCollectionSections: Int {
//        dataForCollectionView.count
//    }
//    
//    func numberOfItemsInSection(_ section: Int) -> Int {
//        switch dataForCollectionView[section] {
//        case .emojiSection(let items):
//            return items.count
//        case .colorSection(let items):
//            return items.count
//        }
//    }
//    
//    func getSection(_ indexPath: IndexPath) -> CollectionViewData {
//        dataForCollectionView[indexPath.section]
//    }
//}
