package com.dogwalker.app.domain.usecase.booking

import com.dogwalker.app.data.repository.BookingRepository
import com.dogwalker.app.domain.model.Booking
import java.util.UUID
import javax.inject.Inject

/**
 * Human Tasks:
 * 1. Verify that the BookingRepository is properly configured with Room database
 * 2. Ensure proper error handling is implemented in the repository layer
 * 3. Configure unit tests for the use case with mock repository
 * 4. Verify that the date format validation matches the API contract
 */

/**
 * Use case for creating new bookings in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the business logic for creating new bookings, ensuring all required
 *   data is validated and properly persisted through the BookingRepository.
 */
class CreateBookingUseCase @Inject constructor(
    private val bookingRepository: BookingRepository
) {
    /**
     * Creates a new booking with the provided details.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Supports booking management by validating input parameters and creating
     *   new booking records with proper status tracking.
     *
     * @param userId ID of the user creating the booking
     * @param dogId ID of the dog to be walked
     * @param walkDate Date of the scheduled walk (format: YYYY-MM-DD)
     * @param paymentId ID of the associated payment transaction
     * @return The newly created Booking object
     * @throws IllegalArgumentException if any of the required parameters are invalid
     */
    suspend fun createBooking(
        userId: String,
        dogId: String,
        walkDate: String,
        paymentId: String
    ): Booking {
        // Validate input parameters
        validateInputParameters(userId, dogId, walkDate, paymentId)

        // Create a new Booking object with default values
        val booking = Booking(
            id = generateBookingId(),
            userId = userId,
            userName = "", // Will be populated by repository layer
            dogId = dogId,
            dogName = "", // Will be populated by repository layer
            dogBreed = "", // Will be populated by repository layer
            walkDate = walkDate,
            walkTime = "12:00", // Default time, should be updated with actual scheduled time
            paymentId = paymentId,
            paymentStatus = Booking.PAYMENT_STATUS_PENDING,
            paymentAmount = 0.0, // Will be updated based on service pricing
            status = Booking.STATUS_PENDING,
            timestamp = System.currentTimeMillis()
        )

        // Persist the booking through the repository
        bookingRepository.insertBooking(booking)

        return booking
    }

    /**
     * Validates the input parameters for creating a new booking.
     *
     * @param userId ID of the user creating the booking
     * @param dogId ID of the dog to be walked
     * @param walkDate Date of the scheduled walk
     * @param paymentId ID of the associated payment transaction
     * @throws IllegalArgumentException if any parameter is invalid
     */
    private fun validateInputParameters(
        userId: String,
        dogId: String,
        walkDate: String,
        paymentId: String
    ) {
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(dogId.isNotBlank()) { "Dog ID cannot be blank" }
        require(paymentId.isNotBlank()) { "Payment ID cannot be blank" }
        
        // Validate walk date format (YYYY-MM-DD)
        require(walkDate.matches(DATE_REGEX)) { 
            "Walk date must be in YYYY-MM-DD format" 
        }

        // Validate that the walk date is not in the past
        val currentDate = java.time.LocalDate.now().toString()
        require(walkDate >= currentDate) { 
            "Walk date cannot be in the past" 
        }
    }

    /**
     * Generates a unique booking ID using UUID.
     *
     * @return A unique booking identifier
     */
    private fun generateBookingId(): String = UUID.randomUUID().toString()

    companion object {
        /**
         * Regular expression for validating date format (YYYY-MM-DD)
         */
        private val DATE_REGEX = Regex(
            "^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])\$"
        )
    }
}