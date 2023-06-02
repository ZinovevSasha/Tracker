//import Foundation
//
//struct BatchUpdates {
//    var deleteSections: Set<Int> = []
//    var insertSections: Set<Int> = []
//    var updateSections: Set<Int> = []
//    var moveSections: [(fromIndex: Int, toIndex: Int)] = []
//    
//    var deleteItems: [Int: Set<Int>] = [:]
//    var insertItems: [Int: Set<Int>] = [:]
//    var updateItems: [Int: Set<Int>] = [:]
//    var moveItems: [(fromIndexPath: IndexPath, toIndexPath: IndexPath)] = []
//    var reloadItems: Set<IndexPath> = [] // New property added
//    
//    var moveAndUpdates: [(from: IndexPath, to: IndexPath)] = [] // New property added
//}
//class DiffCalculator {
//    func calculateDiff(oldData: [TrackerCategoryViewModel], newData: [TrackerCategoryViewModel]) -> BatchUpdates {
//        var batchUpdates = BatchUpdates()
//        
//        // Create sets of old and new trackers.
//        let oldSet = Set(oldData.flatMap { $0.trackers })
//        let newSet = Set(newData.flatMap { $0.trackers })
//        
//        // Calculate added and removed trackers.
//        let addedTrackers = newSet.subtracting(oldSet)
//        let removedTrackers = oldSet.subtracting(newSet)
//        
//        // Calculate section-wise changes.
//        let oldHeaderSet = Set(oldData.map { $0.header })
//        let newHeaderSet = Set(newData.map { $0.header })
//        let addedHeaders = newHeaderSet.subtracting(oldHeaderSet)
//        let removedHeaders = oldHeaderSet.subtracting(newHeaderSet)
//        let commonHeaders = oldHeaderSet.intersection(newHeaderSet)
//        
//        // Find the indices of headers that have been added or removed.
//        for header in removedHeaders {
//            if let index = oldData.firstIndex(where: { $0.header == header }) {
//                batchUpdates.deleteSections.insert(index)
//            }
//        }
//        for header in addedHeaders {
//            if let index = newData.firstIndex(where: { $0.header == header }) {
//                batchUpdates.insertSections.insert(index)
//            }
//        }
//        
//        // Find the indices of headers that have been updated.
//        for header in commonHeaders {
//            guard let oldIndex = oldData.firstIndex(where: { $0.header == header }),
//                  let newIndex = newData.firstIndex(where: { $0.header == header }),
//                  !oldData[oldIndex].trackers.elementsEqual(newData[newIndex].trackers) else {
//                continue
//            }
//            batchUpdates.updateSections.insert(newIndex)
//        }
//        
//        // Find the indices of headers that have been moved.
//        var moves = [(fromIndex: Int, toIndex: Int)]()
//        for header in commonHeaders {
//            guard let oldIndex = oldData.firstIndex(where: { $0.header == header }),
//                  let newIndex = newData.firstIndex(where: { $0.header == header }),
//                  oldIndex != newIndex else {
//                continue
//            }
//            moves.append((fromIndex: oldIndex, toIndex: newIndex))
//        }
//        batchUpdates.moveSections = moves.sorted(by: { $0.fromIndex < $1.fromIndex })
//            .map({ (fromIndex: $0.fromIndex, toIndex: $0.toIndex) })
//        
//        // Find the indices of items that have been added or removed.
//        var deletions = [Int: Set<Int>]()
//        var insertions = [Int: Set<Int>]()
//        for tracker in removedTrackers {
//            if let oldSectionIndex = oldData.firstIndex(where: { $0.trackers.contains(tracker) }),
//               let oldItemIndex = oldData[oldSectionIndex].trackers.firstIndex(of: tracker) {
//                var sectionDeletions = deletions[oldSectionIndex] ?? Set()
//                sectionDeletions.insert(oldItemIndex)
//                deletions[oldSectionIndex] = sectionDeletions
//            }
//        }
//        for tracker in addedTrackers {
//            if let newSectionIndex = newData.firstIndex(where: { $0.trackers.contains(tracker) }),
//               let newItemIndex = newData[newSectionIndex].trackers.firstIndex(of: tracker) {
//                var sectionInsertions = insertions[newSectionIndex] ?? Set()
//                sectionInsertions.insert(newItemIndex)
//                insertions[newSectionIndex] = sectionInsertions
//            }
//        }
//        batchUpdates.deleteItems = deletions
//        batchUpdates.insertItems = insertions
//        
//        // Find the indices of items that have been moved and updated.
//        var movesAndUpdates = [(from: IndexPath, to: IndexPath)]()
//        var updates = [Int: Set<Int>]()
//        for tracker in oldSet.intersection(newSet) {
//            guard let oldSectionIndex = oldData.firstIndex(where: { $0.trackers.contains(tracker) }),
//                  let oldItemIndex = oldData[oldSectionIndex].trackers.firstIndex(of: tracker),
//                  let newSectionIndex = newData.firstIndex(where: { $0.trackers.contains(tracker) }),
//                  let newItemIndex = newData[newSectionIndex].trackers.firstIndex(of: tracker)
//            else { continue }
//            
//            if oldSectionIndex != newSectionIndex || oldItemIndex != newItemIndex {
//                movesAndUpdates.append((
//                    from: IndexPath(item: oldItemIndex, section: oldSectionIndex),
//                    to: IndexPath(item: newItemIndex, section: newSectionIndex)))
//            }
//            
//            if oldData[oldSectionIndex].trackers[oldItemIndex] != newData[newSectionIndex].trackers[newItemIndex] {
//                var sectionUpdates = updates[newSectionIndex] ?? Set()
//                sectionUpdates.insert(newItemIndex)
//                updates[newSectionIndex] = sectionUpdates
//            }
//        }
//        
//        // Sort the move and update operations by section index.
//        movesAndUpdates.sort(by: { $0.from.section < $1.from.section })
//        batchUpdates.moveItems = movesAndUpdates.map({ (from: $0.from, to: $0.to) })
//        batchUpdates.updateItems = updates
//        
//        return batchUpdates
//    }
//}
//
//
//class DiffCalculatorr {
//    func calculateDiff(oldData: [TrackerCategoryViewModel], newData: [TrackerCategoryViewModel]) -> BatchUpdates {
//        var batchUpdates = BatchUpdates()
//        
//        // Create sets of old and new trackers.
//        let oldSet = Set(oldData.flatMap { $0.trackers })
//        let newSet = Set(newData.flatMap { $0.trackers })
//        
//        // Calculate added and removed trackers.
//        let addedTrackers = newSet.subtracting(oldSet)
//        let removedTrackers = oldSet.subtracting(newSet)
//        
//        // Calculate section-wise changes.
//        let oldHeaderSet = Set(oldData.map { $0.header })
//        let newHeaderSet = Set(newData.map { $0.header })
//        let addedHeaders = newHeaderSet.subtracting(oldHeaderSet)
//        let removedHeaders = oldHeaderSet.subtracting(newHeaderSet)
//        let commonHeaders = oldHeaderSet.intersection(newHeaderSet)
//        
//        // Find the indices of headers that have been added or removed.
//        for header in removedHeaders {
//            if let index = oldData.firstIndex(where: { $0.header == header }) {
//                let adjustedIndex = adjustedSectionIndex(for: index, in: batchUpdates)
//                batchUpdates.deleteSections.insert(adjustedIndex)
//            }
//        }
//        for header in addedHeaders {
//            if let index = newData.firstIndex(where: { $0.header == header }) {
//                let adjustedIndex = adjustedSectionIndex(for: index, in: batchUpdates)
//                batchUpdates.insertSections.insert(adjustedIndex)
//            }
//        }
//        
//        // Find the indices of headers that have been updated.
//        for header in commonHeaders {
//            guard let oldIndex = oldData.firstIndex(where: { $0.header == header }),
//                  let newIndex = newData.firstIndex(where: { $0.header == header }),
//                  !oldData[oldIndex].trackers.elementsEqual(newData[newIndex].trackers) else {
//                continue
//            }
//            let adjustedIndex = adjustedSectionIndex(for: newIndex, in: batchUpdates)
//            batchUpdates.updateSections.insert(adjustedIndex)
//        }
//        
//        // Find the indices of headers that have been moved.
//        var moves = [(fromIndex: Int, toIndex: Int)]()
//        for header in commonHeaders {
//            guard let oldIndex = oldData.firstIndex(where: { $0.header == header }),
//                  let newIndex = newData.firstIndex(where: { $0.header == header }),
//                  oldIndex != newIndex else {
//                continue
//            }
//            let adjustedFromIndex = adjustedSectionIndex(for: oldIndex, in: batchUpdates)
//            let adjustedToIndex = adjustedSectionIndex(for: newIndex, in: batchUpdates)
//            moves.append((fromIndex: adjustedFromIndex, toIndex: adjustedToIndex))
//        }
//        batchUpdates.moveSections = moves.sorted(by: { $0.fromIndex < $1.fromIndex })
//            .map({ (fromIndex: $0.fromIndex, toIndex: $0.toIndex) })
//        
//        // Find the indices of items that have been added or removed.
//        var deletions = [Int: Set<Int>]()
//        var insertions = [Int: Set<Int>]()
//        for tracker in removedTrackers {
//            if let oldSectionIndex = oldData.firstIndex(where: { $0.trackers.contains(tracker) }),
//               let oldItemIndex = oldData[oldSectionIndex].trackers.firstIndex(of: tracker) {
//                var sectionDeletions = deletions[oldSectionIndex] ?? Set()
//                sectionDeletions.insert(oldItemIndex)
//                deletions[oldSectionIndex] = sectionDeletions
//            }
//        }
//        for tracker in addedTrackers {
//            if let newSectionIndex = newData.firstIndex(where: { $0.trackers.contains(tracker) }),
//               let newItemIndex = newData[newSectionIndex].trackers.firstIndex(of: tracker) {
//                var sectionInsertions = insertions[newSectionIndex] ?? Set()
//                sectionInsertions.insert(newItemIndex)
//                insertions[newSectionIndex] = sectionInsertions
//            }
//        }
//        batchUpdates.deleteItems = deletions
//        batchUpdates.insertItems = insertions
//        
//        // Find the indices of items that have been moved and updated.
//        var movesAndUpdates = [(from: IndexPath, to: IndexPath)]()
//        var updates = [Int: Set<Int>]()
//        for tracker in oldSet.intersection(newSet) {
//            guard let oldSectionIndex = oldData.firstIndex(where: { $0.trackers.contains(tracker) }),
//                  let oldItemIndex = oldData[oldSectionIndex].trackers.firstIndex(of: tracker),
//                  let newSectionIndex = newData.firstIndex(where: { $0.trackers.contains(tracker) }),
//                  let newItemIndex = newData[newSectionIndex].trackers.firstIndex(of: tracker),
//                  oldSectionIndex != newSectionIndex || oldItemIndex != newItemIndex else {
//                continue
//            }
//            
//            if oldSectionIndex == newSectionIndex {
//                let adjustedSectionIndex = adjustedSectionIndex(for: oldSectionIndex, in: batchUpdates)
//                movesAndUpdates.append((from: IndexPath(item: oldItemIndex, section: adjustedSectionIndex),
//                                        to: IndexPath(item: newItemIndex, section: adjustedSectionIndex)))
//            } else {
//                var sectionUpdates = updates[newSectionIndex] ?? Set()
//                sectionUpdates.insert(newItemIndex)
//                updates[newSectionIndex] = sectionUpdates
//                
//                var sectionDeletions = deletions[oldSectionIndex] ?? Set()
//                sectionDeletions.insert(oldItemIndex)
//                deletions[oldSectionIndex] = sectionDeletions
//                
//                var sectionInsertions = insertions[newSectionIndex] ?? Set()
//                sectionInsertions.insert(newItemIndex)
//                insertions[newSectionIndex] = sectionInsertions
//            }
//        }
//        
//        batchUpdates.moveAndUpdates = movesAndUpdates
//        batchUpdates.updateItems = updates
//    
//        return batchUpdates
//    }
//    
//    private func adjustedSectionIndex(for index: Int, in batchUpdates: BatchUpdates) -> Int {
//        var adjustedIndex = index
//        // Account for previous section insertions.
//        for insertionIndex in batchUpdates.insertSections where insertionIndex <= adjustedIndex {
//            adjustedIndex += 1
//        }
//        // Account for previous section deletions.
//        for deletionIndex in batchUpdates.deleteSections where deletionIndex < adjustedIndex {
//            adjustedIndex -= 1
//        }
//        // Account for previous section moves.
//        for move in batchUpdates.moveSections where move.fromIndex < adjustedIndex && move.toIndex >= adjustedIndex {
//            adjustedIndex -= 1
//        }
//        return adjustedIndex
//    }
//}
