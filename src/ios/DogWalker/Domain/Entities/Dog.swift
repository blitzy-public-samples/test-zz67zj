// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Review and implement proper data retention policies for dog profile data compliance
2. Set up proper data validation rules for dog age and breed information
3. Configure proper access control for dog profile modifications
4. Ensure proper error handling for invalid data scenarios
*/

// MARK: - BookingSummary Entity
/// A lightweight representation of a booking associated with a dog
struct BookingSummary {
    let id: String
    let scheduledAt: Date
    
    init(id: String, scheduledAt: Date) {
        self.id = id
        self.scheduledAt = scheduledAt
    }
}

// MARK: - WalkSummary Entity
/// A lightweight representation of a walk to avoid circular dependencies
struct WalkSummary {
    let id: String
    let status: String
    
    init(id: String, status: String) {
        self.id = id
        self.status = status
    }
}

// MARK: - Dog Entity
/// Represents a dog in the Dog Walker application
/// Requirement: User Management (1.3 Scope/Core Features/User Management)
/// Supports dog profile management, including details and associations with owners and walks
class Dog {
    // MARK: - Properties
    let id: String
    let name: String
    let breed: String
    let age: Int
    let ownerId: String
    private(set) var bookings: [BookingSummary]
    private(set) var walks: [WalkSummary]
    
    // MARK: - Initialization
    init(
        id: String,
        name: String,
        breed: String,
        age: Int,
        ownerId: String,
        bookings: [BookingSummary] = [],
        walks: [WalkSummary] = []
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.ownerId = ownerId
        self.bookings = bookings
        self.walks = walks
    }
    
    // MARK: - Booking Management
    /// Adds a booking summary to the dog's list of bookings
    /// - Parameter booking: The booking summary to add
    func addBooking(_ booking: BookingSummary) {
        // Validate the booking
        guard !bookings.contains(where: { $0.id == booking.id }) else {
            // Booking already exists, should handle this error appropriately in production
            return
        }
        
        // Add the booking to the list
        bookings.append(booking)
        
        // Note: In a real implementation, this would typically:
        // 1. Notify relevant observers of the booking addition
        // 2. Persist the change to the backend
        // 3. Update any scheduling services
        // These implementations would be handled by the appropriate use cases/services
    }
    
    // MARK: - Walk Management
    /// Adds a walk summary to the dog's list of walks
    /// - Parameter walk: The walk summary to add
    func addWalk(_ walk: WalkSummary) {
        // Validate the walk
        guard !walks.contains(where: { $0.id == walk.id }) else {
            // Walk already exists, should handle this error appropriately in production
            return
        }
        
        // Add the walk to the list
        walks.append(walk)
        
        // Note: In a real implementation, this would typically:
        // 1. Notify relevant observers of the walk addition
        // 2. Persist the change to the backend
        // 3. Update any tracking services
        // These implementations would be handled by the appropriate use cases/services
    }
}

// MARK: - Equatable Conformance
extension Dog: Equatable {
    static func == (lhs: Dog, rhs: Dog) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance
extension Dog: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible Conformance
extension Dog: CustomStringConvertible {
    var description: String {
        return "Dog(id: \(id), name: \(name), breed: \(breed), age: \(age))"
    }
}