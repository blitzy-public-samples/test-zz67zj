// XCTest framework - Latest
import XCTest

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure test data is properly set up in the test environment
2. Configure proper test environment variables
3. Review and update test assertions based on business requirements
4. Set up proper test reporting and monitoring
*/

/// BookingFlowUITests: UI tests for the booking flow in the Dog Walker iOS application
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System)
/// - Supports real-time availability search, booking management, and schedule coordination
class BookingFlowUITests: XCTestCase {
    
    // MARK: - Properties
    
    private var app: XCUIApplication!
    
    // MARK: - Test Lifecycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    /// Tests the end-to-end booking flow
    /// Verifies that users can create a booking and see it in their booking list
    func testBookingFlow() throws {
        // Given: The app is launched and on the Bookings screen
        let bookingsNavigationBar = app.navigationBars["Bookings"]
        XCTAssertTrue(bookingsNavigationBar.exists, "Bookings navigation bar should be visible")
        
        // When: User taps the create booking button
        let createButton = app.buttons["Create Booking"]
        XCTAssertTrue(createButton.exists, "Create Booking button should be visible")
        createButton.tap()
        
        // Then: Create booking form should be displayed
        let createBookingTitle = app.navigationBars["Create Booking"]
        XCTAssertTrue(createBookingTitle.exists, "Create Booking screen should be visible")
        
        // When: User fills in booking details
        let ownerField = app.textFields["Owner"]
        let walkerField = app.textFields["Walker"]
        let dogField = app.textFields["Dog"]
        let dateField = app.textFields["Date"]
        
        XCTAssertTrue(ownerField.exists, "Owner field should be visible")
        XCTAssertTrue(walkerField.exists, "Walker field should be visible")
        XCTAssertTrue(dogField.exists, "Dog field should be visible")
        XCTAssertTrue(dateField.exists, "Date field should be visible")
        
        ownerField.tap()
        ownerField.typeText("John Doe")
        
        walkerField.tap()
        walkerField.typeText("Jane Smith")
        
        dogField.tap()
        dogField.typeText("Max")
        
        dateField.tap()
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists, "Date picker should be visible")
        // Select tomorrow's date
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        datePicker.adjust(to: tomorrow)
        
        // When: User submits the booking
        let submitButton = app.buttons["Submit"]
        XCTAssertTrue(submitButton.exists, "Submit button should be visible")
        submitButton.tap()
        
        // Then: Should return to bookings list
        XCTAssertTrue(bookingsNavigationBar.exists, "Should return to Bookings screen")
        
        // And: New booking should appear in the list
        let bookingsList = app.tables["BookingsList"]
        XCTAssertTrue(bookingsList.exists, "Bookings list should be visible")
        
        // Wait for the booking to appear
        let newBookingCell = bookingsList.cells.containing(NSPredicate(format: "label CONTAINS 'John Doe'")).element
        let exists = newBookingCell.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "New booking should appear in the list")
        
        // When: User taps on the booking
        newBookingCell.tap()
        
        // Then: Booking details should be displayed
        let detailsTitle = app.navigationBars["Booking Details"]
        XCTAssertTrue(detailsTitle.exists, "Booking details screen should be visible")
        
        // Verify booking details
        let ownerLabel = app.staticTexts["Owner: John Doe"]
        let walkerLabel = app.staticTexts["Walker: Jane Smith"]
        let dogLabel = app.staticTexts["Dog: Max"]
        
        XCTAssertTrue(ownerLabel.exists, "Owner details should be visible")
        XCTAssertTrue(walkerLabel.exists, "Walker details should be visible")
        XCTAssertTrue(dogLabel.exists, "Dog details should be visible")
    }
    
    /// Tests the booking list refresh functionality
    func testBookingListRefresh() throws {
        // Given: The app is on the Bookings screen
        let bookingsList = app.tables["BookingsList"]
        XCTAssertTrue(bookingsList.exists, "Bookings list should be visible")
        
        // When: User pulls to refresh
        bookingsList.swipeDown()
        
        // Then: Loading indicator should appear
        let loadingIndicator = app.activityIndicators["LoadingIndicator"]
        XCTAssertTrue(loadingIndicator.exists, "Loading indicator should be visible during refresh")
        
        // And: Loading indicator should disappear
        let disappeared = loadingIndicator.waitForNonExistence(timeout: 5)
        XCTAssertTrue(disappeared, "Loading indicator should disappear after refresh")
    }
    
    /// Tests error handling in the booking flow
    func testBookingErrorHandling() throws {
        // Given: The app is on the Bookings screen
        let createButton = app.buttons["Create Booking"]
        XCTAssertTrue(createButton.exists, "Create Booking button should be visible")
        createButton.tap()
        
        // When: User submits without required fields
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        // Then: Error messages should appear
        let errorMessage = app.staticTexts["Please fill in all required fields"]
        XCTAssertTrue(errorMessage.exists, "Error message should be visible")
        
        // When: User fills invalid data
        let dateField = app.textFields["Date"]
        dateField.tap()
        dateField.typeText("invalid date")
        
        submitButton.tap()
        
        // Then: Validation error should appear
        let validationError = app.staticTexts["Invalid date format"]
        XCTAssertTrue(validationError.exists, "Validation error should be visible")
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    /// Waits for the element to not exist
    /// - Parameter timeout: Maximum time to wait
    /// - Returns: True if the element no longer exists
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == FALSE")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}