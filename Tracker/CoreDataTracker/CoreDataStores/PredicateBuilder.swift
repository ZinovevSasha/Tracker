import Foundation

protocol PredicateBuilderProtocol {
    associatedtype T
    func build(type: NSCompoundPredicate.LogicalType) -> NSPredicate
    func addPredicate(_ predicateType: PredicateBuilder<T>.PredicateType,
        keyPath: KeyPath<T, String?>,
        value: String) -> Self
    
}
struct PredicateBuilder<T> {
    private var predicates: [NSPredicate] = []
    
    func addPredicate(_ predicateType: PredicateType, keyPath: KeyPath<T, String?>, value: String) -> PredicateBuilder<T> {
        var copy = self
        let predicate = predicateType.predicate(keyPath: keyPath, value: value)
        copy.predicates.append(predicate)
        return copy
    }
    
    func build(type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
        return NSCompoundPredicate(type: type, subpredicates: predicates)
    }
}

extension PredicateBuilder {
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

}
