// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Ensure ProcessPaymentUseCase is properly configured with payment gateway credentials
2. Set up proper error handling and logging for payment operations
3. Configure proper access control and authentication for payment operations
4. Set up monitoring and alerting for payment processing failures
*/

/// PaymentViewModel: Manages the state and business logic for the Payment screen
/// Requirements addressed:
/// - Payments (1.3 Scope/Core Features/Payments): Supports secure payment processing, automated billing, and receipt generation
class PaymentViewModel {
    // MARK: - Dependencies
    
    private let processPaymentUseCase: ProcessPaymentUseCase
    
    // MARK: - Published Properties
    
    /// Indicates whether a payment is currently being processed
    @Published private(set) var isProcessing: Bool = false
    
    /// Contains error message if payment processing fails
    @Published private(set) var errorMessage: String?
    
    // MARK: - Constants
    
    private enum LogMessages {
        static let startProcessing = "Starting payment processing"
        static let processingSuccess = "Payment processing completed successfully"
        static let processingError = "Payment processing failed"
    }
    
    // MARK: - Initialization
    
    /// Initializes the PaymentViewModel with required dependencies
    /// - Parameter processPaymentUseCase: Use case for processing payments
    init(processPaymentUseCase: ProcessPaymentUseCase) {
        self.processPaymentUseCase = processPaymentUseCase
    }
    
    // MARK: - Payment Processing
    
    /// Processes a payment and updates the UI state accordingly
    /// - Parameter payment: The payment to process
    func processPayment(_ payment: Payment) {
        // Log the start of payment processing
        Logger.log(LogMessages.startProcessing)
        
        // Update UI state to show processing
        isProcessing = true
        errorMessage = nil
        
        // Process the payment using the use case
        let result = processPaymentUseCase.processPayment(payment: payment)
        
        switch result {
        case .success(_):
            // Payment successful
            Logger.log(LogMessages.processingSuccess)
            isProcessing = false
            errorMessage = nil
            
        case .failure(let error):
            // Payment failed
            Logger.log("\(LogMessages.processingError): \(error.localizedDescription)")
            isProcessing = false
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Error Handling Extension

private extension PaymentViewModel {
    /// Formats error messages for display in the UI
    /// - Parameter error: The APIError to format
    /// - Returns: A user-friendly error message
    func formatErrorMessage(_ error: APIError) -> String {
        if let statusCode = error.statusCode {
            return "Payment failed (Error \(statusCode)): \(error.message)"
        }
        return "Payment failed: \(error.message)"
    }
}