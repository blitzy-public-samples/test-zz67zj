/**
 * Human Tasks:
 * 1. Verify coroutine scope configuration in the dependency injection setup
 * 2. Ensure proper error handling is implemented in the UI layer for location tracking failures
 * 3. Configure location permission handling in the UI layer before calling these methods
 * 4. Verify GPS accuracy settings match the application requirements
 */

package com.dogwalker.app.domain.usecase.walk

// Internal imports
import com.dogwalker.app.domain.model.Walk
import com.dogwalker.app.domain.model.Location
import com.dogwalker.app.data.repository.WalkRepository
import com.dogwalker.app.data.repository.LocationRepository

// Coroutines - version 1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Use case class that provides business logic for tracking a walk in real-time.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements live GPS tracking and route recording functionality for walks,
 *   providing methods to save location updates and retrieve walk routes.
 */
class TrackWalkUseCase(
    private val walkRepository: WalkRepository,
    private val locationRepository: LocationRepository
) {
    /**
     * Tracks the current location of a walk by saving the location data to the database.
     * This method should be called periodically during an active walk to record the route.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Implements real-time GPS tracking by saving location updates during walks
     *
     * @param walkId Unique identifier of the walk being tracked
     * @param latitude Current latitude coordinate
     * @param longitude Current longitude coordinate
     * @param timestamp Unix timestamp when the location was recorded
     */
    suspend fun trackLocation(
        walkId: String,
        latitude: Double,
        longitude: Double,
        timestamp: Long
    ) {
        withContext(Dispatchers.IO) {
            try {
                // Validate input parameters
                require(walkId.isNotBlank()) { "Walk ID cannot be blank" }
                require(latitude in -90.0..90.0) { "Invalid latitude value" }
                require(longitude in -180.0..180.0) { "Invalid longitude value" }
                require(timestamp > 0) { "Invalid timestamp" }

                // Retrieve the walk entity
                val walk = walkRepository.getWalkById(walkId)
                requireNotNull(walk) { "Walk not found: $walkId" }

                // Create a new location object
                val location = Location(
                    id = "${walkId}_${timestamp}",
                    latitude = latitude,
                    longitude = longitude,
                    userId = walk.userId,
                    walkId = walkId,
                    timestamp = timestamp
                )

                // Save the location to the database
                locationRepository.saveLocation(location)

                // Update the walk's location list
                val updatedLocations = walk.locations + location
                val updatedWalk = walk.copy(locations = updatedLocations)
                walkRepository.insertWalk(updatedWalk)
            } catch (e: Exception) {
                // Log the error and rethrow
                println("Error tracking location for walk $walkId: ${e.message}")
                throw e
            }
        }
    }

    /**
     * Retrieves the complete route of a walk by fetching all associated location data.
     * This method can be used to display the walk route on a map or calculate statistics.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Supports route recording by providing access to the complete walk route
     *
     * @param walkId Unique identifier of the walk
     * @return List of Location objects representing the walk's route
     */
    suspend fun getRoute(walkId: String): List<Location> {
        return withContext(Dispatchers.IO) {
            try {
                // Validate walk ID
                require(walkId.isNotBlank()) { "Walk ID cannot be blank" }

                // Verify that the walk exists
                val walk = walkRepository.getWalkById(walkId)
                requireNotNull(walk) { "Walk not found: $walkId" }

                // Retrieve all locations for the walk
                locationRepository.getLocationsForWalk(walkId)
            } catch (e: Exception) {
                // Log the error and rethrow
                println("Error retrieving route for walk $walkId: ${e.message}")
                throw e
            }
        }
    }

    companion object {
        /**
         * Minimum time interval (in milliseconds) between location updates
         */
        const val MIN_UPDATE_INTERVAL_MS = 5000L // 5 seconds

        /**
         * Maximum time interval (in milliseconds) between location updates
         */
        const val MAX_UPDATE_INTERVAL_MS = 30000L // 30 seconds
    }
}