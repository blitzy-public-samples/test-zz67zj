package com.dogwalker.app.data.repository

// External imports - kotlinx.coroutines v1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

// Internal imports
import com.dogwalker.app.data.api.ApiService
import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.domain.model.Payment

/**
 * Human Tasks:
 * 1. Verify payment gateway integration configuration in the backend
 * 2. Ensure proper error handling for payment failures
 * 3. Configure payment retry mechanisms
 * 4. Set up payment notification handlers
 */

/**
 * Repository class that handles payment-related operations including database interactions
 * and API calls.
 *
 * Requirements addressed:
 * - Payments (1.3 Scope/Core Features/Payments)
 *   Implements secure payment processing, automated billing, and receipt generation
 *   through integration with the backend payment service.
 */
class PaymentRepository(
    private val apiService: ApiService,
    private val appDatabase: AppDatabase
) {
    /**
     * Processes a payment by validating details, saving to local database,
     * and sending to the backend API.
     *
     * Requirements addressed:
     * - Payments (1.3 Scope/Core Features/Payments)
     *   Implements the core payment processing flow with local persistence
     *   and backend synchronization.
     *
     * @param payment The payment details to process
     * @return Boolean indicating whether the payment was successfully processed
     */
    suspend fun processPayment(payment: Payment): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                // Validate payment details
                validatePayment(payment)

                // Save payment to local database
                val bookingDao = appDatabase.bookingDao()
                val bookingEntity = bookingDao.getAllBookings().find { 
                    it.paymentId == payment.id 
                }

                if (bookingEntity != null) {
                    // Update booking with payment information
                    bookingDao.updateBooking(
                        bookingEntity.copy(
                            paymentStatus = payment.status,
                            paymentAmount = payment.amount
                        )
                    )
                }

                // Send payment to backend API
                val booking = apiService.createBooking(
                    Booking(
                        id = bookingEntity?.id ?: "",
                        userId = bookingEntity?.userId ?: "",
                        userName = bookingEntity?.userName ?: "",
                        dogId = bookingEntity?.dogId ?: "",
                        dogName = bookingEntity?.dogName ?: "",
                        dogBreed = bookingEntity?.dogBreed ?: "",
                        walkDate = bookingEntity?.walkDate ?: "",
                        walkTime = bookingEntity?.walkTime ?: "",
                        paymentId = payment.id,
                        paymentStatus = payment.status,
                        paymentAmount = payment.amount,
                        status = bookingEntity?.status ?: "",
                        timestamp = payment.timestamp
                    )
                )

                // Return true if both database update and API call succeed
                booking != null
            } catch (e: Exception) {
                // Log error and return false
                false
            }
        }
    }

    /**
     * Retrieves the current status of a payment from the backend API.
     *
     * Requirements addressed:
     * - Payments (1.3 Scope/Core Features/Payments)
     *   Implements payment status tracking functionality.
     *
     * @param paymentId The unique identifier of the payment
     * @return The current status of the payment
     */
    suspend fun getPaymentStatus(paymentId: String): String {
        return withContext(Dispatchers.IO) {
            try {
                // Query local database first
                val bookingDao = appDatabase.bookingDao()
                val bookingEntity = bookingDao.getAllBookings().find { 
                    it.paymentId == paymentId 
                }

                // Return local status if available and recent
                if (bookingEntity != null && isStatusRecent(bookingEntity.timestamp)) {
                    return@withContext bookingEntity.paymentStatus
                }

                // Otherwise fetch from API
                val booking = apiService.createBooking(
                    Booking(
                        id = bookingEntity?.id ?: "",
                        userId = bookingEntity?.userId ?: "",
                        userName = bookingEntity?.userName ?: "",
                        dogId = bookingEntity?.dogId ?: "",
                        dogName = bookingEntity?.dogName ?: "",
                        dogBreed = bookingEntity?.dogBreed ?: "",
                        walkDate = bookingEntity?.walkDate ?: "",
                        walkTime = bookingEntity?.walkTime ?: "",
                        paymentId = paymentId,
                        paymentStatus = bookingEntity?.paymentStatus ?: "",
                        paymentAmount = bookingEntity?.paymentAmount ?: 0.0,
                        status = bookingEntity?.status ?: "",
                        timestamp = System.currentTimeMillis()
                    )
                )

                // Update local database with latest status
                if (booking != null && bookingEntity != null) {
                    bookingDao.updateBooking(
                        bookingEntity.copy(
                            paymentStatus = booking.paymentStatus,
                            timestamp = booking.timestamp
                        )
                    )
                }

                booking?.paymentStatus ?: Payment.STATUS_FAILED
            } catch (e: Exception) {
                // Return failed status on error
                Payment.STATUS_FAILED
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
        require(payment.amount > 0) { "Payment amount must be greater than 0" }
        require(payment.method in VALID_PAYMENT_METHODS) { "Invalid payment method" }
        require(payment.status in VALID_PAYMENT_STATUSES) { "Invalid payment status" }
        require(payment.timestamp > 0) { "Payment timestamp must be greater than 0" }
    }

    /**
     * Checks if a status timestamp is recent enough to be considered valid.
     *
     * @param timestamp The timestamp to check
     * @return Boolean indicating if the timestamp is recent
     */
    private fun isStatusRecent(timestamp: Long): Boolean {
        val currentTime = System.currentTimeMillis()
        val timeDifference = currentTime - timestamp
        return timeDifference <= STATUS_CACHE_DURATION
    }

    companion object {
        // Valid payment methods
        private val VALID_PAYMENT_METHODS = setOf(
            Payment.METHOD_CREDIT_CARD,
            Payment.METHOD_DEBIT_CARD,
            Payment.METHOD_PAYPAL
        )

        // Valid payment statuses
        private val VALID_PAYMENT_STATUSES = setOf(
            Payment.STATUS_PENDING,
            Payment.STATUS_PROCESSING,
            Payment.STATUS_COMPLETED,
            Payment.STATUS_FAILED,
            Payment.STATUS_REFUNDED
        )

        // Cache duration for payment status (5 minutes)
        private const val STATUS_CACHE_DURATION = 5 * 60 * 1000L
    }
}