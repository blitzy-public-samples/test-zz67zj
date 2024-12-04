// Foundation framework - Latest
import Foundation

/// LoginUseCase: Implements the login use case for authenticating users
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user authentication and login processes
class LoginUseCase {
    // MARK: - Human Tasks
    /*
    1. Ensure proper error tracking service is configured for authentication failures
    2. Review and implement proper token refresh mechanisms
    3. Configure proper timeout values for login operations
    */
    
    // MARK: - Properties
    
    private let authRepository: AuthRepository
    
    // MARK: - Initialization
    
    /// Initializes the LoginUseCase with required dependencies
    /// - Parameter authRepository: Repository handling authentication operations
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    // MARK: - Public Methods
    
    /// Executes the login use case by validating credentials and authenticating the user
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Result containing the authenticated User or an Error
    func execute(email: String, password: String) -> Result<User, Error> {
        // Log the start of login process
        Logger.info("Starting login process for email: \(email)")
        
        // Validate email format
        guard isValidEmail(email) else {
            Logger.error("Invalid email format: \(email)")
            return .failure(APIError(message: "Invalid email format"))
        }
        
        // Validate password
        guard isValidPassword(password) else {
            Logger.error("Invalid password format")
            return .failure(APIError(message: "Invalid password format"))
        }
        
        // Attempt login through repository
        let result = authRepository.login(email: email, password: password)
        
        // Log the result
        switch result {
        case .success(let user):
            Logger.info("Login successful for user: \(user.id)")
        case .failure(let error):
            Logger.error("Login failed: \(error.localizedDescription)")
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    /// Validates email format using regex
    /// - Parameter email: Email address to validate
    /// - Returns: Boolean indicating if the email format is valid
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates password meets minimum requirements
    /// - Parameter password: Password to validate
    /// - Returns: Boolean indicating if the password meets requirements
    private func isValidPassword(_ password: String) -> Bool {
        // Password must be at least 8 characters
        guard password.count >= 8 else {
            return false
        }
        
        // Password must contain at least one uppercase letter
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else {
            return false
        }
        
        // Password must contain at least one lowercase letter
        guard password.range(of: "[a-z]", options: .regularExpression) != nil else {
            return false
        }
        
        // Password must contain at least one number
        guard password.range(of: "[0-9]", options: .regularExpression) != nil else {
            return false
        }
        
        return true
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension LoginUseCase {
    /// Tests the login use case with various scenarios
    func runTests() {
        // Test invalid email
        let invalidEmailResult = execute(email: "invalid-email", password: "ValidPass123")
        assert(invalidEmailResult.isFailure)
        
        // Test invalid password
        let invalidPasswordResult = execute(email: "test@example.com", password: "weak")
        assert(invalidPasswordResult.isFailure)
        
        Logger.debug("LoginUseCase tests completed")
    }
}
#endif