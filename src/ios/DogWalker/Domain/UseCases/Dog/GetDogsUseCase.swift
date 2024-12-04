// Foundation framework - Latest version
import Foundation

// Internal dependencies using relative paths
import "../../../Data/Repositories/DogRepository"
import "../../Entities/Dog"

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure DogRepository is properly configured with CoreDataStack
2. Review error handling strategy for repository fetch failures
3. Configure proper logging for use case execution monitoring
4. Set up performance monitoring for fetch operations
*/

/// GetDogsUseCase provides the business logic to retrieve a list of dogs associated with a user
/// Requirement: Dog Profile Management (1.3 Scope/Core Features/User Management)
/// Supports the retrieval of dog profiles, including details like breed, age, and special needs
public class GetDogsUseCase {
    
    // MARK: - Properties
    
    private let dogRepository: DogRepository
    
    // MARK: - Initialization
    
    /// Initializes the GetDogsUseCase with a DogRepository instance
    /// - Parameter dogRepository: The repository to use for fetching dogs
    public init(dogRepository: DogRepository) {
        self.dogRepository = dogRepository
    }
    
    // MARK: - Use Case Execution
    
    /// Retrieves a list of dogs from the repository
    /// - Returns: An array of Dog entities
    /// - Throws: Any error that occurs during the fetch operation
    public func getDogs() throws -> [Dog] {
        do {
            // Fetch all dogs from the repository
            let dogs = try dogRepository.fetchAllDogs()
            
            // Note: In a real implementation, this would typically:
            // 1. Apply any business rules or filtering
            // 2. Sort the results based on business requirements
            // 3. Transform the data if needed
            // 4. Validate the results before returning
            
            return dogs
        } catch {
            // Propagate the error to the caller
            // The presentation layer should handle error presentation
            throw error
        }
    }
}