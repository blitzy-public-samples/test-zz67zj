// CoreData framework - Latest version
import CoreData

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure Core Data model includes Walk entity with all required attributes
2. Configure proper indexes for performance optimization
3. Set up proper error handling and logging for database operations
4. Review data migration strategy for model updates
*/

// Internal imports using relative paths
import "../../Domain/Entities/Walk"
import "../Persistence/CoreDataStack"
import "../Persistence/PersistenceError"

/// WalkRepository provides an interface for managing Walk entities in Core Data
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
/// Requirement: Data Management (Technical Specification/8.2 Database Design/8.2.2 Data Management Strategy)
/// Ensures efficient and reliable data storage and retrieval using Core Data for local persistence
class WalkRepository {
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    /// Initializes the WalkRepository with a CoreDataStack instance
    /// - Parameter coreDataStack: The CoreDataStack to use for persistence
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - CRUD Operations
    
    /// Creates a new Walk entity in the database
    /// - Parameter walk: The Walk entity to create
    /// - Throws: PersistenceError if creation fails
    func createWalk(_ walk: Walk) throws {
        let context = coreDataStack.viewContext
        
        // Create managed object
        guard let walkEntity = NSEntityDescription.insertNewObject(
            forEntityName: "Walk",
            into: context
        ) as? NSManagedObject else {
            throw PersistenceError.entityCreationFailed(entityName: "Walk")
        }
        
        // Set properties
        walkEntity.setValue(walk.id, forKey: "id")
        walkEntity.setValue(walk.walker.id, forKey: "walkerId")
        walkEntity.setValue(walk.status, forKey: "status")
        
        // Convert route to data
        let routeData = walk.route.map { location in
            [
                "latitude": location.latitude,
                "longitude": location.longitude
            ]
        }
        walkEntity.setValue(try JSONSerialization.data(withJSONObject: routeData), forKey: "route")
        
        // Set relationships
        let dogIds = walk.dogs.map { $0.id }
        walkEntity.setValue(dogIds, forKey: "dogIds")
        
        // Save context
        try coreDataStack.saveContext()
    }
    
    /// Fetches all Walk entities from the database
    /// - Returns: Array of Walk entities
    /// - Throws: PersistenceError if fetch fails
    func fetchWalks() throws -> [Walk] {
        let context = coreDataStack.viewContext
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Walk")
        
        // Execute fetch request
        let results = try context.executeFetchRequest(fetchRequest)
        
        // Convert managed objects to Walk entities
        return try results.map { managedObject in
            guard let id = managedObject.value(forKey: "id") as? String,
                  let walkerId = managedObject.value(forKey: "walkerId") as? String,
                  let status = managedObject.value(forKey: "status") as? String,
                  let routeData = managedObject.value(forKey: "route") as? Data,
                  let dogIds = managedObject.value(forKey: "dogIds") as? [String] else {
                throw PersistenceError.invalidAttributeValue(
                    attributeName: "required attributes",
                    entityName: "Walk"
                )
            }
            
            // Parse route data
            let routeArray = try JSONSerialization.jsonObject(with: routeData) as? [[String: Double]]
            let route = routeArray?.map { locationDict in
                Walk.Location(
                    latitude: locationDict["latitude"] ?? 0.0,
                    longitude: locationDict["longitude"] ?? 0.0
                )
            } ?? []
            
            // Note: In a real implementation, you would fetch the related entities
            // (walker, dogs) using their IDs. This is simplified for the example.
            return Walk(
                id: id,
                walker: User(id: walkerId, name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: .init(latitude: 0, longitude: 0)),
                dogs: [],
                booking: Booking(id: "", owner: User(id: "", name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: .init(latitude: 0, longitude: 0)), walker: User(id: "", name: "", email: "", phone: "", role: "", walks: [], payments: [], currentLocation: .init(latitude: 0, longitude: 0)), dogs: [], walk: .init(id: "", distance: 0, startTime: Date(), endTime: Date()), payment: .init(id: "", amount: 0, currency: ""), scheduledAt: Date(), status: ""),
                route: route,
                startTime: Date(),
                endTime: Date(),
                status: status
            )
        }
    }
    
    /// Updates an existing Walk entity in the database
    /// - Parameter walk: The Walk entity to update
    /// - Throws: PersistenceError if update fails
    func updateWalk(_ walk: Walk) throws {
        let context = coreDataStack.viewContext
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Walk")
        fetchRequest.predicate = NSPredicate(format: "id == %@", walk.id)
        
        // Execute fetch request
        let results = try context.executeFetchRequest(fetchRequest)
        
        guard let walkEntity = results.first else {
            throw PersistenceError.entityFetchFailed(entityName: "Walk")
        }
        
        // Update properties
        walkEntity.setValue(walk.status, forKey: "status")
        
        // Convert route to data
        let routeData = walk.route.map { location in
            [
                "latitude": location.latitude,
                "longitude": location.longitude
            ]
        }
        walkEntity.setValue(try JSONSerialization.data(withJSONObject: routeData), forKey: "route")
        
        // Update relationships
        let dogIds = walk.dogs.map { $0.id }
        walkEntity.setValue(dogIds, forKey: "dogIds")
        
        // Save context
        try coreDataStack.saveContext()
    }
    
    /// Deletes a Walk entity from the database
    /// - Parameter walkId: The ID of the Walk entity to delete
    /// - Throws: PersistenceError if deletion fails
    func deleteWalk(_ walkId: String) throws {
        let context = coreDataStack.viewContext
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Walk")
        fetchRequest.predicate = NSPredicate(format: "id == %@", walkId)
        
        // Execute fetch request
        let results = try context.executeFetchRequest(fetchRequest)
        
        guard let walkEntity = results.first else {
            throw PersistenceError.entityFetchFailed(entityName: "Walk")
        }
        
        // Delete entity
        context.delete(walkEntity)
        
        // Save context
        try coreDataStack.saveContext()
    }
}