package com.dogwalker.app.domain.model

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit

/**
 * Human Tasks:
 * 1. Ensure the database schema matches the Walk model properties
 * 2. Configure ProGuard rules to prevent obfuscation of this data class if using R8/ProGuard
 * 3. Verify that the date/time format matches the API contract for startTime and endTime fields
 * 4. Ensure proper indexing is set up in the database for userId, dogId, and bookingId fields
 */

/**
 * Represents a walk entity in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the walk data structure that tracks walk sessions including
 *   user, dog, location, and time details.
 */
data class Walk(
    /**
     * Unique identifier for the walk
     */
    val id: String,

    /**
     * ID of the user (walker) associated with this walk
     */
    val userId: String,

    /**
     * ID of the dog being walked
     */
    val dogId: String,

    /**
     * ID of the booking associated with this walk
     */
    val bookingId: String,

    /**
     * List of location points recorded during the walk
     */
    val locations: List<Location>,

    /**
     * Start time of the walk in ISO 8601 format (yyyy-MM-dd'T'HH:mm:ss'Z')
     */
    val startTime: String,

    /**
     * End time of the walk in ISO 8601 format (yyyy-MM-dd'T'HH:mm:ss'Z')
     */
    val endTime: String,

    /**
     * Current status of the walk
     */
    val status: String
) {
    init {
        require(id.isNotBlank()) { "Walk ID cannot be blank" }
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(dogId.isNotBlank()) { "Dog ID cannot be blank" }
        require(bookingId.isNotBlank()) { "Booking ID cannot be blank" }
        require(startTime.isNotBlank()) { "Start time cannot be blank" }
        require(endTime.isNotBlank()) { "End time cannot be blank" }
        require(status in VALID_STATUSES) { "Invalid walk status: $status" }
    }

    /**
     * Calculates the duration of the walk based on start and end times.
     * 
     * @return Duration of the walk in a human-readable format (e.g., "1 hour 30 minutes")
     */
    fun calculateDuration(): String {
        val dateFormat = SimpleDateFormat(DATE_FORMAT, Locale.getDefault())
        
        val start = dateFormat.parse(startTime) ?: return "Invalid duration"
        val end = dateFormat.parse(endTime) ?: return "Invalid duration"
        
        val durationMillis = end.time - start.time
        val hours = TimeUnit.MILLISECONDS.toHours(durationMillis)
        val minutes = TimeUnit.MILLISECONDS.toMinutes(durationMillis) % 60

        return when {
            hours > 0 && minutes > 0 -> "$hours hour${if (hours > 1) "s" else ""} $minutes minute${if (minutes > 1) "s" else ""}"
            hours > 0 -> "$hours hour${if (hours > 1) "s" else ""}"
            minutes > 0 -> "$minutes minute${if (minutes > 1) "s" else ""}"
            else -> "Less than a minute"
        }
    }

    companion object {
        /**
         * Valid walk status values
         */
        val VALID_STATUSES = setOf(
            "scheduled",
            "in_progress",
            "completed",
            "cancelled",
            "paused"
        )

        /**
         * Date format pattern for time fields
         */
        const val DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        /**
         * Maximum allowed duration for a single walk in hours
         */
        const val MAX_DURATION_HOURS = 4

        /**
         * Minimum allowed duration for a single walk in minutes
         */
        const val MIN_DURATION_MINUTES = 30
    }
}