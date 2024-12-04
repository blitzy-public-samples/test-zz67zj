/**
 * Human Tasks:
 * 1. Verify that the BookingRepository is properly configured in the dependency injection module
 * 2. Ensure proper error handling is implemented at the UI layer when consuming this use case
 * 3. Consider implementing pagination if the number of bookings grows large
 * 4. Configure unit tests for this use case with mock repository
 */

package com.dogwalker.app.domain.usecase.booking

import com.dogwalker.app.data.repository.BookingRepository
import com.dogwalker.app.domain.model.Booking
import javax.inject.Inject

/**
 * Use case that retrieves all booking records from the repository.
 * 
 * Requirements addressed:
 * - Booking Management (1.3 Scope/Core Features/Booking System)
 *   Implements the domain layer use case for retrieving all booking records,
 *   supporting the booking management feature by providing access to booking data.
 */
class GetBookingsUseCase @Inject constructor(
    private val bookingRepository: BookingRepository
) {
    /**
     * Retrieves all booking records by invoking the BookingRepository.
     *
     * Requirements addressed:
     * - Booking Management (1.3 Scope/Core Features/Booking System)
     *   Provides functionality to retrieve all booking records for listing
     *   and management purposes.
     *
     * @return List of all booking records as domain models
     */
    suspend fun getBookings(): List<Booking> {
        return bookingRepository.getAllBookings()
    }
}