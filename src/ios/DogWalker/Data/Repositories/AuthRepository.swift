// Foundation framework - Latest
import Foundation

/// AuthRepository: Manages authentication-related operations for the Dog Walker iOS application
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user authentication and registration processes
/// - Secure Data Storage (Technical Specification/10.2 Data Security/10.2.2 Encryption Framework): Ensures secure token storage
class AuthRepository {
    // MARK: - Human Tasks
    /*
    1. Configure proper keychain access groups if needed for shared authentication state
    2. Set up proper SSL certificate pinning for authentication endpoints
    3. Configure error tracking service for authentication failures
    4. Review and implement proper token refresh mechanisms
    */
    
    // MARK: - Constants
    
    private enum KeychainKeys {
        static let authToken = "auth_token"
    }
    
    private enum APIEndpoints {
        static let login = "/auth/login"
        static let register = "/auth/register"
    }
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Authentication Methods
    
    /// Authenticates a user with their email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Result containing the authenticated User or an Error
    func login(email: String, password: String) -> Result<User, Error> {
        // Create a semaphore for synchronous API call
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<User, Error>!
        
        // Validate input parameters
        guard !email.isEmpty, !password.isEmpty else {
            return .failure(APIError(message: "Email and password cannot be empty"))
        }
        
        // Prepare request parameters
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // Perform login request
        apiClient.performRequest(endpoint: APIEndpoints.login, parameters: parameters) { response in
            switch response {
            case .success(let data):
                do {
                    // Parse response data
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let token = json["token"] as? String,
                          let userData = json["user"] as? [String: Any],
                          let userId = userData["id"] as? String,
                          let name = userData["name"] as? String,
                          let email = userData["email"] as? String,
                          let phone = userData["phone"] as? String,
                          let role = userData["role"] as? String else {
                        result = .failure(APIError(message: "Invalid response format"))
                        semaphore.signal()
                        return
                    }
                    
                    // Store authentication token securely
                    guard KeychainWrapper.save(key: KeychainKeys.authToken, value: token) else {
                        result = .failure(APIError(message: "Failed to save authentication token"))
                        semaphore.signal()
                        return
                    }
                    
                    // Create and return user instance
                    let user = User(
                        id: userId,
                        name: name,
                        email: email,
                        phone: phone,
                        role: role,
                        walks: [],
                        payments: [],
                        currentLocation: Location(latitude: 0, longitude: 0)
                    )
                    
                    result = .success(user)
                } catch {
                    result = .failure(APIError(message: "Failed to parse response", underlyingError: error))
                }
                
            case .failure(let error):
                result = .failure(error)
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 30)
        return result
    }
    
    /// Registers a new user with the provided details
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - password: User's password
    ///   - phoneNumber: User's phone number
    ///   - role: User's role in the system
    /// - Returns: Result containing the registered User or an Error
    func register(name: String, email: String, password: String, phoneNumber: String, role: String) -> Result<User, Error> {
        // Create a semaphore for synchronous API call
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<User, Error>!
        
        // Validate input parameters
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !phoneNumber.isEmpty, !role.isEmpty else {
            return .failure(APIError(message: "All registration fields are required"))
        }
        
        // Prepare request parameters
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "phone_number": phoneNumber,
            "role": role
        ]
        
        // Perform registration request
        apiClient.performRequest(endpoint: APIEndpoints.register, parameters: parameters) { response in
            switch response {
            case .success(let data):
                do {
                    // Parse response data
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let token = json["token"] as? String,
                          let userData = json["user"] as? [String: Any],
                          let userId = userData["id"] as? String else {
                        result = .failure(APIError(message: "Invalid response format"))
                        semaphore.signal()
                        return
                    }
                    
                    // Store authentication token securely
                    guard KeychainWrapper.save(key: KeychainKeys.authToken, value: token) else {
                        result = .failure(APIError(message: "Failed to save authentication token"))
                        semaphore.signal()
                        return
                    }
                    
                    // Create and return user instance
                    let user = User(
                        id: userId,
                        name: name,
                        email: email,
                        phone: phoneNumber,
                        role: role,
                        walks: [],
                        payments: [],
                        currentLocation: Location(latitude: 0, longitude: 0)
                    )
                    
                    result = .success(user)
                } catch {
                    result = .failure(APIError(message: "Failed to parse response", underlyingError: error))
                }
                
            case .failure(let error):
                result = .failure(error)
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 30)
        return result
    }
    
    /// Logs out the current user by removing their authentication token
    /// - Returns: Boolean indicating whether the logout was successful
    func logout() -> Bool {
        return KeychainWrapper.delete(key: KeychainKeys.authToken)
    }
}