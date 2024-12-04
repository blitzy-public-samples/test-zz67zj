// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper error handling for location tracking failures
3. Review and implement proper data retention policies for walk data compliance
4. Ensure proper access control for walk initiation
*/

// Internal imports using relative paths
import "../../../Domain/Entities/Walk"
import "../../../Domain/Entities/User"
import "../../../Domain/Entities/Location"
import "../../../Data/Repositories/WalkRepository"
import "../../../Data/Repositories/LocationRepository"

/// StartWalkUseCase: Responsible for initiating a new dog walking session
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class StartWalkUseCase {
    
    // MARK: - Properties
    
    private let walkRepository: WalkRepository
    private let locationRepository: LocationRepository
    
    // MARK: - Initialization
    
    /// Initializes the StartWalkUseCase with required repositories
    /// - Parameters:
    ///   - walkRepository: Repository for managing Walk entities
    ///   - locationRepository: Repository for managing Location entities
    init(walkRepository: WalkRepository, locationRepository: LocationRepository) {
        self.walkRepository = walkRepository
        self.locationRepository = locationRepository
    }
    
    // MARK: - Public Methods
    
    /// Initiates a new walk session
    /// - Parameters:
    ///   - walker: The user who will conduct the walk
    ///   - dogs: Array of dogs participating in the walk
    ///   - startLocation: The starting location of the walk
    /// - Returns: The newly created Walk entity
    /// - Throws: Error if walk creation fails
    func startWalk(walker: User, dogs: [Dog], startLocation: Location) throws -> Walk {
        // Generate a unique ID for the walk
        let walkId = UUID().uuidString
        
        // Get current date/time for start time
        let startTime = Date()
        
        // Create the walk entity with initial status
        let walk = Walk(
            id: walkId,
            walker: walker,
            dogs: dogs,
            booking: Booking(
                id: UUID().uuidString,
                owner: User(
                    id: "",
                    name: "",
                    email: "",
                    phone: "",
                    role: "",
                    walks: [],
                    payments: [],
                    currentLocation: Location(latitude: 0, longitude: 0)
                ),
                walker: walker,
                dogs: dogs,
                walk: WalkSummary(
                    id: walkId,
                    distance: 0,
                    startTime: startTime,
                    endTime: startTime.addingTimeInterval(3600)
                ),
                payment: PaymentSummary(
                    id: UUID().uuidString,
                    amount: 0,
                    currency: "USD"
                ),
                scheduledAt: startTime,
                status: "in_progress"
            ),
            route: [startLocation],
            startTime: startTime,
            endTime: startTime.addingTimeInterval(3600),
            status: "in_progress"
        )
        
        do {
            // Save the walk entity
            try walkRepository.createWalk(walk)
            
            // Save the starting location
            _ = try await locationRepository.updateLocation(startLocation)
            
            Logger.info("Successfully started walk with ID: \(walkId)")
            
            return walk
        } catch {
            Logger.error("Failed to start walk: \(error.localizedDescription)")
            throw error
        }
    }
}