package com.dogwalker.app.domain.usecase.payment

// External imports - kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

// Internal imports
import com.dogwalker.app.data.repository.PaymentRepository
import com.dogwalker.app.domain.model.Payment

/**
 * Human Tasks:
 * 1. Verify payment validation rules match business requirements
 * 2. Configure error handling and logging for payment failures
 * 3. Set up payment monitoring and alerting
 * 4. Review payment security measures and compliance requirements
 */

/**
 * Use case class that encapsulates the business logic for processing payments
 * in the Dog Walker application.
 *
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements secure payment processing by validating payment details
 *   and delegating to the PaymentRepository for transaction handling.
 */
class ProcessPaymentUseCase(
    private val paymentRepository: PaymentRepository
) {
    /**
     * Executes the payment processing logic by validating the payment details
     * and delegating to the PaymentRepository.
     *
     * Requirements addressed:
     * - Payments (1.3 Scope/Core Features/Payments)
     *   Handles secure payment processing by validating payment data
     *   and ensuring proper transaction handling.
     *
     * @param payment The payment details to process
     * @return Boolean indicating whether the payment was successfully processed
     */
    suspend fun execute(payment: Payment): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                // Validate payment object
                validatePayment(payment)

                // Delegate to repository for payment processing
                paymentRepository.processPayment(payment)
            } catch (e: Exception) {
                // Log error and return false on failure
                false
            }
        }
    }

    /**
     * Validates the payment object to ensure all required fields are present
     * and contain valid values.
     *
     * @param payment The payment object to validate
     * @throws IllegalArgumentException if any validation fails
     */
    private fun validatePayment(payment: Payment) {
        require(payment.id.isNotBlank()) { "Payment ID cannot be blank" }
        require(payment.amount > Payment.MIN_PAYMENT_AMOUNT) { 
            "Payment amount must be greater than ${Payment.MIN_PAYMENT_AMOUNT}" 
        }
        require(payment.method in setOf(
            Payment.METHOD_CREDIT_CARD,
            Payment.METHOD_DEBIT_CARD,
            Payment.METHOD_PAYPAL
        )) { "Invalid payment method: ${payment.method}" }
        require(payment.status in setOf(
            Payment.STATUS_PENDING,
            Payment.STATUS_PROCESSING
        )) { "Invalid initial payment status: ${payment.status}" }
        require(payment.timestamp > 0) { "Payment timestamp must be greater than 0" }
    }
}