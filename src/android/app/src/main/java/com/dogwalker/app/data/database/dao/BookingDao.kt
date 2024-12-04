/**
 * Human Tasks:
 * 1. Verify Room database configuration in the app's build.gradle file (version 2.5.0)
 * 2. Ensure proper database migration strategy is in place when modifying DAO queries
 * 3. Verify that the database indexes are optimized for the queries being performed
 * 4. Configure ProGuard rules to prevent obfuscation of this interface if using R8/ProGuard
 */

package com.dogwalker.app.data.database.dao

import androidx.room.Dao // Room version: 2.5.0
import androidx.room.Delete // Room version: 2.5.0
import androidx.room.Insert // Room version: 2.5.0
import androidx.room.Query // Room version: 2.5.0
import androidx.room.Update // Room version: 2.5.0
import com.dogwalker.app.data.database.entity.BookingEntity

/**
 * Data Access Object (DAO) interface for booking-related database operations.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the database access layer for booking management, providing
 *   methods for creating, retrieving, updating, and deleting booking records.
 */
@Dao
interface BookingDao {
    /**
     * Retrieves all booking records from the database.
     * The records are returned in the form of BookingEntity objects which can be
     * converted to domain models using the toDomainModel() extension function.
     *
     * @return List of all booking records stored in the database
     */
    @Query("SELECT * FROM bookings")
    suspend fun getAllBookings(): List<BookingEntity>

    /**
     * Inserts a new booking record into the database.
     * If a booking with the same ID already exists, the transaction will fail.
     *
     * @param booking The BookingEntity object to be inserted into the database
     */
    @Insert
    suspend fun insertBooking(booking: BookingEntity)

    /**
     * Updates an existing booking record in the database.
     * The booking is identified by its primary key (id).
     *
     * @param booking The BookingEntity object containing updated information
     */
    @Update
    suspend fun updateBooking(booking: BookingEntity)

    /**
     * Deletes a booking record from the database.
     * The booking is identified by its primary key (id).
     *
     * @param booking The BookingEntity object to be deleted from the database
     */
    @Delete
    suspend fun deleteBooking(booking: BookingEntity)
}