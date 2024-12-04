// Foundation framework - Latest
import Foundation

// Internal imports using relative paths
import "../../../Domain/Entities/User"
import "../../../Data/Repositories/UserRepository"
import "../../../Domain/UseCases/Auth/LogoutUseCase"
import "../../../Utilities/Logger"

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure proper error tracking service is configured for profile operations
2. Review and implement proper data retention policies for user data
3. Configure proper logging levels based on environment
*/

/// ProfileViewModel manages the state and logic for the Profile screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user profile management
/// - Centralized Logging (7.4.1 Monitoring and Observability): Ensures consistent logging
/// - Data Security (10.2.2 Encryption Framework): Secure logout handling
class ProfileViewModel {
    
    // MARK: - Properties
    
    /// The current user profile data
    private(set) var user: User?
    
    /// Loading state indicator
    private(set) var isLoading: Bool = false
    
    /// Error message for displaying to the user
    private(set) var errorMessage: String?
    
    /// Repository for user data operations
    private let userRepository: UserRepository
    
    /// Use case for handling logout operations
    private let logoutUseCase: LogoutUseCase
    
    // MARK: - Initialization
    
    /// Initializes the ProfileViewModel with required dependencies
    /// - Parameters:
    ///   - userRepository: Repository for user data operations
    ///   - logoutUseCase: Use case for handling logout operations
    init(userRepository: UserRepository, logoutUseCase: LogoutUseCase) {
        self.userRepository = userRepository
        self.logoutUseCase = logoutUseCase
    }
    
    // MARK: - Public Methods
    
    /// Fetches the user profile data from the repository
    /// - Parameter userId: The ID of the user to fetch
    func fetchUserProfile(userId: String) {
        Logger.info("Fetching user profile for ID: \(userId)")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedUser = try await userRepository.fetchUserById(userId)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let user = fetchedUser {
                        self.user = user
                        Logger.info("Successfully fetched user profile: \(user.id)")
                    } else {
                        self.errorMessage = "User not found"
                        Logger.warning("User not found for ID: \(userId)")
                    }
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.errorMessage = "Failed to fetch user profile"
                    self.isLoading = false
                    Logger.error("Failed to fetch user profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Updates the user profile data in the repository
    /// - Parameter user: The updated user data to save
    func updateUserProfile(user: User) {
        Logger.info("Updating user profile for ID: \(user.id)")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await userRepository.saveUser(user)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.user = user
                    self.isLoading = false
                    Logger.info("Successfully updated user profile: \(user.id)")
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.errorMessage = "Failed to update user profile"
                    self.isLoading = false
                    Logger.error("Failed to update user profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Logs out the current user by securely removing authentication tokens
    /// - Returns: Boolean indicating whether the logout was successful
    func logout() -> Bool {
        Logger.info("Initiating user logout")
        
        let result = logoutUseCase.execute()
        
        if result {
            user = nil
            Logger.info("User logout successful")
        } else {
            errorMessage = "Failed to logout"
            Logger.error("User logout failed")
        }
        
        return result
    }
}