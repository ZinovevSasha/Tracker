import Foundation

struct Tracker {
    let color: String?
    var ffff: String?
}

enum PredicateType {
    case equalTo
    case notEqualTo
    case greaterThan
    case lessThan
    case contains
    case beginsWith
    case endsWith
    
    func predicate<T>(keyPath: KeyPath<T, String?>, value: String) -> NSPredicate {
        let format: String
        switch self {
        case .equalTo:
            format = "%K == %@"
        case .notEqualTo:
            format = "NOT (%K == %@)"
        case .greaterThan:
            format = "%K > %@"
        case .lessThan:
            format = "%K < %@"
        case .contains:
            format = "%K CONTAINS[cd] %@"
        case .beginsWith:
            format = "%K BEGINSWITH[cd] %@"
        case .endsWith:
            format = "%K ENDSWITH[cd] %@"
        }
        return NSPredicate(format: format, keyPath._kvcKeyPathString ?? "", value)
    }
}


//struct PredicateBuilder<T> {
//    var predicates: [NSPredicate] = []
//
//    func addPredicate(_ predicateType: PredicateType, keyPath: KeyPath<T, String?>, value: String) -> PredicateBuilder<T> {
//        var copy = self
//        let predicate = predicateType.predicate(keyPath: keyPath, value: value)
//        copy.predicates.append(predicate)
//        return copy
//    }
//
//    func build(type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
//        return NSCompoundPredicate(type: type, subpredicates: predicates)
//    }
//}
//
//let builder = PredicateBuilder<Tracker>()
//    .addPredicate(.beginsWith, keyPath: \.color, value: "f")
//    .addPredicate(.contains, keyPath: \.color, value: "dddd")
//
//let anotherBuilder = builder
//
//anotherBuilder.addPredicate(.notEqualTo, keyPath: \.color, value: "dfsdfsd").build()
//
//print(builder.predicates)
//print(anotherBuilder.predicates)

////////////////////////////////////////////////////////////////////////////////////////////
//struct PredicateBuilder<T> {
//    var predicates: [NSPredicate] = []
//
//    mutating func addPredicate(_ predicateType: PredicateType, keyPath: KeyPath<T, String?>, value: String) {
//        let predicate = predicateType.predicate(keyPath: keyPath, value: value)
//        predicates.append(predicate)
//    }
//
//    func build(type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
//        return NSCompoundPredicate(type: type, subpredicates: predicates)
//    }
//}
//
//var builder = PredicateBuilder<Tracker>()
//builder.addPredicate(.beginsWith, keyPath: \.color, value: "f")
//builder.addPredicate(.contains, keyPath: \.color, value: "dddd")
//
//var anotherBuilder = builder
//anotherBuilder.addPredicate(.notEqualTo, keyPath: \.color, value: "dfsdfsd")
//let predicate = anotherBuilder.build()
//
//
//print(builder.predicates) // prints [color BEGINSWITH "f", color CONTAINS "dddd", color != "dfsdfsd"]
//print(anotherBuilder.predicates) // prints [color BEGINSWITH "f", color CONTAINS "dddd", color != "dfsdfsd"]

////////////////////////////////////////////////////////////////////////////////////////////

final class PredicateBuilder<T> {
    var predicates: [NSPredicate] = []
    
    func addPredicate(_ predicateType: PredicateType, keyPath: KeyPath<T, String?>, value: String) -> PredicateBuilder {
        let predicate = predicateType.predicate(keyPath: keyPath, value: value)
        predicates.append(predicate)
        return self
    }
    
    func build(type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
        let predicates = predicates
        self.predicates.removeAll()
        return NSCompoundPredicate(type: type, subpredicates: predicates)
    }
}



var builder1 = PredicateBuilder<Tracker>()
builder1.addPredicate(.beginsWith, keyPath: \.color, value: "f")
builder1.addPredicate(.contains, keyPath: \.color, value: "dddd")

var anotherBuilder1 = builder1
anotherBuilder1.addPredicate(.notEqualTo, keyPath: \.color, value: "dfsdfsd")
//let predicate1 = anotherBuilder1.build()


print(builder1.predicates)
print(anotherBuilder1.predicates)




