// Combine framework - Latest
import Combine

// Internal imports with relative paths
import "../../../Domain/UseCases/Auth/RegisterUseCase"
import "../../../Utilities/Logger"

/// RegisterViewModel: Manages the state and logic for the user registration screen
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user registration and profile creation for dog owners and walkers
class RegisterViewModel: ObservableObject {
    // MARK: - Human Tasks
    /*
    1. Configure proper validation rules for password strength
    2. Set up error tracking service for registration failures
    3. Review and implement proper data sanitization rules
    4. Configure analytics tracking for registration events
    */
    
    // MARK: - Published Properties
    
    @Published var name: String?
    @Published var email: String?
    @Published var password: String?
    @Published var phoneNumber: String?
    @Published var role: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let registerUseCase: RegisterUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initializes the RegisterViewModel with required dependencies
    /// - Parameter registerUseCase: The use case handling user registration
    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
        setupInitialState()
    }
    
    // MARK: - Private Methods
    
    /// Sets up the initial state of the ViewModel
    private func setupInitialState() {
        name = nil
        email = nil
        password = nil
        phoneNumber = nil
        role = nil
        isLoading = false
        errorMessage = nil
    }
    
    /// Validates the registration input fields
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - password: User's password
    ///   - phoneNumber: User's phone number
    ///   - role: User's role (owner/walker)
    /// - Returns: Boolean indicating whether the input is valid
    private func validateInput(
        name: String,
        email: String,
        password: String,
        phoneNumber: String,
        role: String
    ) -> Bool {
        // Validate name
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Name cannot be empty"
            return false
        }
        
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Invalid email format"
            return false
        }
        
        // Validate password strength
        guard password.count >= 8,
              password.rangeOfCharacter(from: .uppercaseLetters) != nil,
              password.rangeOfCharacter(from: .lowercaseLetters) != nil,
              password.rangeOfCharacter(from: .decimalDigits) != nil else {
            errorMessage = "Password must be at least 8 characters and contain uppercase, lowercase, and numbers"
            return false
        }
        
        // Validate phone number format
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        guard phonePredicate.evaluate(with: phoneNumber) else {
            errorMessage = "Invalid phone number format"
            return false
        }
        
        // Validate role
        let validRoles = ["owner", "walker"]
        guard validRoles.contains(role.lowercased()) else {
            errorMessage = "Role must be either 'owner' or 'walker'"
            return false
        }
        
        return true
    }
    
    // MARK: - Public Methods
    
    /// Initiates the user registration process
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - password: User's password
    ///   - phoneNumber: User's phone number
    ///   - role: User's role (owner/walker)
    func registerUser(
        name: String,
        email: String,
        password: String,
        phoneNumber: String,
        role: String
    ) {
        Logger.info("Starting registration process for user: \(email)")
        
        // Reset error message
        errorMessage = nil
        
        // Validate input
        guard validateInput(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            role: role
        ) else {
            Logger.error("Registration validation failed for user: \(email)")
            return
        }
        
        // Set loading state
        isLoading = true
        
        // Execute registration
        let result = registerUseCase.execute(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            role: role
        )
        
        // Handle result
        switch result {
        case .success(let user):
            Logger.info("Successfully registered user: \(user.email)")
            isLoading = false
            // Note: Further handling of successful registration (e.g., navigation)
            // should be implemented by the view layer
            
        case .failure(let error):
            Logger.error("Registration failed for user \(email): \(error.localizedDescription)")
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}