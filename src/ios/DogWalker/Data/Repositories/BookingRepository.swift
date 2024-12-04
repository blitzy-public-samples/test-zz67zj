// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure error tracking service for monitoring booking operations
2. Set up proper logging for booking state transitions
3. Configure proper data persistence strategy for offline booking support
4. Review and implement proper data retention policies for booking data
5. Set up proper notification handling for booking status changes
*/

/// BookingRepository: Handles data operations related to bookings
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports real-time availability search, booking management, and schedule coordination
class BookingRepository {
    // MARK: - Properties
    
    /// APIClient instance for making network requests
    private let apiClient: APIClient
    
    // MARK: - Constants
    
    private enum Endpoints {
        static let createBooking = "/api/v1/bookings"
        static let fetchBookings = "/api/v1/bookings"
    }
    
    // MARK: - Initialization
    
    /// Initializes the BookingRepository with an APIClient instance
    /// - Parameter apiClient: The APIClient instance to use for network requests
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Booking Operations
    
    /// Creates a new booking by sending the booking details to the backend API
    /// - Parameter booking: The booking to create
    /// - Parameter completion: Completion handler with Result type containing optional error
    func createBooking(booking: Booking, completion: @escaping (Result<Void, APIError>) -> Void) {
        // Construct booking parameters
        let parameters: [String: Any] = [
            "id": booking.id,
            "owner_id": booking.owner.id,
            "walker_id": booking.walker.id,
            "dog_ids": booking.dogs.map { $0.id },
            "scheduled_at": ISO8601DateFormatter().string(from: booking.scheduledAt),
            "status": booking.status
        ]
        
        // Make API request
        apiClient.performRequest(
            endpoint: Endpoints.createBooking,
            parameters: parameters
        ) { result in
            switch result {
            case .success(_):
                // Booking created successfully
                completion(.success(()))
                
            case .failure(let error):
                // Handle API error
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches a list of bookings from the backend API
    /// - Parameter completion: Completion handler with Result type containing array of Booking objects or error
    func fetchBookings(completion: @escaping (Result<[Booking], APIError>) -> Void) {
        // Make API request
        apiClient.performRequest(
            endpoint: Endpoints.fetchBookings
        ) { result in
            switch result {
            case .success(let data):
                do {
                    // Parse response data
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                        let error = APIError(
                            message: "Invalid response format",
                            statusCode: nil,
                            underlyingError: nil
                        )
                        completion(.failure(error))
                        return
                    }
                    
                    // Map JSON to Booking objects
                    let bookings = try json.map { bookingData -> Booking in
                        // Extract booking data
                        guard
                            let id = bookingData["id"] as? String,
                            let ownerData = bookingData["owner"] as? [String: Any],
                            let walkerData = bookingData["walker"] as? [String: Any],
                            let dogsData = bookingData["dogs"] as? [[String: Any]],
                            let scheduledAtString = bookingData["scheduled_at"] as? String,
                            let status = bookingData["status"] as? String,
                            let scheduledAt = ISO8601DateFormatter().date(from: scheduledAtString)
                        else {
                            throw APIError(
                                message: "Missing or invalid booking data",
                                statusCode: nil,
                                underlyingError: nil
                            )
                        }
                        
                        // Create User objects
                        let owner = try self.createUser(from: ownerData)
                        let walker = try self.createUser(from: walkerData)
                        
                        // Create Dog objects
                        let dogs = try dogsData.map { try self.createDog(from: $0) }
                        
                        // Create dummy walk and payment summaries for the Booking
                        let walk = WalkSummary(id: UUID().uuidString, distance: 0, startTime: Date(), endTime: Date())
                        let payment = PaymentSummary(id: UUID().uuidString, amount: 0, currency: "USD")
                        
                        // Create and return Booking object
                        return Booking(
                            id: id,
                            owner: owner,
                            walker: walker,
                            dogs: dogs,
                            walk: walk,
                            payment: payment,
                            scheduledAt: scheduledAt,
                            status: status
                        )
                    }
                    
                    completion(.success(bookings))
                    
                } catch {
                    let apiError = APIError(
                        message: "Failed to parse bookings",
                        statusCode: nil,
                        underlyingError: error
                    )
                    completion(.failure(apiError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a User object from JSON data
    /// - Parameter userData: Dictionary containing user data
    /// - Returns: A User object
    private func createUser(from userData: [String: Any]) throws -> User {
        guard
            let id = userData["id"] as? String,
            let name = userData["name"] as? String,
            let email = userData["email"] as? String,
            let phone = userData["phone"] as? String,
            let role = userData["role"] as? String
        else {
            throw APIError(
                message: "Missing or invalid user data",
                statusCode: nil,
                underlyingError: nil
            )
        }
        
        // Create dummy location for the User
        let location = Location(latitude: 0, longitude: 0)
        
        return User(
            id: id,
            name: name,
            email: email,
            phone: phone,
            role: role,
            walks: [],
            payments: [],
            currentLocation: location
        )
    }
    
    /// Creates a Dog object from JSON data
    /// - Parameter dogData: Dictionary containing dog data
    /// - Returns: A Dog object
    private func createDog(from dogData: [String: Any]) throws -> Dog {
        guard
            let id = dogData["id"] as? String,
            let name = dogData["name"] as? String,
            let breed = dogData["breed"] as? String,
            let age = dogData["age"] as? Int,
            let ownerId = dogData["owner_id"] as? String
        else {
            throw APIError(
                message: "Missing or invalid dog data",
                statusCode: nil,
                underlyingError: nil
            )
        }
        
        return Dog(
            id: id,
            name: name,
            breed: breed,
            age: age,
            ownerId: ownerId
        )
    }
}