/**
 * Human Tasks:
 * 1. Verify that location permissions are properly configured in AndroidManifest.xml
 * 2. Ensure proper error handling and retry mechanisms are in place for location tracking
 * 3. Test location tracking accuracy and battery consumption in different scenarios
 * 4. Configure location update intervals based on battery optimization requirements
 */

package com.dogwalker.app.domain.usecase.location

// Internal imports
import com.dogwalker.app.data.repository.LocationRepository
import com.dogwalker.app.domain.model.Location
import com.dogwalker.app.service.LocationService

// Coroutines - version 1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Use case class that handles the business logic for tracking and managing live GPS location updates
 * during a walk in the Dog Walker application.
 *
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements live GPS tracking and route recording functionality for dog walking services,
 *   coordinating between the LocationService and LocationRepository.
 */
class TrackLocationUseCase(
    private val locationService: LocationService,
    private val locationRepository: LocationRepository
) {
    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    /**
     * Tracks the user's live location during a walk and saves it to the database.
     * This method coordinates between the LocationService for live tracking and
     * LocationRepository for data persistence.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Implements location tracking and storage functionality for walk monitoring
     *
     * @param walkId The unique identifier of the active walk session
     * @return Boolean indicating if location tracking was successfully started
     */
    suspend fun trackLocation(walkId: String): Boolean = withContext(Dispatchers.IO) {
        try {
            // Validate walkId
            require(walkId.isNotBlank()) { "Walk ID cannot be blank" }

            // Start location updates using LocationService
            val trackingStarted = locationService.startLocationUpdates(walkId)
            if (!trackingStarted) {
                return@withContext false
            }

            // Get the initial location
            val initialLocation = locationService.getLastKnownLocation()
            initialLocation?.let { location ->
                // Save the initial location to the repository
                try {
                    locationRepository.saveLocation(
                        Location(
                            id = location.id,
                            latitude = location.latitude,
                            longitude = location.longitude,
                            userId = location.userId,
                            walkId = walkId,
                            timestamp = System.currentTimeMillis()
                        )
                    )
                } catch (e: Exception) {
                    // Log error but continue tracking as this is just the initial location
                    println("Error saving initial location: ${e.message}")
                }
            }

            true
        } catch (e: Exception) {
            // Stop location updates if anything goes wrong
            locationService.stopLocationUpdates()
            println("Error starting location tracking: ${e.message}")
            false
        }
    }

    /**
     * Stops tracking the user's location for the current walk session.
     *
     * @return Boolean indicating if location tracking was successfully stopped
     */
    suspend fun stopTracking(): Boolean = withContext(Dispatchers.IO) {
        try {
            locationService.stopLocationUpdates()
            true
        } catch (e: Exception) {
            println("Error stopping location tracking: ${e.message}")
            false
        }
    }

    companion object {
        /**
         * Minimum distance (in meters) between consecutive location points
         * to prevent storing redundant data
         */
        private const val MIN_DISTANCE_METERS = 10.0

        /**
         * Maximum age (in milliseconds) for a location point to be considered valid
         */
        private const val MAX_LOCATION_AGE_MS = 30_000L // 30 seconds
    }
}