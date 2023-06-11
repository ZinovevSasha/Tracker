import Foundation

protocol TrackerPredicateBuilderProtocol {
    func buildPredicateTrackersFor(weekDay: String) -> NSPredicate
    func buildPredicateTrackersWith(name: String, forWeekDay weekDay: String) -> NSPredicate
    func buildPredicateCompletedTrackersWith(name: String, forDate date: String) -> NSPredicate
    func buildPredicateCompletedTrackersFor(date: String) -> NSPredicate
    func buildPredicateUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) -> NSPredicate
    func buildPredicateUncompletedTrackers(forWeekDay weekDay: String, andForDate date: String) -> NSPredicate
}

protocol TrackerRecordPredicateBuilderProtocol {
    func buildPredicateIsCompletedFor(selectedDate date: String, trackerWithId id: String) -> NSPredicate
}

protocol TrackerCategoryPredicateBuilderProtocol {
    func buildPredicateCategory(name: String) -> NSPredicate
    func buildPredicateCategoryIsLastSelected() -> NSPredicate
}

final class PredicateBuilder {}

extension PredicateBuilder: TrackerPredicateBuilderProtocol {
    func buildPredicateTrackersFor(weekDay: String) -> NSPredicate {
        predicate(weekDay: weekDay)
    }

    func buildPredicateTrackersWith(name: String, forWeekDay weekDay: String) -> NSPredicate {
        let namePredicate = predicate(name: name)
        let weekDayPredicate = predicate(weekDay: weekDay)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            namePredicate, weekDayPredicate
        ])
    }

    func buildPredicateCompletedTrackersWith(name: String, forDate date: String) -> NSPredicate {
        let namePredicate = predicate(name: name)
        let completedForDatePredicate = predicateCompletedTrackersFor(date: date)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            namePredicate, completedForDatePredicate
        ])
    }

    func buildPredicateCompletedTrackersFor(date: String) -> NSPredicate {
        predicateCompletedTrackersFor(date: date)
    }

    func buildPredicateUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) -> NSPredicate {
        let weekDayPredicate = predicate(weekDay: weekDay)
        let uncompletedForDatePredicate = predicateUncompletedTrackersFor(date: date)
        let neverTrackedPredicate = predicateNeverTrackedTracker()
        let namePredicate = predicate(name: name)

        let dontTrackedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            neverTrackedPredicate, weekDayPredicate, namePredicate
        ])

        let uncompletedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            uncompletedForDatePredicate, weekDayPredicate, namePredicate
        ])

        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            dontTrackedAndForDayOfWeek, uncompletedForDatePredicate
        ])
    }

    func buildPredicateUncompletedTrackers(forWeekDay weekDay: String, andForDate date: String) -> NSPredicate {
        let weekDayPredicate = predicate(weekDay: weekDay)
        let uncompletedForDatePredicate = predicateUncompletedTrackersFor(date: date)
        let neverTrackedPredicate = predicateNeverTrackedTracker()

        let dontTrackedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            neverTrackedPredicate, weekDayPredicate
        ])

        let uncompletedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            uncompletedForDatePredicate, weekDayPredicate
        ])

        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            dontTrackedAndForDayOfWeek, uncompletedForDatePredicate
        ])
    }
}

extension PredicateBuilder: TrackerRecordPredicateBuilderProtocol {
    func buildPredicateIsCompletedFor(selectedDate date: String, trackerWithId id: String) -> NSPredicate {
        let idPredicate = predicate(id: id)
        let datePredicate = predicate(date: date)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            idPredicate, datePredicate
        ])
    }
}

extension PredicateBuilder: TrackerCategoryPredicateBuilderProtocol {
    func buildPredicateCategory(name: String) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCD.header),
            name)
    }

    func buildPredicateCategoryIsLastSelected() -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCD.isLastSelected),
            NSNumber(value: true)
        )
    }
}

private extension PredicateBuilder {
    // MARK: - TrackerCD
    func predicate(weekDay: String) -> NSPredicate {
        NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCD.schedule),
            weekDay
        )
    }

    func predicate(name: String) -> NSPredicate {
        NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCD.name),
            name
        )
    }

    func predicateNeverTrackedTracker() -> NSPredicate {
        NSPredicate(
            format: "%K.@count == 0",
            #keyPath(TrackerCD.trackerRecord)
        )
    }

    func predicateUncompletedTrackersFor(date: String) -> NSPredicate {
        NSPredicate(
            format: "SUBQUERY(%K, $record, $record.%K == %@).@count == 0",
            #keyPath(TrackerCD.trackerRecord),
            #keyPath(TrackerRecordCD.date),
            date
        )
    }

    func predicateCompletedTrackersFor(date: String) -> NSPredicate {
        NSPredicate(
            format: "ANY %K.%K == %@",
            #keyPath(TrackerCD.trackerRecord),
            #keyPath(TrackerRecordCD.date),
            date
        )
    }

    // MARK: - TrackerRecordCD
    func predicate(id: String) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCD.identifier),
            id
        )
    }

    func predicate(date: String) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCD.date),
            date
        )
    }
}
