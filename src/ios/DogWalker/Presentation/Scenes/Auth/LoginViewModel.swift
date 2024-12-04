// Foundation framework - Latest
import Foundation
// Combine framework - Latest
import Combine

/// LoginViewModel: Manages the state and logic for the login screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user authentication and login processes
class LoginViewModel: ObservableObject {
    // MARK: - Human Tasks
    /*
    1. Ensure proper error tracking service is configured for authentication failures
    2. Configure analytics tracking for login attempts and failures
    3. Review timeout values for login operations
    */
    
    // MARK: - Dependencies
    
    private let loginUseCase: LoginUseCase
    
    // MARK: - Published Properties
    
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initializes the LoginViewModel with required dependencies
    /// - Parameter loginUseCase: The use case responsible for handling login operations
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Public Methods
    
    /// Initiates the login process with the provided credentials
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func login(email: String, password: String) {
        // Log the start of login process
        Logger.log("Starting login process for email: \(email)")
        
        // Update loading state
        isLoading = true
        errorMessage = nil
        
        // Execute login use case
        let result = loginUseCase.execute(email: email, password: password)
        
        // Handle the result
        switch result {
        case .success(let user):
            Logger.log("Login successful for user: \(user.id)")
            isLoggedIn = true
            
        case .failure(let error):
            Logger.log("Login failed: \(error.localizedDescription)", level: .error)
            errorMessage = error.localizedDescription
        }
        
        // Update loading state
        isLoading = false
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension LoginViewModel {
    /// Runs test scenarios for the login process
    func runTests() {
        // Test invalid credentials
        login(email: "invalid@email", password: "short")
        assert(!isLoggedIn)
        assert(errorMessage != nil)
        
        // Reset state
        isLoggedIn = false
        errorMessage = nil
        
        // Test valid credentials (note: requires mock LoginUseCase)
        login(email: "test@example.com", password: "ValidPass123")
        
        Logger.debug("LoginViewModel tests completed")
    }
}
#endif