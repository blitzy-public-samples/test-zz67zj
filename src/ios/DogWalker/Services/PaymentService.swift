// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure payment gateway credentials in environment configuration
2. Set up proper error handling and logging for payment operations
3. Implement proper security measures for handling sensitive payment data
4. Configure proper access control and authentication for payment operations
5. Set up monitoring and alerting for payment processing failures
*/

/// PaymentService: Handles payment-related operations in the Dog Walker application
/// Requirements addressed:
/// - Payments (1.3 Scope/Core Features/Payments): Supports secure payment processing, automated billing, and receipt generation
class PaymentService {
    // MARK: - Properties
    
    private let apiClient: APIClient
    private let processPaymentUseCase: ProcessPaymentUseCase
    private let logger: Logger.Type
    
    // MARK: - Constants
    
    private enum PaymentEndpoint {
        static let initiate = "/payments/initiate"
        static let finalize = "/payments/finalize"
    }
    
    private enum LogMessages {
        static let initiatingPayment = "Initiating payment process"
        static let paymentInitiated = "Payment initiated successfully"
        static let paymentInitiationFailed = "Payment initiation failed"
        static let finalizingPayment = "Finalizing payment"
        static let paymentFinalized = "Payment finalized successfully"
        static let paymentFinalizationFailed = "Payment finalization failed"
        static let invalidStatus = "Invalid payment status provided"
    }
    
    // MARK: - Initialization
    
    /// Initializes the PaymentService with required dependencies
    /// - Parameters:
    ///   - apiClient: Client for making API requests
    ///   - processPaymentUseCase: Use case for processing payments
    ///   - logger: Logger for logging payment operations
    init(
        apiClient: APIClient,
        processPaymentUseCase: ProcessPaymentUseCase,
        logger: Logger.Type = Logger.self
    ) {
        self.apiClient = apiClient
        self.processPaymentUseCase = processPaymentUseCase
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    /// Initiates a payment by creating a payment record and sending it to the server
    /// - Parameter payment: The payment to initiate
    /// - Returns: A Result containing the initiated Payment object or an APIError
    func initiatePayment(payment: Payment) -> Result<Payment, APIError> {
        logger.info(LogMessages.initiatingPayment)
        
        // Validate payment details
        guard validatePayment(payment) else {
            let error = APIError(
                message: "Invalid payment details",
                statusCode: nil,
                underlyingError: nil
            )
            logger.error("\(LogMessages.paymentInitiationFailed): \(error.localizedDescription)")
            return .failure(error)
        }
        
        // Process the payment using the use case
        let result = processPaymentUseCase.processPayment(payment: payment)
        
        switch result {
        case .success(let processedPayment):
            logger.info(LogMessages.paymentInitiated)
            return .success(processedPayment)
            
        case .failure(let error):
            logger.error("\(LogMessages.paymentInitiationFailed): \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /// Finalizes a payment by updating its status to 'completed' or 'failed'
    /// - Parameters:
    ///   - payment: The payment to finalize
    ///   - newStatus: The new status to set for the payment
    /// - Returns: A Result containing the finalized Payment object or an APIError
    func finalizePayment(payment: Payment, newStatus: String) -> Result<Payment, APIError> {
        logger.info(LogMessages.finalizingPayment)
        
        // Validate the new status
        guard isValidPaymentStatus(newStatus) else {
            let error = APIError(
                message: LogMessages.invalidStatus,
                statusCode: nil,
                underlyingError: nil
            )
            logger.error("\(LogMessages.paymentFinalizationFailed): \(error.localizedDescription)")
            return .failure(error)
        }
        
        // Create parameters for the finalization request
        let parameters: [String: Any] = [
            "payment_id": payment.id,
            "status": newStatus
        ]
        
        // Create a completion handler to handle the async result
        var result: Result<Payment, APIError>!
        let semaphore = DispatchSemaphore(value: 0)
        
        // Make the API request to finalize the payment
        apiClient.performRequest(
            endpoint: PaymentEndpoint.finalize,
            parameters: parameters
        ) { apiResult in
            switch apiResult {
            case .success(let data):
                do {
                    // Attempt to decode the response data into a Payment object
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let finalizedPayment = try decoder.decode(Payment.self, from: data)
                    result = .success(finalizedPayment)
                    logger.info(LogMessages.paymentFinalized)
                } catch {
                    let apiError = APIError(
                        message: "Failed to decode payment response",
                        statusCode: nil,
                        underlyingError: error
                    )
                    result = .failure(apiError)
                    logger.error("\(LogMessages.paymentFinalizationFailed): \(apiError.localizedDescription)")
                }
                
            case .failure(let error):
                result = .failure(error)
                logger.error("\(LogMessages.paymentFinalizationFailed): \(error.localizedDescription)")
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    // MARK: - Private Helper Methods
    
    /// Validates the payment details
    /// - Parameter payment: The payment to validate
    /// - Returns: Boolean indicating if the payment is valid
    private func validatePayment(_ payment: Payment) -> Bool {
        // Validate amount
        guard payment.amount > 0 else {
            return false
        }
        
        // Validate status
        guard isValidPaymentStatus(payment.status) else {
            return false
        }
        
        return true
    }
    
    /// Validates if the payment status is valid
    /// - Parameter status: The status to validate
    /// - Returns: Boolean indicating if the status is valid
    private func isValidPaymentStatus(_ status: String) -> Bool {
        let validStatuses = ["pending", "processing", "completed", "failed", "refunded"]
        return validStatuses.contains(status)
    }
}