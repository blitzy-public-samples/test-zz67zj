/**
 * Human Tasks:
 * 1. Verify that proper error handling is configured in the application
 * 2. Ensure that the coroutine scope is properly configured for database operations
 * 3. Configure unit tests for the use case with mock repository
 * 4. Verify that the booking validation rules match the business requirements
 */

package com.dogwalker.app.domain.usecase.booking

import com.dogwalker.app.data.repository.BookingRepository
import com.dogwalker.app.domain.model.Booking
import javax.inject.Inject

/**
 * Use case for creating new bookings in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the business logic for creating new bookings, including
 *   validation of booking data and delegation to the repository layer.
 */
class CreateBookingUseCase @Inject constructor(
    private val bookingRepository: BookingRepository
) {
    /**
     * Creates a new booking after validating the input data.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Supports booking management by providing functionality to create new bookings
     *   with proper validation and error handling.
     *
     * @param booking The booking object containing all required booking information
     * @throws IllegalArgumentException if any required fields are missing or invalid
     */
    suspend fun createBooking(booking: Booking) {
        // Validate required fields
        validateBooking(booking)

        // Insert the booking through the repository
        try {
            bookingRepository.insertBooking(booking)
        } catch (e: Exception) {
            throw BookingCreationException("Failed to create booking: ${e.message}", e)
        }
    }

    /**
     * Validates all required fields of a booking.
     *
     * @param booking The booking object to validate
     * @throws IllegalArgumentException if any validation fails
     */
    private fun validateBooking(booking: Booking) {
        require(booking.id.isNotBlank()) { "Booking ID cannot be blank" }
        require(booking.userId.isNotBlank()) { "User ID cannot be blank" }
        require(booking.userName.isNotBlank()) { "User name cannot be blank" }
        require(booking.dogId.isNotBlank()) { "Dog ID cannot be blank" }
        require(booking.dogName.isNotBlank()) { "Dog name cannot be blank" }
        require(booking.dogBreed.isNotBlank()) { "Dog breed cannot be blank" }
        
        // Validate walk date format (YYYY-MM-DD)
        require(booking.walkDate.matches(Regex("^\\d{4}-\\d{2}-\\d{2}$"))) { 
            "Invalid walk date format. Expected: YYYY-MM-DD" 
        }
        
        // Validate walk time format (HH:mm)
        require(booking.walkTime.matches(Regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$"))) {
            "Invalid walk time format. Expected: HH:mm"
        }
        
        require(booking.paymentId.isNotBlank()) { "Payment ID cannot be blank" }
        require(booking.paymentStatus in VALID_PAYMENT_STATUSES) {
            "Invalid payment status. Expected one of: ${VALID_PAYMENT_STATUSES.joinToString()}"
        }
        require(booking.paymentAmount > 0) { "Payment amount must be greater than 0" }
        require(booking.status in VALID_BOOKING_STATUSES) {
            "Invalid booking status. Expected one of: ${VALID_BOOKING_STATUSES.joinToString()}"
        }
        require(booking.timestamp > 0) { "Timestamp must be greater than 0" }
    }

    companion object {
        private val VALID_PAYMENT_STATUSES = setOf(
            "pending",
            "completed",
            "failed"
        )

        private val VALID_BOOKING_STATUSES = setOf(
            "pending",
            "confirmed",
            "in_progress",
            "completed",
            "cancelled"
        )
    }
}

/**
 * Custom exception for booking creation failures.
 */
class BookingCreationException(message: String, cause: Throwable? = null) : 
    Exception(message, cause)