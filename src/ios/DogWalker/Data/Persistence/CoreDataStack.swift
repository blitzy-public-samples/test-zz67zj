//
// CoreDataStack.swift
// DogWalker
//

// Human Tasks:
// 1. Verify Core Data model file (.xcdatamodeld) is properly configured in Xcode project
// 2. Ensure proper data migration strategy is in place before deploying model changes
// 3. Configure proper error logging and monitoring for Core Data operations
// 4. Review Core Data concurrency settings based on application performance requirements

// CoreData framework - Latest version
import CoreData

// Internal dependencies using relative paths
import "../PersistenceError"
import "../../Domain/Entities/User"

/// CoreDataStack manages the Core Data persistence stack for the Dog Walker application
/// Requirement: Data Management (Technical Specification/8.2 Database Design/8.2.2 Data Management Strategy)
/// Ensures efficient and reliable data storage and retrieval using Core Data for local persistence
public class CoreDataStack {
    
    // MARK: - Properties
    
    /// The persistent container for the application
    public let persistentContainer: NSPersistentContainer
    
    /// The main view context for the application
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Singleton Instance
    
    /// Shared instance of the CoreDataStack
    public static let shared = CoreDataStack()
    
    // MARK: - Initialization
    
    /// Initializes the CoreDataStack with the application's persistent container
    private init() {
        // Initialize the persistent container with the application name
        persistentContainer = NSPersistentContainer(name: "DogWalker")
        
        // Configure the persistent store description
        if let description = persistentContainer.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
        
        // Load the persistent stores
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle any errors during store loading
                fatalError("Failed to load persistent stores: \(PersistenceError.saveContextFailed(underlyingError: error).debugDescription)")
            }
        }
        
        // Configure the view context
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Context Management
    
    /// Creates a new background context for performing operations
    /// - Returns: A new background context
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    /// Performs a block operation on a background context
    /// - Parameter block: The block to execute with the background context
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Context Saving
    
    /// Saves changes in the managed object context to the persistent store
    /// - Throws: PersistenceError if the save operation fails
    public func saveContext() throws {
        let context = persistentContainer.viewContext
        
        // Check if there are any changes to save
        guard context.hasChanges else { return }
        
        do {
            // Attempt to save the context
            try context.save()
        } catch {
            // Handle any errors during save operation
            throw PersistenceError.saveContextFailed(underlyingError: error)
        }
    }
    
    /// Saves a background context
    /// - Parameter context: The background context to save
    /// - Throws: PersistenceError if the save operation fails
    public func saveBackgroundContext(_ context: NSManagedObjectContext) throws {
        // Check if there are any changes to save
        guard context.hasChanges else { return }
        
        do {
            // Attempt to save the context
            try context.save()
        } catch {
            // Handle any errors during save operation
            throw PersistenceError.saveContextFailed(underlyingError: error)
        }
    }
    
    // MARK: - Store Management
    
    /// Resets the entire Core Data stack
    /// - Throws: PersistenceError if the reset operation fails
    public func resetStore() throws {
        // Get the persistent store coordinator
        let coordinator = persistentContainer.persistentStoreCoordinator
        
        // Get all persistent stores
        let stores = coordinator.persistentStores
        
        for store in stores {
            do {
                // Remove each persistent store
                try coordinator.remove(store)
                
                // Delete the store file if it exists
                if let storeURL = store.url {
                    try FileManager.default.removeItem(at: storeURL)
                }
            } catch {
                throw PersistenceError(message: "Failed to reset store: \(error.localizedDescription)")
            }
        }
        
        // Reload the persistent stores
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to reload persistent stores: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Context Extensions

extension NSManagedObjectContext {
    /// Executes a fetch request and handles errors
    /// - Parameter request: The fetch request to execute
    /// - Returns: The fetch results
    /// - Throws: PersistenceError if the fetch operation fails
    func executeFetchRequest<T>(_ request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try fetch(request)
        } catch {
            throw PersistenceError.entityFetchFailed(entityName: String(describing: T.self))
        }
    }
}