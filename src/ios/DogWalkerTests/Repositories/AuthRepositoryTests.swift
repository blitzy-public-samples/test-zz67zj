// XCTest framework - Latest
import XCTest
@testable import DogWalker

/// AuthRepositoryTests: Unit tests for the AuthRepository class
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Ensures the correctness of user authentication and registration processes
/// - Secure Data Storage (Technical Specification/10.2 Data Security/10.2.2 Encryption Framework): Validates secure storage and retrieval of sensitive data
class AuthRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var authRepository: AuthRepository!
    private var mockAPIClient: MockAPIClient!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        authRepository = AuthRepository(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        authRepository = nil
        mockAPIClient = nil
        // Clean up any stored tokens
        _ = KeychainWrapper.delete(key: "auth_token")
        super.tearDown()
    }
    
    // MARK: - Login Tests
    
    func testLoginSuccess() {
        // Prepare test data
        let email = "test@example.com"
        let password = "Password123"
        let expectedToken = "test_token_123"
        let expectedUser = User(
            id: "user123",
            name: "Test User",
            email: email,
            phone: "+1234567890",
            role: "owner",
            walks: [],
            payments: [],
            currentLocation: Location(latitude: 0, longitude: 0)
        )
        
        // Configure mock response
        let responseData: [String: Any] = [
            "token": expectedToken,
            "user": [
                "id": expectedUser.id,
                "name": expectedUser.name,
                "email": expectedUser.email,
                "phone": expectedUser.phone,
                "role": expectedUser.role
            ]
        ]
        mockAPIClient.mockResponse = try? JSONSerialization.data(withJSONObject: responseData)
        
        // Perform login
        let result = authRepository.login(email: email, password: password)
        
        // Verify results
        switch result {
        case .success(let user):
            XCTAssertEqual(user.id, expectedUser.id)
            XCTAssertEqual(user.email, expectedUser.email)
            XCTAssertEqual(user.name, expectedUser.name)
            XCTAssertEqual(user.phone, expectedUser.phone)
            XCTAssertEqual(user.role, expectedUser.role)
            
            // Verify token was stored securely
            let storedToken = KeychainWrapper.retrieve(key: "auth_token")
            XCTAssertEqual(storedToken, expectedToken)
            
        case .failure(let error):
            XCTFail("Login should succeed but failed with error: \(error)")
        }
    }
    
    func testLoginFailureInvalidCredentials() {
        // Configure mock response for authentication failure
        let errorData: [String: Any] = [
            "error": "Invalid credentials"
        ]
        mockAPIClient.mockResponse = try? JSONSerialization.data(withJSONObject: errorData)
        mockAPIClient.mockError = APIError(message: "Invalid credentials")
        
        // Perform login with invalid credentials
        let result = authRepository.login(email: "wrong@email.com", password: "wrongpass")
        
        // Verify failure
        switch result {
        case .success:
            XCTFail("Login should fail with invalid credentials")
        case .failure(let error):
            XCTAssertTrue(error is APIError)
            XCTAssertEqual((error as? APIError)?.message, "Invalid credentials")
            
            // Verify no token was stored
            let storedToken = KeychainWrapper.retrieve(key: "auth_token")
            XCTAssertNil(storedToken)
        }
    }
    
    // MARK: - Registration Tests
    
    func testRegistrationSuccess() {
        // Prepare test data
        let name = "New User"
        let email = "newuser@example.com"
        let password = "NewPass123"
        let phone = "+1987654321"
        let role = "walker"
        let expectedToken = "new_user_token_123"
        
        // Configure mock response
        let responseData: [String: Any] = [
            "token": expectedToken,
            "user": [
                "id": "new_user_123",
                "name": name,
                "email": email,
                "phone": phone,
                "role": role
            ]
        ]
        mockAPIClient.mockResponse = try? JSONSerialization.data(withJSONObject: responseData)
        
        // Perform registration
        let result = authRepository.register(
            name: name,
            email: email,
            password: password,
            phoneNumber: phone,
            role: role
        )
        
        // Verify results
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, name)
            XCTAssertEqual(user.email, email)
            XCTAssertEqual(user.phone, phone)
            XCTAssertEqual(user.role, role)
            
            // Verify token was stored securely
            let storedToken = KeychainWrapper.retrieve(key: "auth_token")
            XCTAssertEqual(storedToken, expectedToken)
            
        case .failure(let error):
            XCTFail("Registration should succeed but failed with error: \(error)")
        }
    }
    
    func testRegistrationFailureExistingEmail() {
        // Configure mock response for existing email error
        let errorData: [String: Any] = [
            "error": "Email already exists"
        ]
        mockAPIClient.mockResponse = try? JSONSerialization.data(withJSONObject: errorData)
        mockAPIClient.mockError = APIError(message: "Email already exists")
        
        // Perform registration with existing email
        let result = authRepository.register(
            name: "Test User",
            email: "existing@example.com",
            password: "Password123",
            phoneNumber: "+1234567890",
            role: "owner"
        )
        
        // Verify failure
        switch result {
        case .success:
            XCTFail("Registration should fail with existing email")
        case .failure(let error):
            XCTAssertTrue(error is APIError)
            XCTAssertEqual((error as? APIError)?.message, "Email already exists")
            
            // Verify no token was stored
            let storedToken = KeychainWrapper.retrieve(key: "auth_token")
            XCTAssertNil(storedToken)
        }
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() {
        // Store a test token first
        XCTAssertTrue(KeychainWrapper.save(key: "auth_token", value: "test_token"))
        
        // Perform logout
        let result = authRepository.logout()
        
        // Verify results
        XCTAssertTrue(result)
        
        // Verify token was removed
        let storedToken = KeychainWrapper.retrieve(key: "auth_token")
        XCTAssertNil(storedToken)
    }
}

// MARK: - Mock API Client

private class MockAPIClient: APIClient {
    var mockResponse: Data?
    var mockError: Error?
    
    override func performRequest(
        endpoint: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        if let error = mockError {
            completion(.failure(error as! APIError))
        } else if let response = mockResponse {
            completion(.success(response))
        }
    }
}