// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure proper error tracking service for monitoring login and booking operations
2. Set up proper logging for user session management
3. Review and implement proper data retention policies for user data
4. Configure proper caching strategy for frequently accessed booking data
*/

/// HomeViewModel: Manages the state and business logic for the Home screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user profile management and role-based access
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports booking management and schedule coordination
class HomeViewModel {
    // MARK: - Dependencies
    
    private let loginUseCase: LoginUseCase
    private let getBookingsUseCase: GetBookingsUseCase
    
    // MARK: - State
    
    /// Current user state
    private(set) var currentUser: User?
    
    /// Current bookings state
    private(set) var bookings: [Booking] = []
    
    /// Loading state
    private(set) var isLoading: Bool = false
    
    /// Error state
    private(set) var error: Error?
    
    // MARK: - State Change Handlers
    
    /// Closure called when the user state changes
    var onUserStateChanged: ((User?) -> Void)?
    
    /// Closure called when the bookings state changes
    var onBookingsChanged: (([Booking]) -> Void)?
    
    /// Closure called when the loading state changes
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    /// Closure called when an error occurs
    var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    
    /// Initializes the HomeViewModel with required dependencies
    /// - Parameters:
    ///   - loginUseCase: Use case for handling user authentication
    ///   - getBookingsUseCase: Use case for fetching bookings
    init(loginUseCase: LoginUseCase, getBookingsUseCase: GetBookingsUseCase) {
        self.loginUseCase = loginUseCase
        self.getBookingsUseCase = getBookingsUseCase
    }
    
    // MARK: - Public Methods
    
    /// Logs in the user with the provided credentials
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func loginUser(email: String, password: String) {
        Logger.log("Starting login process for user: \(email)")
        
        // Update loading state
        updateLoadingState(true)
        
        // Attempt login
        let result = loginUseCase.execute(email: email, password: password)
        
        switch result {
        case .success(let user):
            // Update user state
            currentUser = user
            onUserStateChanged?(user)
            
            // Log success
            Logger.info("User logged in successfully: \(user.id)")
            
            // Fetch bookings after successful login
            fetchBookings()
            
        case .failure(let error):
            // Update error state
            self.error = error
            onError?(error)
            
            // Log error
            Logger.error("Login failed: \(error.localizedDescription)")
        }
        
        // Update loading state
        updateLoadingState(false)
    }
    
    /// Fetches bookings for the current user
    func fetchBookings() {
        Logger.log("Fetching bookings")
        
        // Update loading state
        updateLoadingState(true)
        
        // Fetch bookings
        getBookingsUseCase.execute { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let bookings):
                // Update bookings state
                self.bookings = bookings
                self.onBookingsChanged?(bookings)
                
                // Log success
                Logger.info("Successfully fetched \(bookings.count) bookings")
                
            case .failure(let error):
                // Update error state
                self.error = error
                self.onError?(error)
                
                // Log error
                Logger.error("Failed to fetch bookings: \(error.localizedDescription)")
            }
            
            // Update loading state
            self.updateLoadingState(false)
        }
    }
    
    // MARK: - Private Methods
    
    /// Updates the loading state and notifies observers
    /// - Parameter isLoading: New loading state
    private func updateLoadingState(_ isLoading: Bool) {
        self.isLoading = isLoading
        onLoadingStateChanged?(isLoading)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension HomeViewModel {
    /// Tests the view model with various scenarios
    func runTests() {
        // Test invalid login
        loginUser(email: "invalid-email", password: "weak")
        assert(error != nil, "Invalid login should produce an error")
        
        // Test valid login
        loginUser(email: "test@example.com", password: "ValidPass123")
        assert(currentUser != nil, "Valid login should set current user")
        
        // Test bookings fetch
        fetchBookings()
        assert(!bookings.isEmpty, "Bookings should be populated after fetch")
        
        Logger.debug("HomeViewModel tests completed")
    }
}
#endif