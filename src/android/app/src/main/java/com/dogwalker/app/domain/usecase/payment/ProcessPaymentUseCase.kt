package com.dogwalker.app.domain.usecase.payment

// External imports - kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

// Internal imports
import com.dogwalker.app.data.repository.PaymentRepository
import com.dogwalker.app.domain.model.Payment
import com.dogwalker.app.domain.model.User

/**
 * Human Tasks:
 * 1. Verify payment gateway integration configuration in the backend
 * 2. Ensure proper error handling for payment failures
 * 3. Configure payment retry mechanisms
 * 4. Set up payment notification handlers
 */

/**
 * Use case class that handles the business logic for processing payments.
 *
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements secure payment processing, automated billing, and receipt generation
 *   through integration with the PaymentRepository.
 */
class ProcessPaymentUseCase(
    private val paymentRepository: PaymentRepository
) {
    /**
     * Processes a payment by validating the payment details and interacting with the PaymentRepository.
     *
     * Requirements addressed:
     * - Payments (1.3 Scope/Core Features/Payments)
     *   Implements the core payment processing flow with validation and error handling.
     *
     * @param payment The payment details to process
     * @return Boolean indicating whether the payment was successfully processed
     */
    suspend fun processPayment(payment: Payment): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                // Validate payment details
                validatePayment(payment)

                // Process payment through repository
                paymentRepository.processPayment(payment)
            } catch (e: Exception) {
                // Log error and return false
                false
            }
        }
    }

    /**
     * Validates payment details before processing.
     *
     * @param payment The payment to validate
     * @throws IllegalArgumentException if payment details are invalid
     */
    private fun validatePayment(payment: Payment) {
        require(payment.id.isNotBlank()) { "Payment ID cannot be blank" }
        require(payment.amount > Payment.MIN_PAYMENT_AMOUNT) { "Payment amount must be greater than ${Payment.MIN_PAYMENT_AMOUNT}" }
        require(payment.method in VALID_PAYMENT_METHODS) { "Invalid payment method: ${payment.method}" }
        require(payment.status in VALID_PAYMENT_STATUSES) { "Invalid payment status: ${payment.status}" }
        require(payment.timestamp > 0) { "Payment timestamp must be greater than 0" }
    }

    companion object {
        // Valid payment methods
        private val VALID_PAYMENT_METHODS = setOf(
            Payment.METHOD_CREDIT_CARD,
            Payment.METHOD_DEBIT_CARD,
            Payment.METHOD_PAYPAL
        )

        // Valid initial payment statuses
        private val VALID_PAYMENT_STATUSES = setOf(
            Payment.STATUS_PENDING,
            Payment.STATUS_PROCESSING
        )
    }
}