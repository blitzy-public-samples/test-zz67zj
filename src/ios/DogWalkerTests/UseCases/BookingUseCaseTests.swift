// XCTest framework - Latest
import XCTest

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure test data matches the validation rules in CreateBookingUseCase
2. Configure proper test environment for repository mocking
3. Review test coverage requirements for booking operations
4. Set up proper test logging configuration
*/

/// BookingUseCaseTests: Unit tests for booking-related use cases
/// Requirement: Booking System (1.3 Scope/Core Features/Booking System)
/// Supports real-time availability search, booking management, and schedule coordination
final class BookingUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockBookingRepository: MockBookingRepository!
    private var createBookingUseCase: CreateBookingUseCase!
    private var getBookingsUseCase: GetBookingsUseCase!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        mockBookingRepository = MockBookingRepository()
        createBookingUseCase = CreateBookingUseCase(bookingRepository: mockBookingRepository)
        getBookingsUseCase = GetBookingsUseCase(bookingRepository: mockBookingRepository)
        Logger.info("Setting up BookingUseCaseTests")
    }
    
    override func tearDown() {
        mockBookingRepository = nil
        createBookingUseCase = nil
        getBookingsUseCase = nil
        super.tearDown()
        Logger.info("Tearing down BookingUseCaseTests")
    }
    
    // MARK: - Test Cases
    
    /// Tests the successful creation of a booking
    func testCreateBooking() {
        // Given
        let expectation = XCTestExpectation(description: "Create booking")
        let mockBooking = createMockBooking()
        
        mockBookingRepository.createBookingResult = .success(())
        
        // When
        createBookingUseCase.execute(booking: mockBooking) { result in
            // Then
            switch result {
            case .success:
                XCTAssertTrue(self.mockBookingRepository.createBookingCalled)
                XCTAssertEqual(self.mockBookingRepository.lastBooking?.id, mockBooking.id)
                Logger.info("Successfully tested booking creation")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Tests booking creation failure
    func testCreateBookingFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Create booking failure")
        let mockBooking = createMockBooking()
        let mockError = APIError(message: "Failed to create booking", statusCode: 500)
        
        mockBookingRepository.createBookingResult = .failure(mockError)
        
        // When
        createBookingUseCase.execute(booking: mockBooking) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
                
            case .failure(let error):
                XCTAssertTrue(self.mockBookingRepository.createBookingCalled)
                XCTAssertEqual(error.statusCode, mockError.statusCode)
                Logger.info("Successfully tested booking creation failure")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Tests the successful retrieval of bookings
    func testGetBookings() {
        // Given
        let expectation = XCTestExpectation(description: "Get bookings")
        let mockBookings = [createMockBooking(), createMockBooking()]
        
        mockBookingRepository.fetchBookingsResult = .success(mockBookings)
        
        // When
        getBookingsUseCase.execute { result in
            // Then
            switch result {
            case .success(let bookings):
                XCTAssertTrue(self.mockBookingRepository.fetchBookingsCalled)
                XCTAssertEqual(bookings.count, mockBookings.count)
                Logger.info("Successfully tested bookings retrieval")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Tests bookings retrieval failure
    func testGetBookingsFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Get bookings failure")
        let mockError = APIError(message: "Failed to fetch bookings", statusCode: 500)
        
        mockBookingRepository.fetchBookingsResult = .failure(mockError)
        
        // When
        getBookingsUseCase.execute { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
                
            case .failure(let error):
                XCTAssertTrue(self.mockBookingRepository.fetchBookingsCalled)
                XCTAssertEqual(error.statusCode, mockError.statusCode)
                Logger.info("Successfully tested bookings retrieval failure")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    /// Creates a mock booking for testing
    private func createMockBooking() -> Booking {
        let owner = User(
            id: "owner123",
            name: "John Doe",
            email: "john@example.com",
            phone: "+1234567890",
            role: "owner",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        let walker = User(
            id: "walker123",
            name: "Jane Smith",
            email: "jane@example.com",
            phone: "+1987654321",
            role: "walker",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        let dog = Dog(
            id: "dog123",
            name: "Max",
            breed: "Golden Retriever",
            age: 3,
            ownerId: owner.id
        )
        
        let walk = WalkSummary(
            id: "walk123",
            distance: 2.5,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600)
        )
        
        let payment = PaymentSummary(
            id: "payment123",
            amount: 30.0,
            currency: "USD"
        )
        
        return Booking(
            id: "booking123",
            owner: owner,
            walker: walker,
            dogs: [dog],
            walk: walk,
            payment: payment,
            scheduledAt: Date().addingTimeInterval(86400),
            status: "pending"
        )
    }
}

// MARK: - Mock Repository

/// Mock implementation of BookingRepository for testing
private class MockBookingRepository: BookingRepository {
    var createBookingCalled = false
    var fetchBookingsCalled = false
    var lastBooking: Booking?
    
    var createBookingResult: Result<Void, APIError>?
    var fetchBookingsResult: Result<[Booking], APIError>?
    
    override func createBooking(booking: Booking, completion: @escaping (Result<Void, APIError>) -> Void) {
        createBookingCalled = true
        lastBooking = booking
        
        if let result = createBookingResult {
            completion(result)
        }
    }
    
    override func fetchBookings(completion: @escaping (Result<[Booking], APIError>) -> Void) {
        fetchBookingsCalled = true
        
        if let result = fetchBookingsResult {
            completion(result)
        }
    }
}