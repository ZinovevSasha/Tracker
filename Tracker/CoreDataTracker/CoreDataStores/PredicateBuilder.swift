import Foundation

final class PredicateBuilder {
    func date( _ date: String) -> NSPredicate {
        return NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.date),
            date
        )
    }
    
    func weekDay( _ weekDay: String) -> NSPredicate {
        return NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.schedule),
            weekDay
        )
    }
    
    func name( _ name: String) -> NSPredicate {
        return NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.name),
            name
        )
    }
   
    func dateOrWeekDay(date: String, weekDay: String) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: .or, subpredicates: [
            self.weekDay(weekDay),
            self.date(date)
        ])
    }
    
    func nameAndWeekDay(name: String, weekDay: String) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: .and, subpredicates: [
            self.name(name),
            self.weekDay(weekDay)
        ])
    }
    
    func nameAndDate(name: String, date: String) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: .and, subpredicates: [
            self.name(name),
            self.date(date)
        ])
    }
    
    func nameAndWeekDayOrNameAndDate(name: String, date: String, weekDay: String) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: .or, subpredicates: [
            self.nameAndWeekDay(name: name, weekDay: weekDay),
            self.nameAndDate(name: name, date: date)
        ])
    }
}
