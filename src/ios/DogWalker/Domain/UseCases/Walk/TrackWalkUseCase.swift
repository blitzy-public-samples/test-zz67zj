// CoreLocation framework - Latest version
import CoreLocation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper error handling for location tracking failures
3. Review and implement proper data retention policies for location data compliance
4. Configure network security settings for location data transmission
*/

// Internal imports using relative paths
import "../../../Domain/Entities/Walk"
import "../../../Domain/Entities/Location"
import "../../../Data/Repositories/WalkRepository"
import "../../../Data/Repositories/LocationRepository"

/// TrackWalkUseCase: Responsible for tracking real-time location during walks
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class TrackWalkUseCase {
    
    // MARK: - Properties
    
    private let walkRepository: WalkRepository
    private let locationRepository: LocationRepository
    
    // MARK: - Initialization
    
    /// Initializes the TrackWalkUseCase with required repositories
    /// - Parameters:
    ///   - walkRepository: Repository for managing walk data
    ///   - locationRepository: Repository for managing location data
    init(walkRepository: WalkRepository, locationRepository: LocationRepository) {
        self.walkRepository = walkRepository
        self.locationRepository = locationRepository
    }
    
    // MARK: - Public Methods
    
    /// Tracks the real-time location of a walk and updates the route
    /// - Parameters:
    ///   - walkId: The ID of the walk being tracked
    ///   - latitude: The current latitude coordinate
    ///   - longitude: The current longitude coordinate
    func trackLocation(walkId: String, latitude: Double, longitude: Double) {
        Logger.info("Tracking location for walk \(walkId): lat=\(latitude), lon=\(longitude)")
        
        // Create location instance
        let location = Location(latitude: latitude, longitude: longitude)
        
        // Save location to repository
        Task {
            do {
                // Save location data
                let locationSaved = await locationRepository.updateLocation(location)
                guard locationSaved else {
                    Logger.error("Failed to save location for walk \(walkId)")
                    return
                }
                
                // Fetch current walk
                if let walk = try await walkRepository.fetchWalks().first(where: { $0.id == walkId }) {
                    // Add location to walk route
                    walk.addLocation(Walk.Location(latitude: latitude, longitude: longitude))
                    
                    // Save updated walk
                    try await walkRepository.updateWalk(walk)
                    Logger.info("Successfully updated walk \(walkId) with new location")
                } else {
                    Logger.error("Failed to fetch walk with ID \(walkId)")
                }
            } catch {
                Logger.error("Error tracking location: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Error Handling Extension

extension TrackWalkUseCase {
    /// Custom error types for location tracking operations
    enum TrackingError: LocalizedError {
        case invalidWalkId
        case invalidCoordinates
        case locationSaveFailed
        case walkUpdateFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidWalkId:
                return "Invalid walk ID provided"
            case .invalidCoordinates:
                return "Invalid location coordinates provided"
            case .locationSaveFailed:
                return "Failed to save location data"
            case .walkUpdateFailed:
                return "Failed to update walk with new location"
            }
        }
    }
}