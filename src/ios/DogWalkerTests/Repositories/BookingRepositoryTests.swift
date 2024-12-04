// XCTest framework - Latest
import XCTest
@testable import DogWalker

/// BookingRepositoryTests: Unit tests for the BookingRepository class
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System): Verifies booking management functionality
class BookingRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: BookingRepository!
    private var mockAPIClient: MockAPIClient!
    private var mockCoreDataStack: CoreDataStack!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockCoreDataStack = CoreDataStack()
        sut = BookingRepository(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockCoreDataStack = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Tests that createBooking successfully creates a booking
    func testCreateBooking() {
        // Given
        let expectation = XCTestExpectation(description: "Create booking")
        let mockBooking = createMockBooking()
        let expectedParameters: [String: Any] = [
            "id": mockBooking.id,
            "owner_id": mockBooking.owner.id,
            "walker_id": mockBooking.walker.id,
            "dog_ids": mockBooking.dogs.map { $0.id },
            "scheduled_at": ISO8601DateFormatter().string(from: mockBooking.scheduledAt),
            "status": mockBooking.status
        ]
        
        mockAPIClient.mockResult = .success(Data())
        
        // When
        sut.createBooking(booking: mockBooking) { result in
            // Then
            switch result {
            case .success:
                XCTAssertEqual(self.mockAPIClient.lastEndpoint, "/api/v1/bookings")
                XCTAssertEqual(self.mockAPIClient.lastParameters as? [String: Any], expectedParameters)
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Tests that createBooking handles API errors correctly
    func testCreateBookingFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Create booking failure")
        let mockBooking = createMockBooking()
        let mockError = APIError(message: "Network error", statusCode: 500)
        mockAPIClient.mockResult = .failure(mockError)
        
        // When
        sut.createBooking(booking: mockBooking) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
                
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, mockError.localizedDescription)
                XCTAssertEqual(error.statusCode, mockError.statusCode)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Tests that fetchBookings successfully retrieves bookings
    func testFetchBookings() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch bookings")
        let mockBookingsData = createMockBookingsResponse()
        mockAPIClient.mockResult = .success(mockBookingsData)
        
        // When
        sut.fetchBookings { result in
            // Then
            switch result {
            case .success(let bookings):
                XCTAssertEqual(self.mockAPIClient.lastEndpoint, "/api/v1/bookings")
                XCTAssertEqual(bookings.count, 1)
                
                let booking = bookings[0]
                XCTAssertEqual(booking.id, "booking123")
                XCTAssertEqual(booking.owner.id, "owner123")
                XCTAssertEqual(booking.walker.id, "walker123")
                XCTAssertEqual(booking.dogs.count, 1)
                XCTAssertEqual(booking.status, "pending")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Tests that fetchBookings handles API errors correctly
    func testFetchBookingsFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch bookings failure")
        let mockError = APIError(message: "Network error", statusCode: 500)
        mockAPIClient.mockResult = .failure(mockError)
        
        // When
        sut.fetchBookings { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
                
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, mockError.localizedDescription)
                XCTAssertEqual(error.statusCode, mockError.statusCode)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func createMockBooking() -> Booking {
        let owner = User(
            id: "owner123",
            name: "John Owner",
            email: "john@example.com",
            phone: "1234567890",
            role: "owner",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        let walker = User(
            id: "walker123",
            name: "Jane Walker",
            email: "jane@example.com",
            phone: "0987654321",
            role: "walker",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        let dog = Dog(
            id: "dog123",
            name: "Buddy",
            breed: "Labrador",
            age: 3,
            ownerId: owner.id
        )
        
        let walk = WalkSummary(id: "walk123", distance: 0, startTime: Date(), endTime: Date())
        let payment = PaymentSummary(id: "payment123", amount: 30.0, currency: "USD")
        
        return Booking(
            id: "booking123",
            owner: owner,
            walker: walker,
            dogs: [dog],
            walk: walk,
            payment: payment,
            scheduledAt: Date(),
            status: "pending"
        )
    }
    
    private func createMockBookingsResponse() -> Data {
        let json: [String: Any] = [
            [
                "id": "booking123",
                "owner": [
                    "id": "owner123",
                    "name": "John Owner",
                    "email": "john@example.com",
                    "phone": "1234567890",
                    "role": "owner"
                ],
                "walker": [
                    "id": "walker123",
                    "name": "Jane Walker",
                    "email": "jane@example.com",
                    "phone": "0987654321",
                    "role": "walker"
                ],
                "dogs": [
                    [
                        "id": "dog123",
                        "name": "Buddy",
                        "breed": "Labrador",
                        "age": 3,
                        "owner_id": "owner123"
                    ]
                ],
                "scheduled_at": ISO8601DateFormatter().string(from: Date()),
                "status": "pending"
            ]
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

// MARK: - Mock APIClient

private class MockAPIClient: APIClient {
    var mockResult: Result<Data, APIError>!
    var lastEndpoint: String?
    var lastParameters: Any?
    
    override func performRequest(
        endpoint: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        lastEndpoint = endpoint
        lastParameters = parameters
        completion(mockResult)
    }
}