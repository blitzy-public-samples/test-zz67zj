// XCTest framework - Latest
import XCTest

/// AuthenticationUITests: Defines UI tests for the authentication flows, including login and registration
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Ensures the authentication flows, including login and registration, function as expected
class AuthenticationUITests: XCTestCase {
    
    // MARK: - Human Tasks
    /*
    1. Configure test user credentials in a secure configuration file
    2. Set up test environment with clean state before each test
    3. Verify network mocking is properly configured for authentication requests
    4. Review and update test coverage metrics
    */
    
    // MARK: - Properties
    
    private var app: XCUIApplication!
    
    // MARK: - Test Lifecycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Login Tests
    
    /// Tests the login flow with valid credentials
    func testLoginFlow() throws {
        // Navigate to login screen (assuming it's the initial screen)
        let emailTextField = app.textFields["loginEmailTextField"]
        let passwordTextField = app.secureTextFields["loginPasswordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        // Verify login screen elements are present
        XCTAssertTrue(emailTextField.exists, "Email text field should be visible")
        XCTAssertTrue(passwordTextField.exists, "Password text field should be visible")
        XCTAssertTrue(loginButton.exists, "Login button should be visible")
        
        // Test valid login
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        passwordTextField.tap()
        passwordTextField.typeText("ValidPass123")
        
        loginButton.tap()
        
        // Verify successful login transition
        let homeScreenElement = app.otherElements["homeScreen"]
        XCTAssertTrue(homeScreenElement.waitForExistence(timeout: 5), "Should transition to home screen after successful login")
        
        // Test invalid login
        // Navigate back to login screen
        app.navigationBars.buttons.firstMatch.tap()
        
        // Clear previous input
        emailTextField.tap()
        emailTextField.clearText()
        emailTextField.typeText("invalid@email.com")
        
        passwordTextField.tap()
        passwordTextField.clearText()
        passwordTextField.typeText("wrongpass")
        
        loginButton.tap()
        
        // Verify error alert appears
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5), "Error alert should appear for invalid credentials")
        XCTAssertTrue(errorAlert.label.contains("Login Failed"), "Error alert should indicate login failure")
        
        // Dismiss error alert
        errorAlert.buttons["OK"].tap()
    }
    
    /// Tests the registration flow with valid user details
    func testRegistrationFlow() throws {
        // Navigate to registration screen
        app.buttons["Register"].tap()
        
        // Verify registration screen elements
        let nameTextField = app.textFields.matching(identifier: "Full Name").firstMatch
        let emailTextField = app.textFields.matching(identifier: "Email Address").firstMatch
        let passwordTextField = app.secureTextFields.firstMatch
        let phoneTextField = app.textFields.matching(identifier: "Phone Number").firstMatch
        let roleSegmentedControl = app.segmentedControls.firstMatch
        let registerButton = app.buttons["Register Button"]
        
        XCTAssertTrue(nameTextField.exists, "Name text field should be visible")
        XCTAssertTrue(emailTextField.exists, "Email text field should be visible")
        XCTAssertTrue(passwordTextField.exists, "Password text field should be visible")
        XCTAssertTrue(phoneTextField.exists, "Phone text field should be visible")
        XCTAssertTrue(roleSegmentedControl.exists, "Role selector should be visible")
        XCTAssertTrue(registerButton.exists, "Register button should be visible")
        
        // Test valid registration
        nameTextField.tap()
        nameTextField.typeText("John Doe")
        
        emailTextField.tap()
        emailTextField.typeText("john.doe@example.com")
        
        passwordTextField.tap()
        passwordTextField.typeText("SecurePass123")
        
        phoneTextField.tap()
        phoneTextField.typeText("+1234567890")
        
        // Select "Walker" role
        roleSegmentedControl.buttons["Walker"].tap()
        
        registerButton.tap()
        
        // Verify successful registration
        let successAlert = app.alerts.firstMatch
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5), "Success alert should appear after registration")
        
        // Test invalid registration
        // Clear previous input
        nameTextField.tap()
        nameTextField.clearText()
        
        emailTextField.tap()
        emailTextField.clearText()
        emailTextField.typeText("invalid-email")
        
        passwordTextField.tap()
        passwordTextField.clearText()
        passwordTextField.typeText("weak")
        
        phoneTextField.tap()
        phoneTextField.clearText()
        phoneTextField.typeText("invalid")
        
        registerButton.tap()
        
        // Verify error alert appears
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5), "Error alert should appear for invalid registration")
        XCTAssertTrue(errorAlert.label.contains("Error"), "Error alert should indicate registration failure")
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    /// Clears the text from a text field
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        // First tap the text field to activate it
        self.tap()
        
        // Delete existing text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}