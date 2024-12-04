// XCTest framework - Latest
import XCTest
// Combine framework - Latest
import Combine
@testable import DogWalker

/// LoginViewModelTests: Unit tests for the LoginViewModel
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Ensures the login functionality is robust and error-free through comprehensive testing.
class LoginViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var loginViewModel: LoginViewModel!
    private var mockLoginUseCase: MockLoginUseCase!
    private var mockLogger: MockLogger!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        mockLoginUseCase = MockLoginUseCase()
        mockLogger = MockLogger()
        loginViewModel = LoginViewModel(loginUseCase: mockLoginUseCase)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        loginViewModel = nil
        mockLoginUseCase = nil
        mockLogger = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testLoginSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Login success")
        let testEmail = "test@example.com"
        let testPassword = "ValidPass123"
        let testUser = User(
            id: "test-id",
            name: "Test User",
            email: testEmail,
            phone: "+1234567890",
            role: "user",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        mockLoginUseCase.mockResult = .success(testUser)
        
        var loadingStates: [Bool] = []
        var loggedInStates: [Bool] = []
        var errorMessages: [String?] = []
        
        // When
        loginViewModel.$isLoading
            .sink { loadingStates.append($0) }
            .store(in: &cancellables)
        
        loginViewModel.$isLoggedIn
            .sink { loggedInStates.append($0) }
            .store(in: &cancellables)
        
        loginViewModel.$errorMessage
            .sink { errorMessages.append($0) }
            .store(in: &cancellables)
        
        loginViewModel.login(email: testEmail, password: testPassword)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(loadingStates, [false, true, false])
            XCTAssertEqual(loggedInStates, [false, true])
            XCTAssertEqual(errorMessages, [nil, nil])
            XCTAssertTrue(self.loginViewModel.isLoggedIn)
            XCTAssertNil(self.loginViewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoginFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Login failure")
        let testEmail = "invalid@email.com"
        let testPassword = "invalid"
        let testError = APIError(message: "Invalid credentials")
        
        mockLoginUseCase.mockResult = .failure(testError)
        
        var loadingStates: [Bool] = []
        var loggedInStates: [Bool] = []
        var errorMessages: [String?] = []
        
        // When
        loginViewModel.$isLoading
            .sink { loadingStates.append($0) }
            .store(in: &cancellables)
        
        loginViewModel.$isLoggedIn
            .sink { loggedInStates.append($0) }
            .store(in: &cancellables)
        
        loginViewModel.$errorMessage
            .sink { errorMessages.append($0) }
            .store(in: &cancellables)
        
        loginViewModel.login(email: testEmail, password: testPassword)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(loadingStates, [false, true, false])
            XCTAssertEqual(loggedInStates, [false])
            XCTAssertEqual(errorMessages.last, testError.localizedDescription)
            XCTAssertFalse(self.loginViewModel.isLoggedIn)
            XCTAssertNotNil(self.loginViewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoggerIntegration() {
        // Given
        let expectation = XCTestExpectation(description: "Logger integration")
        let testEmail = "test@example.com"
        let testPassword = "ValidPass123"
        let testUser = User(
            id: "test-id",
            name: "Test User",
            email: testEmail,
            phone: "+1234567890",
            role: "user",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        mockLoginUseCase.mockResult = .success(testUser)
        
        // When
        loginViewModel.login(email: testEmail, password: testPassword)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(Logger.log.wasCalled)
            XCTAssertEqual(Logger.log.lastMessage, "Login successful for user: \(testUser.id)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Objects

private class MockLoginUseCase: LoginUseCase {
    var mockResult: Result<User, Error>!
    
    override func execute(email: String, password: String) -> Result<User, Error> {
        return mockResult
    }
}

private class MockLogger {
    private(set) var wasCalled = false
    private(set) var lastMessage: String?
    private(set) var lastLevel: Logger.Level?
    
    func log(_ message: String, level: Logger.Level = .info) {
        wasCalled = true
        lastMessage = message
        lastLevel = level
    }
}