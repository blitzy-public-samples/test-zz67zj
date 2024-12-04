// Foundation framework - Latest
import Foundation

/// RegisterUseCase: Implements the registration process for new users in the Dog Walker application
/// Requirements addressed:
/// - User Management (1.3 Scope/Core Features/User Management): Supports user registration and profile creation
class RegisterUseCase {
    // MARK: - Human Tasks
    /*
    1. Ensure proper validation rules are configured for password strength
    2. Configure email validation patterns if needed
    3. Set up proper error tracking for registration failures
    4. Review and implement proper data sanitization rules
    */
    
    // MARK: - Properties
    
    private let authRepository: AuthRepository
    
    // MARK: - Initialization
    
    /// Initializes the RegisterUseCase with required dependencies
    /// - Parameter authRepository: Repository handling authentication operations
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    // MARK: - Public Methods
    
    /// Executes the user registration process
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - password: User's password
    ///   - phoneNumber: User's phone number
    ///   - role: User's role in the system (e.g., "owner" or "walker")
    /// - Returns: Result containing the registered User or an Error
    func execute(
        name: String,
        email: String,
        password: String,
        phoneNumber: String,
        role: String
    ) -> Result<User, Error> {
        // Validate input parameters
        do {
            try validateRegistrationInput(
                name: name,
                email: email,
                password: password,
                phoneNumber: phoneNumber,
                role: role
            )
        } catch {
            return .failure(error)
        }
        
        // Attempt registration through repository
        return authRepository.register(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            role: role
        )
    }
    
    // MARK: - Private Methods
    
    /// Validates the registration input parameters
    /// - Parameters:
    ///   - name: User's full name to validate
    ///   - email: User's email to validate
    ///   - password: User's password to validate
    ///   - phoneNumber: User's phone number to validate
    ///   - role: User's role to validate
    /// - Throws: ValidationError if any parameter is invalid
    private func validateRegistrationInput(
        name: String,
        email: String,
        password: String,
        phoneNumber: String,
        role: String
    ) throws {
        // Validate name
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidName("Name cannot be empty")
        }
        
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            throw ValidationError.invalidEmail("Invalid email format")
        }
        
        // Validate password strength
        guard password.count >= 8,
              password.rangeOfCharacter(from: .uppercaseLetters) != nil,
              password.rangeOfCharacter(from: .lowercaseLetters) != nil,
              password.rangeOfCharacter(from: .decimalDigits) != nil else {
            throw ValidationError.invalidPassword("Password must be at least 8 characters and contain uppercase, lowercase, and numbers")
        }
        
        // Validate phone number format
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        guard phonePredicate.evaluate(with: phoneNumber) else {
            throw ValidationError.invalidPhoneNumber("Invalid phone number format")
        }
        
        // Validate role
        let validRoles = ["owner", "walker"]
        guard validRoles.contains(role.lowercased()) else {
            throw ValidationError.invalidRole("Role must be either 'owner' or 'walker'")
        }
    }
}

// MARK: - ValidationError

/// Enumeration of possible validation errors during registration
private enum ValidationError: LocalizedError {
    case invalidName(String)
    case invalidEmail(String)
    case invalidPassword(String)
    case invalidPhoneNumber(String)
    case invalidRole(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidName(let message),
             .invalidEmail(let message),
             .invalidPassword(let message),
             .invalidPhoneNumber(let message),
             .invalidRole(let message):
            return message
        }
    }
}