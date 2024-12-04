// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper keychain access for secure storage of user credentials
2. Configure location services in Info.plist with proper usage descriptions
3. Set up proper entitlements for push notifications if implementing user notifications
4. Review and implement proper data retention policies for user data compliance
*/

// MARK: - WalkSummary Entity
/// Lightweight representation of a walk to avoid circular dependencies
struct WalkSummary {
    let id: String
    let status: String
    
    init(id: String, status: String) {
        self.id = id
        self.status = status
    }
}

// MARK: - PaymentSummary Entity
/// Lightweight representation of a payment to avoid circular dependencies
struct PaymentSummary {
    let id: String
    let amount: Double
    
    init(id: String, amount: Double) {
        self.id = id
        self.amount = amount
    }
}

// MARK: - Location Entity
/// Geographic location representation with latitude and longitude
struct Location {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - User Entity
/// Represents a user in the Dog Walker application
/// Requirement: User Management (1.3 Scope/Core Features/User Management)
/// Supports user registration, profile management, and role-based access for dog owners and walkers
class User {
    // MARK: - Properties
    let id: String
    let name: String
    let email: String
    let phone: String
    let role: String
    var walks: [WalkSummary]
    var payments: [PaymentSummary]
    private(set) var currentLocation: Location
    
    // MARK: - Initialization
    init(
        id: String,
        name: String,
        email: String,
        phone: String,
        role: String,
        walks: [WalkSummary],
        payments: [PaymentSummary],
        currentLocation: Location
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.role = role
        self.walks = walks
        self.payments = payments
        self.currentLocation = currentLocation
    }
    
    // MARK: - Location Management
    /// Updates the user's current location
    /// - Parameter newLocation: The new location to update to
    func updateLocation(newLocation: Location) {
        // Validate the new location
        guard newLocation.latitude >= -90 && newLocation.latitude <= 90 &&
              newLocation.longitude >= -180 && newLocation.longitude <= 180 else {
            // Invalid coordinates, should handle this error appropriately in production
            return
        }
        
        // Update the current location
        self.currentLocation = newLocation
        
        // Note: In a real implementation, this would typically:
        // 1. Notify relevant observers of the location change
        // 2. Persist the change to the backend
        // 3. Update any location-based services
        // 4. Handle any geofencing triggers
        // These implementations would be handled by the appropriate use cases/services
    }
}

// MARK: - Equatable Conformance
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance
extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible Conformance
extension User: CustomStringConvertible {
    var description: String {
        return "User(id: \(id), name: \(name), role: \(role))"
    }
}