// XCTest framework - Latest
import XCTest
@testable import DogWalker

/// LoginUseCaseTests: Test suite for the LoginUseCase
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Ensures the login functionality is correctly implemented and tested.
class LoginUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockAuthRepository: MockAuthRepository!
    private var loginUseCase: LoginUseCase!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockAuthRepository = MockAuthRepository()
        loginUseCase = LoginUseCase(authRepository: mockAuthRepository)
    }
    
    override func tearDown() {
        mockAuthRepository = nil
        loginUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testLoginSuccess() {
        // Given
        let expectedEmail = "test@example.com"
        let expectedPassword = "ValidPass123"
        let expectedUser = User(
            id: "test-user-id",
            name: "Test User",
            email: expectedEmail,
            phone: "+1234567890",
            role: "user",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        mockAuthRepository.mockLoginResult = .success(expectedUser)
        
        // When
        let result = loginUseCase.execute(email: expectedEmail, password: expectedPassword)
        
        // Then
        switch result {
        case .success(let user):
            XCTAssertEqual(user.id, expectedUser.id)
            XCTAssertEqual(user.email, expectedEmail)
            XCTAssertEqual(mockAuthRepository.lastLoginEmail, expectedEmail)
            XCTAssertEqual(mockAuthRepository.lastLoginPassword, expectedPassword)
            XCTAssertEqual(mockAuthRepository.loginCallCount, 1)
        case .failure(let error):
            XCTFail("Expected success but got failure with error: \(error)")
        }
    }
    
    func testLoginFailure() {
        // Given
        let expectedEmail = "invalid@example.com"
        let expectedPassword = "InvalidPass"
        let expectedError = APIError(message: "Invalid credentials")
        
        mockAuthRepository.mockLoginResult = .failure(expectedError)
        
        // When
        let result = loginUseCase.execute(email: expectedEmail, password: expectedPassword)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual((error as? APIError)?.message, expectedError.message)
            XCTAssertEqual(mockAuthRepository.lastLoginEmail, expectedEmail)
            XCTAssertEqual(mockAuthRepository.lastLoginPassword, expectedPassword)
            XCTAssertEqual(mockAuthRepository.loginCallCount, 1)
        }
    }
    
    func testLoginWithInvalidEmailFormat() {
        // Given
        let invalidEmail = "invalid-email"
        let password = "ValidPass123"
        
        // When
        let result = loginUseCase.execute(email: invalidEmail, password: password)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for invalid email format")
        case .failure(let error):
            XCTAssertEqual((error as? APIError)?.message, "Invalid email format")
            XCTAssertEqual(mockAuthRepository.loginCallCount, 0, "Repository should not be called for invalid email")
        }
    }
    
    func testLoginWithInvalidPasswordFormat() {
        // Given
        let email = "test@example.com"
        let invalidPassword = "weak"
        
        // When
        let result = loginUseCase.execute(email: email, password: invalidPassword)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for invalid password format")
        case .failure(let error):
            XCTAssertEqual((error as? APIError)?.message, "Invalid password format")
            XCTAssertEqual(mockAuthRepository.loginCallCount, 0, "Repository should not be called for invalid password")
        }
    }
}

// MARK: - Mock AuthRepository

private class MockAuthRepository: AuthRepository {
    var mockLoginResult: Result<User, Error>!
    var loginCallCount = 0
    var lastLoginEmail: String?
    var lastLoginPassword: String?
    
    override func login(email: String, password: String) -> Result<User, Error> {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password
        return mockLoginResult
    }
}