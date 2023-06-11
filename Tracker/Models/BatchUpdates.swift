import Foundation

struct DataProviderUpdate {
    struct Move: Hashable {
        let oldIndexPath: IndexPath
        let newIndexPath: IndexPath
    }
    var insertedSection: IndexSet
    var deletedSection: IndexSet
    var insertedIndexes: IndexPath
    var deletedIndexes: IndexPath
    var updatedIndexes: IndexPath
    let movedIndexes: Set<Move>
}
