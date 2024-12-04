// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Review and implement proper data retention policies for location data compliance
3. Ensure proper error handling for invalid coordinate scenarios
*/

// MARK: - Location Entity
/// Represents a geographic location with latitude and longitude
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class Location {
    // MARK: - Properties
    let latitude: Double
    let longitude: Double
    
    // MARK: - Initialization
    init(latitude: Double, longitude: Double) {
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 &&
              longitude >= -180 && longitude <= 180 else {
            fatalError("Invalid coordinates: lat=\(latitude), lon=\(longitude)")
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: - Distance Calculation
    /// Calculates the distance to another location using the Haversine formula
    /// - Parameter otherLocation: The location to calculate the distance to
    /// - Returns: The distance in meters between the two locations
    func distanceTo(otherLocation: Location) -> Double {
        let earthRadius = 6371000.0 // Earth's radius in meters
        
        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180
        let lat2 = otherLocation.latitude * .pi / 180
        let lon2 = otherLocation.longitude * .pi / 180
        
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1) * cos(lat2) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
}

// MARK: - Equatable Conformance
extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Hashable Conformance
extension Location: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

// MARK: - CustomStringConvertible Conformance
extension Location: CustomStringConvertible {
    var description: String {
        return "Location(latitude: \(latitude), longitude: \(longitude))"
    }
}