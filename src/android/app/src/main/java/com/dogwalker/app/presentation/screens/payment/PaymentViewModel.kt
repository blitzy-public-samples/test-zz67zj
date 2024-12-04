/**
 * Human Tasks:
 * 1. Verify proper error handling and logging configuration for payment failures
 * 2. Ensure proper testing coverage for payment processing scenarios
 * 3. Configure payment analytics tracking
 * 4. Review payment-related security measures
 */

package com.dogwalker.app.presentation.screens.payment

// External imports
import androidx.lifecycle.ViewModel  // version: 2.6.1
import androidx.lifecycle.LiveData  // version: 2.6.1
import androidx.lifecycle.MutableLiveData  // version: 2.6.1
import kotlinx.coroutines.CoroutineScope  // version: 1.6.4
import kotlinx.coroutines.Dispatchers  // version: 1.6.4
import kotlinx.coroutines.launch  // version: 1.6.4

// Internal imports
import com.dogwalker.app.domain.usecase.payment.ProcessPaymentUseCase
import com.dogwalker.app.domain.model.Payment

/**
 * ViewModel class that manages the state and logic for the PaymentScreen.
 *
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements secure payment processing and automated billing through
 *   integration with the ProcessPaymentUseCase.
 * - User Interface Design (8.1 User Interface Design/8.1.1 Design Specifications)
 *   Ensures consistent state management and interaction logic for payment-related
 *   UI components.
 */
class PaymentViewModel(
    private val processPaymentUseCase: ProcessPaymentUseCase
) : ViewModel() {

    // Private mutable state
    private val _paymentStatus = MutableLiveData<Boolean>()

    // Public immutable state
    val paymentStatus: LiveData<Boolean> = _paymentStatus

    // Payment processing state
    private val _isProcessing = MutableLiveData<Boolean>()
    val isProcessing: LiveData<Boolean> = _isProcessing

    // Error state
    private val _error = MutableLiveData<String>()
    val error: LiveData<String> = _error

    /**
     * Initiates the payment processing workflow.
     *
     * Requirements addressed:
     * - Payments (1.3 Scope/Core Features/Payments)
     *   Handles secure payment processing by delegating to the ProcessPaymentUseCase
     *   and managing the UI state during the payment flow.
     *
     * @param payment The payment details to process
     */
    fun processPayment(payment: Payment) {
        _isProcessing.value = true
        _error.value = null

        CoroutineScope(Dispatchers.Main).launch {
            try {
                // Validate payment before processing
                validatePayment(payment)

                // Process payment through use case
                val result = processPaymentUseCase.processPayment(payment)

                // Update UI state based on result
                _paymentStatus.value = result
                _isProcessing.value = false
            } catch (e: IllegalArgumentException) {
                // Handle validation errors
                _error.value = e.message
                _paymentStatus.value = false
                _isProcessing.value = false
            } catch (e: Exception) {
                // Handle other errors
                _error.value = "Payment processing failed. Please try again."
                _paymentStatus.value = false
                _isProcessing.value = false
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
        require(payment.amount > Payment.MIN_PAYMENT_AMOUNT) { 
            "Payment amount must be greater than ${Payment.MIN_PAYMENT_AMOUNT}" 
        }
        require(payment.method in VALID_PAYMENT_METHODS) { 
            "Invalid payment method: ${payment.method}" 
        }
        require(payment.status in VALID_PAYMENT_STATUSES) { 
            "Invalid payment status: ${payment.status}" 
        }
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