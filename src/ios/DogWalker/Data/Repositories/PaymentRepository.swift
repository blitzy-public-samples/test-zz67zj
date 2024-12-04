// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure API endpoints for payment operations in environment configuration
2. Set up proper error handling and logging for payment operations
3. Implement proper security measures for handling sensitive payment data
4. Configure proper access control and authentication for payment operations
5. Set up monitoring and alerting for payment processing failures
*/

/// PaymentRepository: Manages payment-related data operations in the Dog Walker application
/// Requirements addressed:
/// - Payments (1.3 Scope/Core Features/Payments): Supports secure payment processing, automated billing, and receipt generation
class PaymentRepository {
    // MARK: - Properties
    
    /// APIClient instance for making network requests
    private let apiClient: APIClient
    
    // MARK: - Constants
    
    private enum Endpoints {
        static let createPayment = "/payments/create"
        static let updatePaymentStatus = "/payments/status"
    }
    
    // MARK: - Initialization
    
    /// Initializes the PaymentRepository with an APIClient instance
    /// - Parameter apiClient: The APIClient instance to use for network requests
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Payment Operations
    
    /// Creates a new payment record in the system
    /// - Parameter payment: The payment object containing payment details
    /// - Returns: A Result containing the created Payment object or an APIError
    func createPayment(payment: Payment) -> Result<Payment, APIError> {
        // Create a completion handler to handle the async result
        var result: Result<Payment, APIError>!
        let semaphore = DispatchSemaphore(value: 0)
        
        // Construct payment parameters
        let parameters: [String: Any] = [
            "id": payment.id,
            "amount": payment.amount,
            "status": payment.status,
            "payer_id": payment.payer.id,
            "payee_id": payment.payee.id,
            "booking_id": payment.booking.id,
            "walk_id": payment.walk.id,
            "timestamp": ISO8601DateFormatter().string(from: payment.timestamp),
            "currency": payment.currency
        ]
        
        // Make the API request
        apiClient.performRequest(
            endpoint: Endpoints.createPayment,
            parameters: parameters
        ) { apiResult in
            switch apiResult {
            case .success(let data):
                do {
                    // Attempt to decode the response data into a Payment object
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let paymentResponse = try decoder.decode(Payment.self, from: data)
                    result = .success(paymentResponse)
                } catch {
                    result = .failure(APIError(
                        message: "Failed to decode payment response",
                        statusCode: nil,
                        underlyingError: error
                    ))
                }
                
            case .failure(let error):
                result = .failure(error)
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    /// Updates the status of an existing payment record
    /// - Parameters:
    ///   - paymentId: The ID of the payment to update
    ///   - newStatus: The new status to set for the payment
    /// - Returns: A Result indicating success or failure with an APIError
    func updatePaymentStatus(paymentId: String, newStatus: String) -> Result<Void, APIError> {
        // Create a completion handler to handle the async result
        var result: Result<Void, APIError>!
        let semaphore = DispatchSemaphore(value: 0)
        
        // Construct status update parameters
        let parameters: [String: Any] = [
            "payment_id": paymentId,
            "status": newStatus
        ]
        
        // Make the API request
        apiClient.performRequest(
            endpoint: Endpoints.updatePaymentStatus,
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