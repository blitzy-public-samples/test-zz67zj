// Foundation framework - Latest
import Foundation

/// LogoutUseCase: Handles the user logout process by securely removing authentication tokens
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user logout functionality
/// - Data Security (Technical Specification/10.2 Data Security/10.2.2 Encryption Framework): Ensures secure token removal
class LogoutUseCase {
    
    // MARK: - Human Tasks
    /*
    1. Verify proper Keychain access group configuration if using shared keychain
    2. Ensure proper error tracking is configured for logout failures
    3. Review and implement any additional cleanup tasks needed during logout
    */
    
    // MARK: - Properties
    
    private let authRepository: AuthRepository
    
    // MARK: - Initialization
    
    /// Initializes the LogoutUseCase with required dependencies
    /// - Parameter authRepository: Repository handling authentication operations
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    // MARK: - Public Methods
    
    /// Executes the logout process by securely removing the authentication token
    /// - Returns: Boolean indicating whether the logout was successful
    func execute() -> Bool {
        // Log the logout attempt
        Logger.info("Attempting to logout user")
        
        // Perform the logout operation through the repository
        let result = authRepository.logout()
        
        // Log the result
        if result {
            Logger.info("User logout successful")
        } else {
            Logger.error("User logout failed")
        }
        
        return result
    }
}