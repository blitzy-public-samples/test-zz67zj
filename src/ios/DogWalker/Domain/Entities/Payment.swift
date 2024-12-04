// Foundation framework - Latest version
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Review and implement proper data retention policies for payment data compliance
2. Set up proper validation rules for payment status transitions
3. Configure proper access control for payment modifications
4. Ensure proper error handling for invalid payment scenarios
5. Set up proper notification handling for payment status changes
*/

// MARK: - Payment Entity
/// Represents a financial transaction in the Dog Walker application
/// Requirement: Payments (1.3 Scope/Core Features/Payments)
/// Supports secure payment processing, automated billing, and receipt generation
class Payment {
    // MARK: - Properties
    let id: String
    let payer: User
    let payee: User
    let amount: Double
    let currency: String
    let booking: Booking
    let walk: Walk
    let timestamp: Date
    private(set) var status: String
    
    // MARK: - Status Constants
    private enum PaymentStatus {
        static let pending = "pending"
        static let processing = "processing"
        static let completed = "completed"
        static let failed = "failed"
        static let refunded = "refunded"
        
        static let validStatuses: Set<String> = [
            pending, processing, completed, failed, refunded
        ]
    }
    
    // MARK: - Initialization
    init(
        id: String,
        payer: User,
        payee: User,
        amount: Double,
        currency: String,
        booking: Booking,
        walk: Walk,
        timestamp: Date,
        status: String
    ) {
        // Validate status
        guard PaymentStatus.validStatuses.contains(status) else {
            fatalError("Invalid payment status: \(status)")
        }
        
        // Validate amount
        guard amount > 0 else {
            fatalError("Payment amount must be greater than 0")
        }
        
        self.id = id
        self.payer = payer
        self.payee = payee
        self.amount = amount
        self.currency = currency
        self.booking = booking
        self.walk = walk
        self.timestamp = timestamp
        self.status = status
    }
    
    // MARK: - Status Management
    /// Updates the status of the payment
    /// - Parameter newStatus: The new status to update to
    func updateStatus(_ newStatus: String) {
        // Validate the new status
        guard PaymentStatus.validStatuses.contains(newStatus) else {
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
        // 3. Update any payment processing services
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
        case (PaymentStatus.pending, PaymentStatus.processing),
             (PaymentStatus.processing, PaymentStatus.completed),
             (PaymentStatus.processing, PaymentStatus.failed),
             (PaymentStatus.completed, PaymentStatus.refunded):
            return true
        default:
            return false
        }
    }
}

// MARK: - Equatable Conformance
extension Payment: Equatable {
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance
extension Payment: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible Conformance
extension Payment: CustomStringConvertible {
    var description: String {
        return "Payment(id: \(id), payer: \(payer.name), payee: \(payee.name), amount: \(amount) \(currency), status: \(status))"
    }
}