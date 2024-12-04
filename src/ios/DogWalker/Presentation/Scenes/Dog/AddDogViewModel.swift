// Combine framework - Latest version
import Combine
// Foundation framework - Latest version
import Foundation

// Internal dependencies using relative paths
import "../../../Domain/UseCases/Dog/AddDogUseCase"
import "../../../Data/Repositories/DogRepository"
import "../../Common/Extensions/UIViewController+Alert"

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure AddDogUseCase is properly configured with DogRepository
2. Verify validation rules for dog profile data match business requirements
3. Configure proper error handling and user feedback mechanisms
4. Review accessibility requirements for form validation feedback
*/

/// ViewModel for handling the addition of new dogs to the system
/// Requirement: Dog Profile Management (1.3 Scope/Core Features/User Management)
/// Supports the creation of dog profiles with details like breed, age, and special needs
public class AddDogViewModel {
    
    // MARK: - Properties
    
    private let addDogUseCase: AddDogUseCase
    
    /// Published property for error message display
    @Published public var errorMessage: String?
    
    /// Published property for loading state
    @Published public var isLoading: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes the AddDogViewModel with required dependencies
    /// - Parameter addDogUseCase: The use case for adding dogs to the system
    public init(addDogUseCase: AddDogUseCase) {
        self.addDogUseCase = addDogUseCase
    }
    
    // MARK: - Public Methods
    
    /// Handles the addition of a new dog to the system
    /// - Parameters:
    ///   - name: The name of the dog
    ///   - breed: The breed of the dog
    ///   - age: The age of the dog in years
    ///   - ownerId: The ID of the dog's owner
    public func addDog(name: String, breed: String, age: Int, ownerId: String) {
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Validate input fields
        do {
            try validateInput(name: name, breed: breed, age: age, ownerId: ownerId)
            
            // Create Dog instance
            let dog = Dog(
                id: UUID().uuidString,
                name: name,
                breed: breed,
                age: age,
                ownerId: ownerId
            )
            
            // Execute add dog use case
            try addDogUseCase.execute(dog: dog)
            
            // Reset loading state on success
            isLoading = false
            
            // Log successful dog addition
            Logger.info("Successfully added dog: \(dog.name)")
            
        } catch let error as ValidationError {
            handleError(error)
        } catch let error as PersistenceError {
            handleError(error)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Methods
    
    /// Validates the input fields for adding a new dog
    /// - Parameters:
    ///   - name: The name of the dog
    ///   - breed: The breed of the dog
    ///   - age: The age of the dog
    ///   - ownerId: The ID of the dog's owner
    /// - Throws: ValidationError if any field is invalid
    private func validateInput(name: String, breed: String, age: Int, ownerId: String) throws {
        // Validate name
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidField(name: "name", message: "Dog name cannot be empty")
        }
        
        // Validate breed
        guard !breed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidField(name: "breed", message: "Dog breed cannot be empty")
        }
        
        // Validate age
        guard age >= 0 && age <= 30 else {
            throw ValidationError.invalidField(name: "age", message: "Dog age must be between 0 and 30 years")
        }
        
        // Validate owner ID
        guard !ownerId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidField(name: "ownerId", message: "Owner ID cannot be empty")
        }
    }
    
    /// Handles errors that occur during dog addition
    /// - Parameter error: The error to handle
    private func handleError(_ error: Error) {
        isLoading = false
        
        // Set appropriate error message based on error type
        if let validationError = error as? ValidationError {
            errorMessage = validationError.errorDescription
        } else if let persistenceError = error as? PersistenceError {
            errorMessage = "Failed to save dog: \(persistenceError.localizedDescription)"
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        // Log the error
        Logger.error("Error adding dog: \(error.localizedDescription)")
    }
}