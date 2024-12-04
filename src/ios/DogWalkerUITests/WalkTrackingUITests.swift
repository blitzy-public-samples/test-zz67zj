// XCTest framework - Latest
import XCTest

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure location services in Info.plist with proper usage descriptions
2. Set up mock location data for testing GPS tracking
3. Configure proper test environment with network mocking
4. Ensure test user data is properly configured
*/

/// UI tests for the Walk Tracking feature in the Dog Walker iOS application
/// Requirement: Service Execution (1.3 Scope/Core Features/Service Execution)
/// Supports live GPS tracking, route recording, and status updates for dog walking sessions
class WalkTrackingUITests: XCTestCase {
    
    // MARK: - Properties
    
    private var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize the application
        app = XCUIApplication()
        
        // Reset application state before each test
        app.launchArguments = ["--uitesting"]
        
        // Enable location services for testing
        app.launchEnvironment["ALLOW_LOCATION_SERVICES"] = "YES"
        
        // Launch the application
        app.launch()
        
        Logger.info("Test setup completed")
    }
    
    override func tearDownWithError() throws {
        // Clean up any test data
        app = nil
        try super.tearDownWithError()
        
        Logger.info("Test teardown completed")
    }
    
    // MARK: - Test Cases
    
    /// Tests the functionality of starting a walk from the Active Walk screen
    func testStartWalk() throws {
        Logger.info("Testing walk start functionality")
        
        // Navigate to Active Walk screen
        let activeWalkButton = app.buttons["Active Walk"]
        XCTAssertTrue(activeWalkButton.waitForExistence(timeout: 5))
        activeWalkButton.tap()
        
        // Verify initial screen state
        let startButton = app.buttons["Start Walk"]
        let endButton = app.buttons["End Walk"]
        
        XCTAssertTrue(startButton.exists)
        XCTAssertTrue(endButton.exists)
        XCTAssertFalse(endButton.isEnabled)
        
        // Start the walk
        startButton.tap()
        
        // Verify button states after starting walk
        XCTAssertFalse(startButton.isEnabled)
        XCTAssertTrue(endButton.isEnabled)
        
        // Verify map view is showing user location
        let mapView = app.otherElements["MapView"]
        XCTAssertTrue(mapView.exists)
        
        // Verify walk status label
        let statusLabel = app.staticTexts["walkStatusLabel"]
        XCTAssertTrue(statusLabel.label.contains("In Progress"))
        
        Logger.info("Walk start test completed successfully")
    }
    
    /// Tests the functionality of ending a walk from the Active Walk screen
    func testEndWalk() throws {
        Logger.info("Testing walk end functionality")
        
        // Navigate to Active Walk screen
        let activeWalkButton = app.buttons["Active Walk"]
        XCTAssertTrue(activeWalkButton.waitForExistence(timeout: 5))
        activeWalkButton.tap()
        
        // Start a walk first
        let startButton = app.buttons["Start Walk"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        
        // Wait for walk to be in progress
        let endButton = app.buttons["End Walk"]
        XCTAssertTrue(endButton.isEnabled)
        
        // End the walk
        endButton.tap()
        
        // Verify button states after ending walk
        XCTAssertTrue(startButton.isEnabled)
        XCTAssertFalse(endButton.isEnabled)
        
        // Verify walk status label
        let statusLabel = app.staticTexts["walkStatusLabel"]
        XCTAssertTrue(statusLabel.label.contains("Completed"))
        
        // Verify route is displayed on map
        let mapView = app.otherElements["MapView"]
        XCTAssertTrue(mapView.exists)
        
        Logger.info("Walk end test completed successfully")
    }
    
    /// Tests the real-time location tracking functionality during a walk
    func testRealTimeLocationUpdates() throws {
        Logger.info("Testing real-time location updates")
        
        // Navigate to Active Walk screen
        let activeWalkButton = app.buttons["Active Walk"]
        XCTAssertTrue(activeWalkButton.waitForExistence(timeout: 5))
        activeWalkButton.tap()
        
        // Start a walk
        let startButton = app.buttons["Start Walk"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        
        // Simulate location updates
        let locations = [
            (37.7749, -122.4194), // San Francisco
            (37.7750, -122.4180),
            (37.7752, -122.4170)
        ]
        
        for (index, location) in locations.enumerated() {
            // Simulate location change
            app.launchEnvironment["SIMULATED_LATITUDE"] = String(location.0)
            app.launchEnvironment["SIMULATED_LONGITUDE"] = String(location.1)
            
            // Wait for location update
            let predicate = NSPredicate { _, _ in
                // Verify location update in map view
                let mapView = self.app.otherElements["MapView"]
                return mapView.exists
            }
            
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
            _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
            
            // Verify route point is added
            let routePoints = app.otherElements["RoutePoints"]
            XCTAssertEqual(routePoints.children(matching: .any).count, index + 1)
        }
        
        // End the walk
        let endButton = app.buttons["End Walk"]
        endButton.tap()
        
        // Verify final route
        let mapView = app.otherElements["MapView"]
        XCTAssertTrue(mapView.exists)
        
        let routePoints = app.otherElements["RoutePoints"]
        XCTAssertEqual(routePoints.children(matching: .any).count, locations.count)
        
        Logger.info("Real-time location updates test completed successfully")
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    /// Waits for the element to exist and be hittable
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: Boolean indicating if element is ready for interaction
    func waitForHitPoint(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate { (element, _) -> Bool in
            guard let element = element as? XCUIElement else { return false }
            return element.exists && element.isHittable
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}