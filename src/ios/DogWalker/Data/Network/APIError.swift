// Foundation framework - Latest
import Foundation

/// APIError: Structured error handling for API interactions
/// Requirements addressed:
/// - Error Handling (8.3.2/API Specifications): Standardized error handling for API responses
class APIError: LocalizedError {
    // MARK: - Properties
    
    /// The error message describing what went wrong
    let message: String
    
    /// The HTTP status code associated with the error (if applicable)
    let statusCode: Int?
    
    /// The underlying system error that caused this API error (if any)
    let underlyingError: Error?
    
    // MARK: - Initialization
    
    /// Initializes a new APIError instance
    /// - Parameters:
    ///   - message: A descriptive message about the error
    ///   - statusCode: Optional HTTP status code associated with the error
    ///   - underlyingError: Optional underlying error that caused this API error
    init(message: String, statusCode: Int? = nil, underlyingError: Error? = nil) {
        self.message = message
        self.statusCode = statusCode
        self.underlyingError = underlyingError
    }
    
    // MARK: - LocalizedError Conformance
    
    /// Provides a user-friendly description of the error
    /// - Returns: A formatted string containing the error details
    override var errorDescription: String? {
        var description = ""
        
        if let code = statusCode {
            description += "[Status Code: \(code)] "
        }
        
        description += message
        
        if let underlying = underlyingError {
            description += "\nCaused by: \(underlying.localizedDescription)"
        }
        
        return description
    }
    
    /// Provides backward compatibility with NSError's localizedDescription
    override var localizedDescription: String {
        return errorDescription ?? message
    }
}