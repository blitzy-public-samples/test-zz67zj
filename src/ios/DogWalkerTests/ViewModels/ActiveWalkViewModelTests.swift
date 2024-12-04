// XCTest framework - Latest
import XCTest
@testable import DogWalker

/// Unit tests for ActiveWalkViewModel
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Ensures the ActiveWalkViewModel correctly supports live GPS tracking, route recording, and status updates for dog walking sessions
class ActiveWalkViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: ActiveWalkViewModel!
    private var mockStartWalkUseCase: MockStartWalkUseCase!
    private var mockEndWalkUseCase: MockEndWalkUseCase!
    private var mockTrackWalkUseCase: MockTrackWalkUseCase!
    private var mockLocationService: MockLocationService!
    private var mockNotificationService: MockNotificationService!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Initialize mocks
        mockStartWalkUseCase = MockStartWalkUseCase()
        mockEndWalkUseCase = MockEndWalkUseCase()
        mockTrackWalkUseCase = MockTrackWalkUseCase()
        mockLocationService = MockLocationService()
        mockNotificationService = MockNotificationService()
        
        // Initialize view model with mocks
        viewModel = ActiveWalkViewModel(
            startWalkUseCase: mockStartWalkUseCase,
            endWalkUseCase: mockEndWalkUseCase,
            trackWalkUseCase: mockTrackWalkUseCase,
            locationService: mockLocationService,
            notificationService: mockNotificationService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockStartWalkUseCase = nil
        mockEndWalkUseCase = nil
        mockTrackWalkUseCase = nil
        mockLocationService = nil
        mockNotificationService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Tests that startWalk initializes a walk session correctly
    func testStartWalk() {
        // Arrange
        let walker = User(
            id: "test-walker",
            name: "Test Walker",
            email: "test@example.com",
            phone: "1234567890",
            role: "walker",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        let dog = Dog(
            id: "test-dog",
            name: "Test Dog",
            breed: "Test Breed",
            age: 3,
            ownerId: "test-owner"
        )
        
        let startLocation = Location(latitude: 37.7749, longitude: -122.4194)
        let expectedWalkId = "test-walk-id"
        
        // Configure mock
        mockStartWalkUseCase.mockWalk = Walk(
            id: expectedWalkId,
            walker: walker,
            dogs: [dog],
            booking: Booking(
                id: "test-booking",
                owner: walker,
                walker: walker,
                dogs: [dog],
                walk: WalkSummary(
                    id: expectedWalkId,
                    distance: 0,
                    startTime: Date(),
                    endTime: Date()
                ),
                payment: PaymentSummary(
                    id: "test-payment",
                    amount: 0,
                    currency: "USD"
                ),
                scheduledAt: Date(),
                status: "in_progress"
            ),
            route: [startLocation],
            startTime: Date(),
            endTime: Date(),
            status: "in_progress"
        )
        
        // Act
        viewModel.startWalk(walker: walker, dogs: [dog], startLocation: startLocation)
        
        // Assert
        XCTAssertEqual(viewModel.currentWalkId, expectedWalkId, "Current walk ID should be set correctly")
        XCTAssertTrue(mockLocationService.startTrackingCalled, "Location tracking should be started")
        XCTAssertTrue(mockNotificationService.sendPushNotificationCalled, "Push notification should be sent")
    }
    
    /// Tests that endWalk finalizes a walk session correctly
    func testEndWalk() {
        // Arrange
        let walkId = "test-walk-id"
        viewModel.currentWalkId = walkId
        
        // Act
        viewModel.endWalk()
        
        // Assert
        XCTAssertNil(viewModel.currentWalkId, "Current walk ID should be cleared")
        XCTAssertTrue(mockLocationService.stopTrackingCalled, "Location tracking should be stopped")
        XCTAssertTrue(mockNotificationService.sendPushNotificationCalled, "Push notification should be sent")
        XCTAssertTrue(mockEndWalkUseCase.endWalkCalled, "EndWalkUseCase should be called")
    }
    
    /// Tests that trackLocation updates the walk route correctly
    func testTrackLocation() {
        // Arrange
        let walkId = "test-walk-id"
        viewModel.currentWalkId = walkId
        let latitude = 37.7749
        let longitude = -122.4194
        
        // Act
        viewModel.trackLocation(latitude: latitude, longitude: longitude)
        
        // Assert
        XCTAssertTrue(mockTrackWalkUseCase.trackLocationCalled, "TrackWalkUseCase should be called")
        XCTAssertEqual(mockTrackWalkUseCase.lastLatitude, latitude, "Latitude should be passed correctly")
        XCTAssertEqual(mockTrackWalkUseCase.lastLongitude, longitude, "Longitude should be passed correctly")
        XCTAssertTrue(mockLocationService.updateLocationCalled, "Location service should be updated")
    }
}

// MARK: - Mock Classes

/// Mock implementation of StartWalkUseCase for testing
private class MockStartWalkUseCase: StartWalkUseCase {
    var mockWalk: Walk?
    
    override func startWalk(walker: User, dogs: [Dog], startLocation: Location) throws -> Walk {
        return mockWalk ?? Walk(
            id: "mock-walk",
            walker: walker,
            dogs: dogs,
            booking: Booking(
                id: "mock-booking",
                owner: walker,
                walker: walker,
                dogs: dogs,
                walk: WalkSummary(
                    id: "mock-walk",
                    distance: 0,
                    startTime: Date(),
                    endTime: Date()
                ),
                payment: PaymentSummary(
                    id: "mock-payment",
                    amount: 0,
                    currency: "USD"
                ),
                scheduledAt: Date(),
                status: "in_progress"
            ),
            route: [startLocation],
            startTime: Date(),
            endTime: Date(),
            status: "in_progress"
        )
    }
}

/// Mock implementation of EndWalkUseCase for testing
private class MockEndWalkUseCase: EndWalkUseCase {
    var endWalkCalled = false
    
    override func endWalk(_ walk: Walk) throws {
        endWalkCalled = true
    }
}

/// Mock implementation of TrackWalkUseCase for testing
private class MockTrackWalkUseCase: TrackWalkUseCase {
    var trackLocationCalled = false
    var lastLatitude: Double?
    var lastLongitude: Double?
    
    override func trackLocation(walkId: String, latitude: Double, longitude: Double) {
        trackLocationCalled = true
        lastLatitude = latitude
        lastLongitude = longitude
    }
}

/// Mock implementation of LocationService for testing
private class MockLocationService: LocationService {
    var startTrackingCalled = false
    var stopTrackingCalled = false
    var updateLocationCalled = false
    
    override func startTracking() {
        startTrackingCalled = true
    }
    
    override func stopTracking() {
        stopTrackingCalled = true
    }
    
    override func updateLocation(_ location: Location) {
        updateLocationCalled = true
    }
}

/// Mock implementation of NotificationService for testing
private class MockNotificationService: NotificationService {
    var sendPushNotificationCalled = false
    
    override func sendPushNotification(userId: String, message: String) {
        sendPushNotificationCalled = true
    }
}