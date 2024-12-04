/**
 * Human Tasks:
 * 1. Verify Room database configuration in the app's build.gradle file (version 2.5.0)
 * 2. Ensure proper database migration strategy is in place when modifying entity structure
 * 3. Configure ProGuard rules to prevent obfuscation of this entity class if using R8/ProGuard
 * 4. Verify that the decimal precision for paymentAmount matches the business requirements
 */

package com.dogwalker.app.data.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.dogwalker.app.domain.model.Booking

/**
 * Database entity representing a booking record in the Room database.
 * 
 * Requirements addressed:
 * - Booking System (1.3 Scope/Core Features/Booking System)
 *   Implements the database entity for storing and managing booking records,
 *   supporting CRUD operations for the booking management feature.
 */
@Entity(tableName = "bookings")
data class BookingEntity(
    @PrimaryKey
    val id: String,
    
    /**
     * User-related fields
     */
    val userId: String,
    val userName: String,
    
    /**
     * Dog-related fields
     */
    val dogId: String,
    val dogName: String,
    val dogBreed: String,
    
    /**
     * Walk schedule fields
     * walkDate format: YYYY-MM-DD
     * walkTime format: HH:mm
     */
    val walkDate: String,
    val walkTime: String,
    
    /**
     * Payment-related fields
     */
    val paymentId: String,
    val paymentStatus: String,
    val paymentAmount: Double,
    
    /**
     * Booking status and metadata
     */
    val status: String,
    val timestamp: Long
) {
    /**
     * Extension function to convert BookingEntity to domain model Booking
     */
    fun toDomainModel() = Booking(
        id = id,
        userId = userId,
        userName = userName,
        dogId = dogId,
        dogName = dogName,
        dogBreed = dogBreed,
        walkDate = walkDate,
        walkTime = walkTime,
        paymentId = paymentId,
        paymentStatus = paymentStatus,
        paymentAmount = paymentAmount,
        status = status,
        timestamp = timestamp
    )

    companion object {
        /**
         * Extension function to convert domain model Booking to BookingEntity
         */
        fun fromDomainModel(booking: Booking) = BookingEntity(
            id = booking.id,
            userId = booking.userId,
            userName = booking.userName,
            dogId = booking.dogId,
            dogName = booking.dogName,
            dogBreed = booking.dogBreed,
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