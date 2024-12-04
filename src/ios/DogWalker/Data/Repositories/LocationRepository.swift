// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper error handling for location tracking failures
3. Review and implement proper data retention policies for location data compliance
4. Configure network security settings for location data transmission
*/

/// LocationRepository: Handles data operations related to location data
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class LocationRepository {
    
    // MARK: - Properties
    
    /// APIClient instance for making network requests
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    /// Initializes the LocationRepository with an APIClient instance
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    /// Fetches the current location of the user from the API
    /// - Returns: Optional Location object containing the current location data
    func fetchCurrentLocation() async -> Location? {
        Logger.info("Fetching current location")
        
        // Construct API endpoint
        let endpoint = "/api/v1/location/current"
        
        return await withCheckedContinuation { continuation in
            apiClient.performRequest(endpoint: endpoint) { result in
                switch result {
                case .success(let data):
                    do {
                        // Parse location data from response
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let latitude = json["latitude"] as? Double,
                           let longitude = json["longitude"] as? Double {
                            
                            // Create Location instance
                            let location = Location(latitude: latitude, longitude: longitude)
                            Logger.info("Successfully fetched location: \(location)")
                            continuation.resume(returning: location)
                        } else {
                            Logger.error("Failed to parse location data")
                            continuation.resume(returning: nil)
                        }
                    } catch {
                        Logger.error("Error parsing location data: \(error.localizedDescription)")
                        continuation.resume(returning: nil)
                    }
                    
                case .failure(let error):
                    Logger.error("Failed to fetch location: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    /// Updates the user's current location on the server
    /// - Parameter location: The Location object containing the new location data
    /// - Returns: Boolean indicating whether the update was successful
    func updateLocation(_ location: Location) async -> Bool {
        Logger.info("Updating location to: \(location)")
        
        // Construct API endpoint
        let endpoint = "/api/v1/location/update"
        
        // Prepare location data for API request
        let parameters: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "timestamp": DateFormatter.stringFromDate(Date())
        ]
        
        return await withCheckedContinuation { continuation in
            apiClient.performRequest(endpoint: endpoint, parameters: parameters) { result in
                switch result {
                case .success(_):
                    Logger.info("Successfully updated location")
                    continuation.resume(returning: true)
                    
                case .failure(let error):
                    Logger.error("Failed to update location: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
}

// MARK: - Error Handling Extension

extension LocationRepository {
    /// Custom error types for location operations
    enum LocationError: Error {
        case invalidCoordinates
        case networkError
        case parsingError
        case unknownError
        
        var localizedDescription: String {
            switch self {
            case .invalidCoordinates:
                return "Invalid location coordinates provided"
            case .networkError:
                return "Failed to communicate with the server"
            case .parsingError:
                return "Failed to parse location data"
            case .unknownError:
                return "An unknown error occurred"
            }
        }
    }
}