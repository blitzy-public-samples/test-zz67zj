/**
 * Human Tasks:
 * 1. Ensure the database schema matches the User model properties
 * 2. Configure ProGuard rules to prevent obfuscation of this data class if using R8/ProGuard
 * 3. Verify that the email format validation matches the application requirements
 * 4. Ensure proper indexing is set up in the database for bookingIds and dogIds fields
 */

package com.dogwalker.app.domain.model

/**
 * Represents a user entity in the Dog Walker application.
 * 
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Implements the core user profile data structure containing essential details
 *   such as name, email, phone number, and associations with bookings, dogs, and walks.
 */
data class User(
    /**
     * Unique identifier for the user
     */
    val id: String,

    /**
     * Full name of the user
     */
    val name: String,

    /**
     * Email address of the user
     */
    val email: String,

    /**
     * Phone number of the user
     */
    val phoneNumber: String,

    /**
     * List of booking IDs associated with this user
     */
    val bookingIds: List<String>,

    /**
     * List of dog IDs owned by this user
     */
    val dogIds: List<String>,

    /**
     * List of walks associated with this user
     */
    val walks: List<Walk>
) {
    init {
        require(id.isNotBlank()) { "User ID cannot be blank" }
        require(name.isNotBlank()) { "User name cannot be blank" }
        require(email.matches(EMAIL_REGEX)) { "Invalid email format" }
        require(phoneNumber.matches(PHONE_REGEX)) { "Invalid phone number format" }
    }

    companion object {
        /**
         * Regular expression for validating email addresses
         */
        private val EMAIL_REGEX = Regex(
            "[a-zA-Z0-9+._%\\-]{1,256}" +
            "@" +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
            "(" +
            "\\." +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
            ")+"
        )

        /**
         * Regular expression for validating phone numbers
         * Supports formats: +1234567890, (123) 456-7890, 123-456-7890
         */
        private val PHONE_REGEX = Regex(
            "^(\\+\\d{1,3}( )?)?((\\(\\d{3}\\))|\\d{3})[- .]?\\d{3}[- .]?\\d{4}$"
        )

        /**
         * Maximum allowed length for a user's name
         */
        const val MAX_NAME_LENGTH = 100

        /**
         * Maximum allowed length for an email address
         */
        const val MAX_EMAIL_LENGTH = 254
    }
}

/**
 * Represents a walk entity containing details about a specific walk.
 * 
 * Requirements addressed:
 * - User Management (1.3 Scope/Core Features/User Management)
 *   Implements the walk data structure that tracks walk sessions
 *   associated with users.
 */
data class Walk(
    /**
     * Unique identifier for the walk
     */
    val id: String,

    /**
     * ID of the user associated with this walk
     */
    val userId: String,

    /**
     * Start time of the walk in ISO 8601 format
     */
    val startTime: String,

    /**
     * End time of the walk in ISO 8601 format
     */
    val endTime: String
) {
    init {
        require(id.isNotBlank()) { "Walk ID cannot be blank" }
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(startTime.isNotBlank()) { "Start time cannot be blank" }
        require(endTime.isNotBlank()) { "End time cannot be blank" }
        require(endTime > startTime) { "End time must be after start time" }
    }
}