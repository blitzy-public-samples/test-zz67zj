// Foundation framework - Latest
import Foundation
import CoreData

/// UserRepository: Manages user data persistence and retrieval
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user registration and profile management
/// - Data Management (Technical Specification/8.2 Database Design/8.2.2 Data Management Strategy): Implements Core Data persistence
class UserRepository {
    // MARK: - Human Tasks
    /*
    1. Ensure proper Core Data model configuration in Xcode project
    2. Configure error tracking service for monitoring data operations
    3. Review and implement proper data retention policies
    4. Set up proper error logging for failed operations
    */
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    /// Initializes the UserRepository with required dependencies
    /// - Parameters:
    ///   - apiClient: The API client for network requests
    ///   - coreDataStack: The Core Data stack for local persistence
    init(apiClient: APIClient, coreDataStack: CoreDataStack) {
        self.apiClient = apiClient
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - User Operations
    
    /// Fetches a user by their unique identifier
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: Optional User object if found
    func fetchUserById(_ userId: String) async throws -> User? {
        // First, try to fetch from local database
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            if let userEntity = try coreDataStack.viewContext.fetch(fetchRequest).first {
                // Convert Core Data entity to User domain model
                return User(
                    id: userEntity.value(forKey: "id") as! String,
                    name: userEntity.value(forKey: "name") as! String,
                    email: userEntity.value(forKey: "email") as! String,
                    phone: userEntity.value(forKey: "phone") as! String,
                    role: userEntity.value(forKey: "role") as! String,
                    walks: [], // Fetch walks if needed
                    payments: [], // Fetch payments if needed
                    currentLocation: Location(latitude: 0, longitude: 0) // Fetch location if needed
                )
            }
        } catch {
            throw PersistenceError.entityFetchFailed(entityName: "User")
        }
        
        // If not found locally, fetch from API
        return try await fetchUserFromAPI(userId)
    }
    
    /// Saves or updates a user in the local database
    /// - Parameter user: The user object to save
    func saveUser(_ user: User) throws {
        let context = coreDataStack.viewContext
        
        // Check if user already exists
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            let userEntity: NSManagedObject
            
            if let existingUser = existingUsers.first {
                // Update existing user
                userEntity = existingUser
            } else {
                // Create new user
                guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
                    throw PersistenceError.entityCreationFailed(entityName: "User")
                }
                userEntity = NSManagedObject(entity: entity, insertInto: context)
            }
            
            // Update user properties
            userEntity.setValue(user.id, forKey: "id")
            userEntity.setValue(user.name, forKey: "name")
            userEntity.setValue(user.email, forKey: "email")
            userEntity.setValue(user.phone, forKey: "phone")
            userEntity.setValue(user.role, forKey: "role")
            
            // Save the context
            try coreDataStack.saveContext()
            
        } catch {
            throw PersistenceError.saveContextFailed(underlyingError: error)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Fetches a user from the remote API
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: Optional User object if found
    private func fetchUserFromAPI(_ userId: String) async throws -> User? {
        return try await withCheckedThrowingContinuation { continuation in
            apiClient.performRequest(
                endpoint: "/api/v1/users/\(userId)",
                parameters: nil
            ) { result in
                switch result {
                case .success(let data):
                    do {
                        // Parse user data
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let id = json["id"] as? String,
                           let name = json["name"] as? String,
                           let email = json["email"] as? String,
                           let phone = json["phone"] as? String,
                           let role = json["role"] as? String {
                            
                            // Create user object
                            let user = User(
                                id: id,
                                name: name,
                                email: email,
                                phone: phone,
                                role: role,
                                walks: [], // Parse walks if included in response
                                payments: [], // Parse payments if included in response
                                currentLocation: Location(latitude: 0, longitude: 0) // Parse location if included
                            )
                            
                            // Save user to local database
                            try self.saveUser(user)
                            
                            continuation.resume(returning: user)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}