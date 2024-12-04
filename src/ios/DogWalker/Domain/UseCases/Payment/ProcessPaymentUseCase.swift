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

/// ProcessPaymentUseCase: Implements the use case for processing payments in the Dog Walker application
/// Requirements addressed:
/// - Payments (1.3 Scope/Core Features/Payments): Supports secure payment processing, automated billing, and receipt generation
class ProcessPaymentUseCase {
    // MARK: - Properties
    
    private let paymentRepository: PaymentRepository
    private let apiClient: APIClient
    
    // MARK: - Constants
    
    private enum PaymentEndpoint {
        static let process = "/payments/process"
    }
    
    private enum LogMessages {
        static let startProcessing = "Starting payment processing"
        static let validationFailed = "Payment validation failed"
        static let processingFailed = "Payment processing failed"
        static let processingSucceeded = "Payment processing succeeded"
    }
    
    // MARK: - Initialization
    
    /// Initializes the ProcessPaymentUseCase with required dependencies
    /// - Parameters:
    ///   - paymentRepository: Repository for payment-related data operations
    ///   - apiClient: Client for making API requests
    init(paymentRepository: PaymentRepository, apiClient: APIClient) {
        self.paymentRepository = paymentRepository
        self.apiClient = apiClient
    }
    
    // MARK: - Payment Processing
    
    /// Processes a payment by creating a payment record and updating its status upon completion
    /// - Parameter payment: The payment to process
    /// - Returns: A Result containing the processed Payment object or an APIError
    func processPayment(payment: Payment) -> Result<Payment, APIError> {
        // Log the start of payment processing
        print(LogMessages.startProcessing)
        
        // Validate payment details
        guard validatePayment(payment) else {
            print(LogMessages.validationFailed)
            return .failure(APIError(
                message: "Invalid payment details",
                statusCode: nil,
                underlyingError: nil
            ))
        }
        
        // Create payment record
        let createResult = paymentRepository.createPayment(payment: payment)
        
        switch createResult {
        case .success(let createdPayment):
            // Process payment through payment gateway
            let processResult = processPaymentWithGateway(createdPayment)
            
            switch processResult {
            case .success:
                // Update payment status to completed
                let updateResult = paymentRepository.updatePaymentStatus(
                    paymentId: createdPayment.id,
                    newStatus: "completed"
                )
                
                switch updateResult {
                case .success:
                    print(LogMessages.processingSucceeded)
                    return .success(createdPayment)
                    
                case .failure(let error):
                    print(LogMessages.processingFailed)
                    return .failure(error)
                }
                
            case .failure(let error):
                // Update payment status to failed
                _ = paymentRepository.updatePaymentStatus(
                    paymentId: createdPayment.id,
                    newStatus: "failed"
                )
                
                print(LogMessages.processingFailed)
                return .failure(error)
            }
            
        case .failure(let error):
            print(LogMessages.processingFailed)
            return .failure(error)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Validates the payment details
    /// - Parameter payment: The payment to validate
    /// - Returns: Boolean indicating if the payment is valid
    private func validatePayment(_ payment: Payment) -> Bool {
        // Validate amount
        guard payment.amount > 0 else {
            return false
        }
        
        // Validate payer and payee
        guard payment.payer.id.isEmpty == false,
              payment.payee.id.isEmpty == false,
              payment.payer.id != payment.payee.id else {
            return false
        }
        
        return true
    }
    
    /// Processes the payment through the payment gateway
    /// - Parameter payment: The payment to process
    /// - Returns: A Result indicating success or failure with an APIError
    private func processPaymentWithGateway(_ payment: Payment) -> Result<Void, APIError> {
        // Construct payment parameters for the gateway
        let parameters: [String: Any] = [
            "payment_id": payment.id,
            "amount": payment.amount,
            "payer_id": payment.payer.id,
            "payee_id": payment.payee.id
        ]
        
        // Create a completion handler to handle the async result
        var result: Result<Void, APIError>!
        let semaphore = DispatchSemaphore(value: 0)
        
        // Make the API request to process the payment
        apiClient.performRequest(
            endpoint: PaymentEndpoint.process,
            parameters: parameters
        ) { apiResult in
            switch apiResult {
            case .success(_):
                result = .success(())
            case .failure(let error):
                result = .failure(error)
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
}