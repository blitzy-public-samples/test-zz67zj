// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper error handling and logging configuration is set up
2. Review booking validation rules and constraints
3. Configure proper access control for booking creation
4. Set up monitoring for booking creation performance
*/

/// CreateBookingUseCase: Implements the business logic for creating a new booking
/// Requirement: Booking System (1.3 Scope/Core Features/Booking System)
/// Supports real-time availability search, booking management, and schedule coordination
class CreateBookingUseCase {
    
    // MARK: - Properties
    
    private let bookingRepository: BookingRepository
    
    // MARK: - Initialization
    
    /// Initializes the use case with required dependencies
    /// - Parameter bookingRepository: Repository for managing booking data
    init(bookingRepository: BookingRepository) {
        self.bookingRepository = bookingRepository
    }
    
    // MARK: - Public Methods
    
    /// Executes the use case to create a new booking
    /// - Parameter booking: The booking to be created
    /// - Parameter completion: Completion handler with Result type containing optional error
    func execute(booking: Booking, completion: @escaping (Result<Void, APIError>) -> Void) {
        // Log the start of booking creation
        Logger.info("Starting booking creation process for booking ID: \(booking.id)")
        
        // Validate booking details
        guard validateBooking(booking) else {
            Logger.error("Booking validation failed for booking ID: \(booking.id)")
            let error = APIError(
                message: "Invalid booking details",
                statusCode: nil,
                underlyingError: nil
            )
            completion(.failure(error))
            return
        }
        
        // Create the booking through repository
        bookingRepository.createBooking(booking: booking) { result in
            switch result {
            case .success:
                Logger.info("Successfully created booking with ID: \(booking.id)")
                completion(.success(()))
                
            case .failure(let error):
                Logger.error("Failed to create booking with ID: \(booking.id). Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Validates the booking details before creation
    /// - Parameter booking: The booking to validate
    /// - Returns: Boolean indicating if the booking is valid
    private func validateBooking(_ booking: Booking) -> Bool {
        // Validate booking ID
        guard !booking.id.isEmpty else {
            Logger.warning("Invalid booking ID: empty string")
            return false
        }
        
        // Validate owner
        guard booking.owner.id.count > 0 else {
            Logger.warning("Invalid owner ID for booking: \(booking.id)")
            return false
        }
        
        // Validate walker
        guard booking.walker.id.count > 0 else {
            Logger.warning("Invalid walker ID for booking: \(booking.id)")
            return false
        }
        
        // Validate dogs array
        guard !booking.dogs.isEmpty else {
            Logger.warning("No dogs specified for booking: \(booking.id)")
            return false
        }
        
        // Validate scheduled date
        guard booking.scheduledAt > Date() else {
            Logger.warning("Invalid scheduled date for booking: \(booking.id)")
            return false
        }
        
        // Validate status
        guard !booking.status.isEmpty else {
            Logger.warning("Invalid status for booking: \(booking.id)")
            return false
        }
        
        return true
    }
}