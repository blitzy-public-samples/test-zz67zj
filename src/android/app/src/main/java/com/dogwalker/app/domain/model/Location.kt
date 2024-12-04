/**
 * Human Tasks:
 * 1. Ensure the database schema matches the Location model properties
 * 2. Configure ProGuard rules to prevent obfuscation of this data class if using R8/ProGuard
 * 3. Verify that the precision of latitude and longitude matches the GPS hardware capabilities
 * 4. Ensure proper indexing is set up in the database for userId and walkId fields
 */

package com.dogwalker.app.domain.model

/**
 * Represents a location entity in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the location data structure for GPS tracking and route recording
 *   during dog walks, containing coordinates, timestamps, and associated IDs.
 */
data class Location(
    /**
     * Unique identifier for the location point
     */
    val id: String,

    /**
     * Latitude coordinate in decimal degrees
     */
    val latitude: Double,

    /**
     * Longitude coordinate in decimal degrees
     */
    val longitude: Double,

    /**
     * ID of the user associated with this location point
     */
    val userId: String,

    /**
     * ID of the walk associated with this location point
     */
    val walkId: String,

    /**
     * Unix timestamp when this location was recorded
     */
    val timestamp: Long
) {
    init {
        require(id.isNotBlank()) { "Location ID cannot be blank" }
        require(latitude in -90.0..90.0) { "Latitude must be between -90 and 90 degrees" }
        require(longitude in -180.0..180.0) { "Longitude must be between -180 and 180 degrees" }
        require(userId.isNotBlank()) { "User ID cannot be blank" }
        require(walkId.isNotBlank()) { "Walk ID cannot be blank" }
        require(timestamp > 0) { "Timestamp must be positive" }
    }

    /**
     * Formats the location coordinates into a human-readable string.
     * 
     * @return A formatted string containing the latitude and longitude values.
     */
    fun toFormattedString(): String {
        return String.format(
            "%.6f°%s, %.6f°%s",
            kotlin.math.abs(latitude),
            if (latitude >= 0) "N" else "S",
            kotlin.math.abs(longitude),
            if (longitude >= 0) "E" else "W"
        )
    }

    companion object {
        /**
         * Maximum precision for coordinate values
         */
        const val COORDINATE_PRECISION = 6

        /**
         * Earth's radius in meters (used for distance calculations)
         */
        const val EARTH_RADIUS_METERS = 6371000.0
    }
}