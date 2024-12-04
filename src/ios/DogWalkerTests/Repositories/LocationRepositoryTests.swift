// XCTest framework - Latest
import XCTest
@testable import DogWalker

/// LocationRepositoryTests: Unit tests for the LocationRepository class
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Verifies the functionality of live GPS tracking and location-based features
class LocationRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockAPIClient: MockAPIClient!
    private var locationRepository: LocationRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        locationRepository = LocationRepository(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        locationRepository = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Tests the successful retrieval of current location
    func testFetchCurrentLocation() async {
        // Arrange
        let expectedLatitude = 37.7749
        let expectedLongitude = -122.4194
        let mockResponse = [
            "latitude": expectedLatitude,
            "longitude": expectedLongitude
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: mockResponse)
        mockAPIClient.mockResult = .success(jsonData)
        
        // Act
        let location = await locationRepository.fetchCurrentLocation()
        
        // Assert
        XCTAssertNotNil(location, "Location should not be nil")
        XCTAssertEqual(location?.latitude, expectedLatitude, "Latitude should match expected value")
        XCTAssertEqual(location?.longitude, expectedLongitude, "Longitude should match expected value")
        XCTAssertEqual(mockAPIClient.lastEndpoint, "/api/v1/location/current", "Endpoint should match expected value")
    }
    
    /// Tests location fetch with invalid JSON response
    func testFetchCurrentLocationWithInvalidJSON() async {
        // Arrange
        let invalidJSON = "invalid json".data(using: .utf8)!
        mockAPIClient.mockResult = .success(invalidJSON)
        
        // Act
        let location = await locationRepository.fetchCurrentLocation()
        
        // Assert
        XCTAssertNil(location, "Location should be nil for invalid JSON")
    }
    
    /// Tests location fetch with network error
    func testFetchCurrentLocationWithNetworkError() async {
        // Arrange
        let error = NSError(domain: "com.dogwalker.test", code: -1, userInfo: nil)
        mockAPIClient.mockResult = .failure(error)
        
        // Act
        let location = await locationRepository.fetchCurrentLocation()
        
        // Assert
        XCTAssertNil(location, "Location should be nil for network error")
    }
    
    /// Tests successful location update
    func testUpdateLocation() async {
        // Arrange
        let mockLocation = Location(latitude: 37.7749, longitude: -122.4194)
        let mockResponse = ["status": "success"]
        let jsonData = try! JSONSerialization.data(withJSONObject: mockResponse)
        mockAPIClient.mockResult = .success(jsonData)
        
        // Act
        let success = await locationRepository.updateLocation(mockLocation)
        
        // Assert
        XCTAssertTrue(success, "Update location should return true for successful response")
        XCTAssertEqual(mockAPIClient.lastEndpoint, "/api/v1/location/update", "Endpoint should match expected value")
        
        // Verify parameters
        if let parameters = mockAPIClient.lastParameters as? [String: Any] {
            XCTAssertEqual(parameters["latitude"] as? Double, mockLocation.latitude)
            XCTAssertEqual(parameters["longitude"] as? Double, mockLocation.longitude)
            XCTAssertNotNil(parameters["timestamp"])
        } else {
            XCTFail("Parameters should not be nil")
        }
    }
    
    /// Tests location update with network error
    func testUpdateLocationWithNetworkError() async {
        // Arrange
        let mockLocation = Location(latitude: 37.7749, longitude: -122.4194)
        let error = NSError(domain: "com.dogwalker.test", code: -1, userInfo: nil)
        mockAPIClient.mockResult = .failure(error)
        
        // Act
        let success = await locationRepository.updateLocation(mockLocation)
        
        // Assert
        XCTAssertFalse(success, "Update location should return false for network error")
    }
}

// MARK: - Mock APIClient

private class MockAPIClient: APIClient {
    var mockResult: Result<Data, Error>?
    var lastEndpoint: String?
    var lastParameters: [String: Any]?
    
    override func performRequest(
        endpoint: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        lastEndpoint = endpoint
        lastParameters = parameters
        
        if let result = mockResult {
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(APIError(message: error.localizedDescription,
                                          statusCode: nil,
                                          underlyingError: error)))
            }
        }
    }
}