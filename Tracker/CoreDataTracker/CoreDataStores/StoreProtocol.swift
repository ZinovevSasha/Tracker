import CoreData
import UIKit

protocol Store {
    associatedtype EntityType
    
    var context: NSManagedObjectContext { get }
    var predicateBuilder: PredicateBuilder<EntityType> { get }
    
    init(context: NSManagedObjectContext, predicateBuilder: PredicateBuilder<EntityType>)
    
    func save()
}

extension Store {
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    
    init() throws {
        let context = try Context.getContext()
        self.init(context: context, predicateBuilder: PredicateBuilder())
    }
}

enum Context {
    enum DataProviderError: Error {
        case contextUnavailable
    }
    
    static func getContext() throws -> NSManagedObjectContext {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?
            .persistentContainer.viewContext else {
            throw DataProviderError.contextUnavailable
        }
        return context
    }
}
