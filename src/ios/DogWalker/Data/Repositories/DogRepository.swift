// CoreData framework - Latest version
import CoreData

// Internal dependencies using relative paths
import "../../../Domain/Entities/Dog"
import "../Persistence/CoreDataStack"
import "../Persistence/PersistenceError"

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure Core Data model includes Dog entity with all required attributes
2. Configure proper indexing for dog ID field in Core Data model
3. Review fetch request performance and implement batch fetching if needed
4. Set up proper error monitoring for Core Data operations
*/

/// DogRepository provides an interface for managing Dog entities in the Core Data store
/// Requirement: User Management (1.3 Scope/Core Features/User Management)
/// Supports dog profile management, including details and associations with owners and walks
public class DogRepository {
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    /// Initializes the DogRepository with a CoreDataStack instance
    /// - Parameter coreDataStack: The Core Data stack to use for persistence
    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Fetch Operations
    
    /// Fetches all Dog entities from the Core Data store
    /// - Returns: An array of Dog entities
    /// - Throws: PersistenceError if the fetch operation fails
    public func fetchAllDogs() throws -> [Dog] {
        let context = coreDataStack.viewContext
        
        // Create fetch request
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Dog")
        
        do {
            // Execute fetch request
            let results = try context.fetch(fetchRequest)
            
            // Convert managed objects to domain entities
            return try results.map { managedObject in
                guard let id = managedObject.value(forKey: "id") as? String,
                      let name = managedObject.value(forKey: "name") as? String,
                      let breed = managedObject.value(forKey: "breed") as? String,
                      let age = managedObject.value(forKey: "age") as? Int,
                      let ownerId = managedObject.value(forKey: "ownerId") as? String else {
                    throw PersistenceError.invalidAttributeValue(attributeName: "required attributes", entityName: "Dog")
                }
                
                return Dog(
                    id: id,
                    name: name,
                    breed: breed,
                    age: age,
                    ownerId: ownerId
                )
            }
        } catch {
            throw PersistenceError.entityFetchFailed(entityName: "Dog")
        }
    }
    
    // MARK: - Add Operations
    
    /// Adds a new Dog entity to the Core Data store
    /// - Parameter dog: The Dog entity to add
    /// - Throws: PersistenceError if the save operation fails
    public func addDog(_ dog: Dog) throws {
        let context = coreDataStack.viewContext
        
        // Create new managed object
        guard let entity = NSEntityDescription.entity(forEntityName: "Dog", in: context),
              let managedObject = NSManagedObject(entity: entity, insertInto: context) as? NSManagedObject else {
            throw PersistenceError.entityCreationFailed(entityName: "Dog")
        }
        
        // Set attributes
        managedObject.setValue(dog.id, forKey: "id")
        managedObject.setValue(dog.name, forKey: "name")
        managedObject.setValue(dog.breed, forKey: "breed")
        managedObject.setValue(dog.age, forKey: "age")
        managedObject.setValue(dog.ownerId, forKey: "ownerId")
        
        // Save context
        try coreDataStack.saveContext()
    }
    
    // MARK: - Delete Operations
    
    /// Deletes a Dog entity from the Core Data store
    /// - Parameter dogId: The ID of the Dog entity to delete
    /// - Throws: PersistenceError if the delete operation fails
    public func deleteDog(_ dogId: String) throws {
        let context = coreDataStack.viewContext
        
        // Create fetch request for specific dog
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Dog")
        fetchRequest.predicate = NSPredicate(format: "id == %@", dogId)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            guard let dogToDelete = results.first else {
                throw PersistenceError(message: "Dog with ID \(dogId) not found")
            }
            
            // Delete the object
            context.delete(dogToDelete)
            
            // Save context
            try coreDataStack.saveContext()
        } catch {
            throw PersistenceError.entityDeletionFailed(entityName: "Dog")
        }
    }
}