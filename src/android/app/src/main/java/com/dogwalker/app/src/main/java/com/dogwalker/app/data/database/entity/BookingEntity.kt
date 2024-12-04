package com.dogwalker.app.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.dogwalker.app.domain.model.Booking

/**
 * Human Tasks:
 * 1. Verify database indexing requirements for frequent queries on userId, dogId, and status fields
 * 2. Ensure proper database migration strategy when modifying the entity structure
 * 3. Configure appropriate database type affinity for timestamp field (INTEGER in SQLite)
 * 4. Set up database backup strategy for booking records
 */

/**
 * Database entity representing a booking record in the Room database.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the database schema for storing booking information, enabling
 *   persistent storage and retrieval of booking records.
 */
@Entity(tableName = "bookings")
data class BookingEntity(
    @PrimaryKey
    val id: String,
    
    /**
     * Reference to the user who created the booking
     */
    val userId: String,
    
    /**
     * Reference to the dog being walked
     */
    val dogId: String,
    
    /**
     * Scheduled date for the walk (format: YYYY-MM-DD)
     */
    val walkDate: String,
    
    /**
     * Scheduled time for the walk (format: HH:mm)
     */
    val walkTime: String,
    
    /**
     * Reference to the payment transaction
     */
    val paymentId: String,
    
    /**
     * Current payment status (pending, completed, failed)
     */
    val paymentStatus: String,
    
    /**
     * Amount to be paid for the walk service
     */
    val paymentAmount: Double,
    
    /**
     * Current booking status (pending, confirmed, in_progress, completed, cancelled)
     */
    val status: String,
    
    /**
     * Creation timestamp stored as Unix timestamp (milliseconds since epoch)
     */
    val timestamp: Long
) {
    /**
     * Converts this database entity to a domain model object
     */
    fun toDomainModel(): Booking {
        return Booking(
            id = id,
            userId = userId,
            userName = "", // Note: Not stored in database entity
            dogId = dogId,
            dogName = "", // Note: Not stored in database entity
            dogBreed = "", // Note: Not stored in database entity
            walkDate = walkDate,
            walkTime = walkTime,
            paymentId = paymentId,
            paymentStatus = paymentStatus,
            paymentAmount = paymentAmount,
            status = status,
            timestamp = timestamp
        )
    }

    companion object {
        /**
         * Creates a database entity from a domain model object
         */
        fun fromDomainModel(booking: Booking): BookingEntity {
            return BookingEntity(
                id = booking.id,
                userId = booking.userId,
                dogId = booking.dogId,
                walkDate = booking.walkDate,
                walkTime = booking.walkTime,
                paymentId = booking.paymentId,
                paymentStatus = booking.paymentStatus,
                paymentAmount = booking.paymentAmount,
                status = booking.status,
                timestamp = booking.timestamp
            )
        }
    }
}