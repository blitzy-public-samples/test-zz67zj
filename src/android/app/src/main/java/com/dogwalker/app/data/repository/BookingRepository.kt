/**
 * Human Tasks:
 * 1. Verify Room database configuration in app's build.gradle (version 2.5.0)
 * 2. Ensure proper error handling and logging is configured for database operations
 * 3. Verify that the database operations are performed on the appropriate coroutine dispatcher
 * 4. Configure unit tests for the repository methods with mock DAO
 */

package com.dogwalker.app.data.repository

import com.dogwalker.app.data.database.dao.BookingDao
import com.dogwalker.app.data.database.entity.BookingEntity
import com.dogwalker.app.domain.model.Booking
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository implementation for managing booking-related data operations.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the data layer for booking management, providing methods to
 *   create, retrieve, update, and delete booking records while handling
 *   the conversion between database entities and domain models.
 */
@Singleton
class BookingRepository @Inject constructor(
    private val bookingDao: BookingDao
) {
    /**
     * Retrieves all booking records from the database and maps them to domain models.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Supports retrieval of all booking records for listing and management purposes.
     *
     * @return List of all booking records as domain models
     */
    suspend fun getAllBookings(): List<Booking> {
        return bookingDao.getAllBookings().map { bookingEntity ->
            bookingEntity.toDomainModel()
        }
    }

    /**
     * Inserts a new booking record into the database.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Enables creation of new booking records in the system.
     *
     * @param booking The booking domain model to be inserted
     */
    suspend fun insertBooking(booking: Booking) {
        val bookingEntity = BookingEntity.fromDomainModel(booking)
        bookingDao.insertBooking(bookingEntity)
    }

    /**
     * Updates an existing booking record in the database.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Supports modification of existing booking records to reflect changes
     *   in status, schedule, or other details.
     *
     * @param booking The booking domain model containing updated information
     */
    suspend fun updateBooking(booking: Booking) {
        val bookingEntity = BookingEntity.fromDomainModel(booking)
        bookingDao.updateBooking(bookingEntity)
    }

    /**
     * Deletes a booking record from the database.
     *
     * Requirements addressed:
     * - Booking System (1.3 Scope/Core Features/Booking System)
     *   Enables removal of booking records from the system when cancelled
     *   or no longer needed.
     *
     * @param booking The booking domain model to be deleted
     */
    suspend fun deleteBooking(booking: Booking) {
        val bookingEntity = BookingEntity.fromDomainModel(booking)
        bookingDao.deleteBooking(bookingEntity)
    }
}