// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper error handling is configured for walk status transitions
2. Verify walk repository is properly initialized with Core Data stack
3. Review and implement proper validation rules for walk completion
4. Configure proper notifications for walk completion events
*/

// Internal imports using relative paths
import "../../../Domain/Entities/Walk"
import "../../../Domain/Entities/User"
import "../../../Domain/Entities/Dog"
import "../../../Data/Repositories/WalkRepository"

/// EndWalkUseCase handles the business logic for ending a dog walking session
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and status updates for dog walking sessions
class EndWalkUseCase {
    
    // MARK: - Properties
    
    private let walkRepository: WalkRepository
    
    // MARK: - Initialization
    
    /// Initializes the EndWalkUseCase with required dependencies
    /// - Parameter walkRepository: Repository for managing walk persistence
    init(walkRepository: WalkRepository) {
        self.walkRepository = walkRepository
    }
    
    // MARK: - Use Case Implementation
    
    /// Ends a dog walking session by updating its status and persisting changes
    /// - Parameter walk: The walk instance to end
    /// - Throws: PersistenceError if saving the walk fails
    func endWalk(_ walk: Walk) throws {
        // Validate walk status
        guard walk.status == "in_progress" else {
            throw PersistenceError(message: "Cannot end walk that is not in progress")
        }
        
        // Set end time to current date/time
        let currentDate = Date()
        walk.endTime = currentDate
        
        // Update walk status to completed
        walk.updateStatus("completed")
        
        do {
            // Persist changes to the walk
            try walkRepository.updateWalk(walk)
        } catch {
            // If persistence fails, throw the error
            throw PersistenceError(message: "Failed to save completed walk: \(error.localizedDescription)")
        }
        
        // Note: In a real implementation, this would typically:
        // 1. Notify relevant observers of the walk completion
        // 2. Send notifications to the owner and walker
        // 3. Trigger payment processing if applicable
        // 4. Update scheduling system
        // These implementations would be handled by the appropriate use cases/services
    }
}

// MARK: - Error Extension

extension EndWalkUseCase {
    /// Custom error type for EndWalkUseCase operations
    enum Error: LocalizedError {
        case invalidWalkStatus
        case persistenceFailure(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidWalkStatus:
                return "Cannot end walk that is not in progress"
            case .persistenceFailure(let message):
                return "Failed to save completed walk: \(message)"
            }
        }
    }
}