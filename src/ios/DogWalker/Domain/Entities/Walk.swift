// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up proper data validation rules for route tracking
3. Ensure proper error handling for location tracking failures
4. Review and implement proper data retention policies for walk data compliance
*/

// MARK: - Walk Entity
/// Represents a dog walking session in the Dog Walker application
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and location-based features during dog walking sessions
class Walk {
    // MARK: - Nested Types
    /// Represents a geographic location with latitude and longitude
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
    }
    
    // MARK: - Status Constants
    private enum WalkStatus {
        static let scheduled = "scheduled"
        static let started = "started"
        static let inProgress = "in_progress"
        static let completed = "completed"
        static let cancelled = "cancelled"
        
        static let validStatuses: Set<String> = [
            scheduled, started, inProgress, completed, cancelled
        ]
    }
    
    // MARK: - Properties
    let id: String
    let walker: User
    let dogs: [Dog]
    let booking: Booking
    private(set) var route: [Location]
    let startTime: Date
    let endTime: Date
    private(set) var status: String
    
    // MARK: - Initialization
    init(
        id: String,
        walker: User,
        dogs: [Dog],
        booking: Booking,
        route: [Location],
        startTime: Date,
        endTime: Date,
        status: String
    ) {
        // Validate status
        guard WalkStatus.validStatuses.contains(status) else {
            fatalError("Invalid walk status: \(status)")
        }
        
        // Validate dates
        guard startTime <= endTime else {
            fatalError("End time must be after start time")
        }
        
        self.id = id
        self.walker = walker
        self.dogs = dogs
        self.booking = booking
        self.route = route
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
    }
    
    // MARK: - Status Management
    /// Updates the status of the walk
    /// - Parameter newStatus: The new status to update to
    func updateStatus(_ newStatus: String) {
        // Validate the new status
        guard WalkStatus.validStatuses.contains(newStatus) else {
            // Invalid status, should handle this error appropriately in production
            return
        }
        
        // Validate status transition
        guard isValidStatusTransition(from: status, to: newStatus) else {
            // Invalid transition, should handle this error appropriately in production
            return
        }
        
        // Update the status
        status = newStatus
        
        // Note: In a real implementation, this would typically:
        // 1. Notify relevant observers of the status change
        // 2. Persist the change to the backend
        // 3. Update any tracking services
        // 4. Send notifications to relevant parties
        // These implementations would be handled by the appropriate use cases/services
    }
    
    // MARK: - Route Management
    /// Adds a location to the walk's route
    /// - Parameter location: The location to add to the route
    func addLocation(_ location: Location) {
        // Validate walk status
        guard status == WalkStatus.inProgress else {
            // Walk must be in progress to add locations
            return
        }
        
        // Add the location to the route
        route.append(location)
        
        // Note: In a real implementation, this would typically:
        // 1. Notify relevant observers of the route update
        // 2. Persist the change to the backend
        // 3. Update any tracking services
        // 4. Calculate and update distance metrics
        // These implementations would be handled by the appropriate use cases/services
    }
    
    // MARK: - Helper Methods
    /// Validates if the status transition is allowed
    /// - Parameters:
    ///   - currentStatus: The current status
    ///   - newStatus: The new status to transition to
    /// - Returns: Boolean indicating if the transition is valid
    private func isValidStatusTransition(from currentStatus: String, to newStatus: String) -> Bool {
        switch (currentStatus, newStatus) {
        case (WalkStatus.scheduled, WalkStatus.started),
             (WalkStatus.scheduled, WalkStatus.cancelled),
             (WalkStatus.started, WalkStatus.inProgress),
             (WalkStatus.started, WalkStatus.cancelled),
             (WalkStatus.inProgress, WalkStatus.completed),
             (WalkStatus.inProgress, WalkStatus.cancelled):
            return true
        default:
            return false
        }
    }
}

// MARK: - Equatable Conformance
extension Walk: Equatable {
    static func == (lhs: Walk, rhs: Walk) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance
extension Walk: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible Conformance
extension Walk: CustomStringConvertible {
    var description: String {
        return "Walk(id: \(id), walker: \(walker.name), dogs: \(dogs.map { $0.name }.joined(separator: ", ")), status: \(status))"
    }
}