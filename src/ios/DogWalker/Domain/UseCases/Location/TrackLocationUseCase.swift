// CoreLocation framework - Latest
import CoreLocation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper error handling for location tracking failures
3. Review and implement proper data retention policies for location data
4. Configure network security settings for location data transmission
*/

/// TrackLocationUseCase: Implements real-time location tracking during dog walks
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class TrackLocationUseCase {
    
    // MARK: - Properties
    
    /// Repository for persisting location data
    private let locationRepository: LocationRepository
    
    // MARK: - Initialization
    
    /// Initializes the use case with a location repository
    /// - Parameter locationRepository: Repository for managing location data
    init(locationRepository: LocationRepository = LocationRepository()) {
        self.locationRepository = locationRepository
    }
    
    // MARK: - Location Tracking
    
    /// Tracks the user's location in real-time and saves it to the repository
    /// - Parameters:
    ///   - latitude: The latitude coordinate of the current location
    ///   - longitude: The longitude coordinate of the current location
    func trackLocation(latitude: Double, longitude: Double) {
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 &&
              longitude >= -180 && longitude <= 180 else {
            Logger.error("Invalid coordinates provided: lat=\(latitude), lon=\(longitude)")
            return
        }
        
        // Create location entity
        let location = Location(latitude: latitude, longitude: longitude)
        
        // Log tracking event
        Logger.info("Tracking location: \(location)")
        
        // Save location to repository
        Task {
            do {
                let success = await locationRepository.updateLocation(location)
                if success {
                    Logger.info("Successfully saved location")
                } else {
                    Logger.error("Failed to save location")
                }
            } catch {
                Logger.error("Error saving location: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Error Handling Extension

extension TrackLocationUseCase {
    /// Custom error types for location tracking operations
    enum TrackingError: LocalizedError {
        case invalidCoordinates
        case saveFailed
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .invalidCoordinates:
                return "Invalid location coordinates provided"
            case .saveFailed:
                return "Failed to save location data"
            case .unknown:
                return "An unknown error occurred during location tracking"
            }
        }
    }
}