// XCTest framework - Latest
import XCTest
@testable import DogWalker

/// BookingViewModelTests: Tests the BookingViewModel functionality
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports real-time availability search, booking management, and schedule coordination
class BookingViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: BookingViewModel!
    private var mockBookingRepository: MockBookingRepository!
    private var mockGetBookingsUseCase: MockGetBookingsUseCase!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        mockBookingRepository = MockBookingRepository()
        mockGetBookingsUseCase = MockGetBookingsUseCase(bookingRepository: mockBookingRepository)
        sut = BookingViewModel(getBookingsUseCase: mockGetBookingsUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockGetBookingsUseCase = nil
        mockBookingRepository = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Tests that loadBookings correctly updates the view model's state when successful
    func testLoadBookings() {
        // Given
        let expectation = XCTestExpectation(description: "Loading bookings")
        var stateChangedCallCount = 0
        
        // Create test data
        let testDate = Date()
        let testLocation = Location(latitude: 0, longitude: 0)
        
        let testOwner = User(
            id: "owner1",
            name: "John Doe",
            email: "john@example.com",
            phone: "1234567890",
            role: "owner",
            walks: [],
            payments: [],
            currentLocation: testLocation
        )
        
        let testWalker = User(
            id: "walker1",
            name: "Jane Smith",
            email: "jane@example.com",
            phone: "0987654321",
            role: "walker",
            walks: [],
            payments: [],
            currentLocation: testLocation
        )
        
        let testDog = Dog(
            id: "dog1",
            name: "Max",
            breed: "Labrador",
            age: 3,
            ownerId: testOwner.id
        )
        
        let testWalk = WalkSummary(id: "walk1", distance: 0, startTime: testDate, endTime: testDate)
        let testPayment = PaymentSummary(id: "payment1", amount: 0, currency: "USD")
        
        let testBooking = Booking(
            id: "booking1",
            owner: testOwner,
            walker: testWalker,
            dogs: [testDog],
            walk: testWalk,
            payment: testPayment,
            scheduledAt: testDate,
            status: "pending"
        )
        
        let expectedBookings = [testBooking]
        
        // Configure mock to return test data
        mockGetBookingsUseCase.executeResult = .success(expectedBookings)
        
        // Monitor state changes
        sut.onStateChanged = {
            stateChangedCallCount += 1
            
            // Verify state changes in correct order
            switch stateChangedCallCount {
            case 1:
                // First state change: Loading started
                XCTAssertTrue(self.sut.isLoading)
                XCTAssertNil(self.sut.error)
                XCTAssertTrue(self.sut.bookings.isEmpty)
                
            case 2:
                // Second state change: Loading finished
                XCTAssertFalse(self.sut.isLoading)
                XCTAssertNil(self.sut.error)
                XCTAssertEqual(self.sut.bookings, expectedBookings)
                expectation.fulfill()
                
            default:
                XCTFail("Unexpected number of state changes")
            }
        }
        
        // When
        sut.loadBookings()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChangedCallCount, 2)
        XCTAssertEqual(mockGetBookingsUseCase.executeCallCount, 1)
        XCTAssertEqual(sut.bookings, expectedBookings)
    }
    
    /// Tests that loadBookings correctly handles errors
    func testLoadBookingsError() {
        // Given
        let expectation = XCTestExpectation(description: "Loading bookings error")
        var stateChangedCallCount = 0
        
        let testError = APIError(
            message: "Failed to fetch bookings",
            statusCode: 500,
            underlyingError: nil
        )
        
        // Configure mock to return error
        mockGetBookingsUseCase.executeResult = .failure(testError)
        
        // Monitor state changes
        sut.onStateChanged = {
            stateChangedCallCount += 1
            
            // Verify state changes in correct order
            switch stateChangedCallCount {
            case 1:
                // First state change: Loading started
                XCTAssertTrue(self.sut.isLoading)
                XCTAssertNil(self.sut.error)
                XCTAssertTrue(self.sut.bookings.isEmpty)
                
            case 2:
                // Second state change: Error state
                XCTAssertFalse(self.sut.isLoading)
                XCTAssertEqual(self.sut.error as? APIError, testError)
                XCTAssertTrue(self.sut.bookings.isEmpty)
                expectation.fulfill()
                
            default:
                XCTFail("Unexpected number of state changes")
            }
        }
        
        // When
        sut.loadBookings()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChangedCallCount, 2)
        XCTAssertEqual(mockGetBookingsUseCase.executeCallCount, 1)
        XCTAssertTrue(sut.bookings.isEmpty)
        XCTAssertEqual(sut.error as? APIError, testError)
    }
}

// MARK: - Mock Objects

/// Mock implementation of BookingRepository for testing
private class MockBookingRepository: BookingRepository {
    var fetchBookingsCallCount = 0
    var fetchBookingsResult: Result<[Booking], APIError>?
    
    override func fetchBookings(completion: @escaping (Result<[Booking], APIError>) -> Void) {
        fetchBookingsCallCount += 1
        if let result = fetchBookingsResult {
            completion(result)
        }
    }
}

/// Mock implementation of GetBookingsUseCase for testing
private class MockGetBookingsUseCase: GetBookingsUseCase {
    var executeCallCount = 0
    var executeResult: Result<[Booking], APIError>?
    
    override func execute(completion: @escaping (Result<[Booking], APIError>) -> Void) {
        executeCallCount += 1
        if let result = executeResult {
            completion(result)
        }
    }
}