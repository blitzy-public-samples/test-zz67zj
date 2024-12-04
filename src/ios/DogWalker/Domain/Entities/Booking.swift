// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Review and implement proper data retention policies for booking data compliance
2. Set up proper validation rules for booking status transitions
3. Configure proper access control for booking modifications
4. Ensure proper error handling for invalid booking scenarios
5. Set up proper notification handling for booking status changes
*/

// MARK: - WalkSummary Entity
/// A lightweight representation of a walk to avoid circular dependencies
struct WalkSummary {
    let id: String
    let distance: Double
    let startTime: Date
    let endTime: Date
    
    init(id: String, distance: Double, startTime: Date, endTime: Date) {
        self.id = id
        self.distance = distance
        self.startTime = startTime
        self.endTime = endTime
    }
}

// MARK: - PaymentSummary Entity
/// A lightweight representation of a payment to avoid circular dependencies
struct PaymentSummary {
    let id: String
    let amount: Double
    let currency: String
    
    init(id: String, amount: Double, currency: String) {
        self.id = id
        self.amount = amount
        self.currency = currency
    }
}

// MARK: - Booking Entity
/// Represents a booking in the Dog Walker application
/// Requirement: Booking System (1.3 Scope/Core Features/Booking System)
/// Supports real-time availability search, booking management, and schedule coordination
class Booking {
    // MARK: - Properties
    let id: String
    let owner: User
    let walker: User
    let dogs: [Dog]
    let walk: WalkSummary
    let payment: PaymentSummary
    let scheduledAt: Date
    private(set) var status: String
    
    // MARK: - Status Constants
    private enum BookingStatus {
        static let pending = "pending"
        static let confirmed = "confirmed"
        static let inProgress = "in_progress"
        static let completed = "completed"
        static let cancelled = "cancelled"
        
        static let validStatuses: Set<String> = [
            pending, confirmed, inProgress, completed, cancelled
        ]
    }
    
    // MARK: - Initialization
    init(
        id: String,
        owner: User,
        walker: User,
        dogs: [Dog],
        walk: WalkSummary,
        payment: PaymentSummary,
        scheduledAt: Date,
        status: String
    ) {
        // Validate status
        guard BookingStatus.validStatuses.contains(status) else {
            fatalError("Invalid booking status: \(status)")
        }
        
        self.id = id
        self.owner = owner
        self.walker = walker
        self.dogs = dogs
        self.walk = walk
        self.payment = payment
        self.scheduledAt = scheduledAt
        self.status = status
    }
    
    // MARK: - Status Management
    /// Updates the status of the booking
    /// - Parameter newStatus: The new status to update to
    func updateStatus(_ newStatus: String) {
        // Validate the new status
        guard BookingStatus.validStatuses.contains(newStatus) else {
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
        // 3. Update any scheduling services
        // 4. Send notifications to relevant parties
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
        case (BookingStatus.pending, BookingStatus.confirmed),
             (BookingStatus.pending, BookingStatus.cancelled),
             (BookingStatus.confirmed, BookingStatus.inProgress),
             (BookingStatus.confirmed, BookingStatus.cancelled),
             (BookingStatus.inProgress, BookingStatus.completed):
            return true
        default:
            return false
        }
    }
}

// MARK: - Equatable Conformance
extension Booking: Equatable {
    static func == (lhs: Booking, rhs: Booking) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance
extension Booking: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible Conformance
extension Booking: CustomStringConvertible {
    var description: String {
        return "Booking(id: \(id), owner: \(owner.name), walker: \(walker.name), scheduledAt: \(scheduledAt), status: \(status))"
    }
}