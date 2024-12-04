// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure error handling and monitoring service for tracking booking retrieval failures
2. Set up proper logging for booking data access patterns
3. Review and implement proper data access policies for booking information
4. Configure proper caching strategy for frequently accessed booking data
*/

/// GetBookingsUseCase: Implements the use case for retrieving bookings
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports real-time availability search, booking management, and schedule coordination
class GetBookingsUseCase {
    // MARK: - Properties
    
    /// Repository instance for accessing booking data
    private let bookingRepository: BookingRepository
    
    // MARK: - Initialization
    
    /// Initializes the GetBookingsUseCase with a BookingRepository instance
    /// - Parameter bookingRepository: The repository to use for accessing booking data
    init(bookingRepository: BookingRepository) {
        self.bookingRepository = bookingRepository
    }
    
    // MARK: - Use Case Execution
    
    /// Executes the use case to fetch bookings from the repository
    /// - Parameter completion: Completion handler with Result type containing array of Booking objects or error
    func execute(completion: @escaping (Result<[Booking], APIError>) -> Void) {
        // Fetch bookings from the repository
        bookingRepository.fetchBookings { result in
            switch result {
            case .success(let bookings):
                // Sort bookings by scheduled date (most recent first)
                let sortedBookings = bookings.sorted { $0.scheduledAt > $1.scheduledAt }
                
                // Return the sorted bookings
                completion(.success(sortedBookings))
                
            case .failure(let error):
                // Handle repository errors
                let apiError = APIError(
                    message: "Failed to fetch bookings",
                    statusCode: error.statusCode,
                    underlyingError: error
                )
                completion(.failure(apiError))
            }
        }
    }
}