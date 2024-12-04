/**
 * Human Tasks:
 * 1. Ensure the database schema matches the Payment model properties
 * 2. Configure ProGuard rules to prevent obfuscation of this data class if using R8/ProGuard
 * 3. Verify that the payment method values match the payment gateway integration requirements
 * 4. Ensure proper decimal precision configuration for amount in the database
 */

package com.dogwalker.app.domain.model

/**
 * Represents a payment entity in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements the core payment data structure for handling secure payment processing,
 *   automated billing, and receipt generation.
 */
data class Payment(
    /**
     * Unique identifier for the payment transaction
     */
    val id: String,

    /**
     * Amount of the payment transaction
     */
    val amount: Double,

    /**
     * Payment method used (e.g., "credit_card", "debit_card", "paypal")
     */
    val method: String,

    /**
     * Current status of the payment
     */
    val status: String,

    /**
     * Unix timestamp of when the payment was processed
     */
    val timestamp: Long
) {
    init {
        require(id.isNotBlank()) { "Payment ID cannot be blank" }
        require(amount > 0) { "Payment amount must be greater than 0" }
        require(method in VALID_PAYMENT_METHODS) { "Invalid payment method" }
        require(status in VALID_PAYMENT_STATUSES) { "Invalid payment status" }
        require(timestamp > 0) { "Payment timestamp must be greater than 0" }
    }

    companion object {
        // Payment method constants
        const val METHOD_CREDIT_CARD = "credit_card"
        const val METHOD_DEBIT_CARD = "debit_card"
        const val METHOD_PAYPAL = "paypal"

        // Payment status constants
        const val STATUS_PENDING = "pending"
        const val STATUS_PROCESSING = "processing"
        const val STATUS_COMPLETED = "completed"
        const val STATUS_FAILED = "failed"
        const val STATUS_REFUNDED = "refunded"

        private val VALID_PAYMENT_METHODS = setOf(
            METHOD_CREDIT_CARD,
            METHOD_DEBIT_CARD,
            METHOD_PAYPAL
        )

        private val VALID_PAYMENT_STATUSES = setOf(
            STATUS_PENDING,
            STATUS_PROCESSING,
            STATUS_COMPLETED,
            STATUS_FAILED,
            STATUS_REFUNDED
        )

        /**
         * Minimum allowed payment amount in the system
         */
        const val MIN_PAYMENT_AMOUNT = 0.01
    }
}