import CoreData
import UIKit

protocol Identible {
    var id: String? { get set }
}

protocol Store {
    associatedtype EntityType: NSManagedObject & Identible
    
    var context: NSManagedObjectContext { get }
    var predicateBuilder: PredicateBuilder<EntityType> { get }
    
    init(context: NSManagedObjectContext, predicateBuilder: PredicateBuilder<EntityType>)
    
    func save()
    func delete(_ entity: EntityType) throws
    func getObjectBy(id: String) -> [EntityType]?
}

extension Store {
    func save() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    func delete(_ entity: EntityType) throws {
        context.delete(entity)
        save()
    }

    func getObjectBy(id: String) -> [EntityType]? {
        let fetchRequest = EntityType.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return try? context.fetch(fetchRequest) as? [EntityType]
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
