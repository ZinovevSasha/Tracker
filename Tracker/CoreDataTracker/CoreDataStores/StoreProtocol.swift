import CoreData
import UIKit

protocol Identible {
    var id: String? { get set }
}

protocol Store {
    associatedtype EntityType: NSManagedObject & Identible
    
    var context: NSManagedObjectContext { get }
        
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
}

final class Context {
    static let shared = Context()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
