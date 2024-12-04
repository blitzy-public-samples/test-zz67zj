/**
 * Human Tasks:
 * 1. Ensure the database schema matches the Booking model properties
 * 2. Configure ProGuard rules to prevent obfuscation of this data class if using R8/ProGuard
 * 3. Verify that the date/time format matches the API contract for walkDate and walkTime fields
 * 4. Ensure proper decimal precision configuration for paymentAmount in the database
 */

package com.dogwalker.app.domain.model

/**
 * Represents a booking entity in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Booking Management (1.3 Scope/Core Features/Booking System)
 *   Implements the core booking data structure containing all necessary associations
 *   including user, dog, walk, and payment details.
 */
data class Booking(
    /**
     * Unique identifier for the booking
     */
    val id: String,

    /**
     * ID of the user who created the booking
     */
    val userId: String,

    /**
     * Name of the user who created the booking
     */
    val userName: String,

    /**
     * ID of the dog to be walked
     */
    val dogId: String,

    /**
     * Name of the dog to be walked
     */
    val dogName: String,

    /**
     * Breed of the dog to be walked
     */
    val dogBreed: String,

    /**
     * Date of the scheduled walk (format: YYYY-MM-DD)
     */
    val walkDate: String,

    /**
     * Time of the scheduled walk (format: HH:mm)
     */
    val walkTime: String,

    /**
     * ID of the associated payment transaction
     */
    val paymentId: String,

    /**
     * Current status of the payment (e.g., "pending", "completed", "failed")
     */
    val paymentStatus: String,

    /**
     * Amount to be paid for the walk
     */
    val paymentAmount: Double,

    /**
     * Current status of the booking (e.g., "pending", "confirmed", "in_progress", "completed", "cancelled")
     */
    val status: String,

    /**
     * Unix timestamp of when the booking was created
     */
    val timestamp: Long
) {
    companion object {
        // Payment status constants
        const val PAYMENT_STATUS_PENDING = "pending"
        const val PAYMENT_STATUS_COMPLETED = "completed"
        const val PAYMENT_STATUS_FAILED = "failed"

        // Booking status constants
        const val STATUS_PENDING = "pending"
        const val STATUS_CONFIRMED = "confirmed"
        const val STATUS_IN_PROGRESS = "in_progress"
        const val STATUS_COMPLETED = "completed"
        const val STATUS_CANCELLED = "cancelled"
    }
}