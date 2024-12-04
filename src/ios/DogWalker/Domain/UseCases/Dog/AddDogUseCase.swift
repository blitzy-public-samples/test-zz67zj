// Foundation framework - Latest version
import Foundation

// Internal dependencies using relative paths
import "../../../Domain/Entities/Dog"
import "../../../Data/Repositories/DogRepository"

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure DogRepository is properly configured with CoreDataStack
2. Verify validation rules for dog profile data are properly defined
3. Configure error monitoring for dog creation operations
4. Review data retention policies for dog profile information
*/

/// AddDogUseCase handles the business logic for adding a new dog to the system
/// Requirement: Dog Profile Management (1.3 Scope/Core Features/User Management)
/// Supports the creation of dog profiles with details like breed, age, and special needs
public class AddDogUseCase {
    
    // MARK: - Properties
    
    private let dogRepository: DogRepository
    
    // MARK: - Initialization
    
    /// Initializes the AddDogUseCase with a DogRepository instance
    /// - Parameter dogRepository: The repository to use for dog persistence
    public init(dogRepository: DogRepository) {
        self.dogRepository = dogRepository
    }
    
    // MARK: - Execution
    
    /// Executes the use case to add a new dog to the system
    /// - Parameter dog: The Dog instance to add
    /// - Throws: PersistenceError if the operation fails
    public func execute(dog: Dog) throws {
        // Validate required fields
        try validateDog(dog)
        
        // Persist the dog using the repository
        try dogRepository.addDog(dog)
    }
    
    // MARK: - Private Helpers
    
    /// Validates the Dog instance to ensure all required fields are properly set
    /// - Parameter dog: The Dog instance to validate
    /// - Throws: ValidationError if any required field is invalid
    private func validateDog(_ dog: Dog) throws {
        // Validate ID
        guard !dog.id.isEmpty else {
            throw ValidationError.invalidField(name: "id", message: "Dog ID cannot be empty")
        }
        
        // Validate name
        guard !dog.name.isEmpty else {
            throw ValidationError.invalidField(name: "name", message: "Dog name cannot be empty")
        }
        
        // Validate breed
        guard !dog.breed.isEmpty else {
            throw ValidationError.invalidField(name: "breed", message: "Dog breed cannot be empty")
        }
        
        // Validate age
        guard dog.age >= 0 && dog.age <= 30 else {
            throw ValidationError.invalidField(name: "age", message: "Dog age must be between 0 and 30 years")
        }
        
        // Validate owner ID
        guard !dog.ownerId.isEmpty else {
            throw ValidationError.invalidField(name: "ownerId", message: "Owner ID cannot be empty")
        }
    }
}

// MARK: - ValidationError

/// Represents validation errors that can occur during dog profile creation
enum ValidationError: LocalizedError {
    case invalidField(name: String, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidField(let name, let message):
            return "Invalid field '\(name)': \(message)"
        }
    }
}