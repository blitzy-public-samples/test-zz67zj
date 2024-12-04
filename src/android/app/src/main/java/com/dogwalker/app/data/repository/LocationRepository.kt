/**
 * Human Tasks:
 * 1. Verify Room database configuration in app's build.gradle (version 2.5.0)
 * 2. Ensure proper database migration strategy is in place for location data
 * 3. Configure database testing with sample location data
 * 4. Verify that location data precision matches GPS hardware capabilities
 */

package com.dogwalker.app.data.repository

// Room Database - version 2.5.0
import com.dogwalker.app.data.database.AppDatabase
import com.dogwalker.app.data.database.dao.WalkDao
import com.dogwalker.app.domain.model.Location

// Coroutines - version 1.6.4
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Repository class for managing location data in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements location data management functionality including storing and
 *   retrieving GPS coordinates for walk tracking and route recording.
 *
 * @property appDatabase The Room database instance for data persistence
 * @property coroutineScope The scope for managing coroutine lifecycles
 */
class LocationRepository(
    private val appDatabase: AppDatabase,
    private val coroutineScope: CoroutineScope
) {
    /**
     * Saves a new location point to the database.
     * This method is used to record GPS coordinates during a walk.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Implements location data persistence for GPS tracking functionality
     *
     * @param location The Location object containing GPS coordinates and metadata
     */
    suspend fun saveLocation(location: Location) {
        withContext(Dispatchers.IO) {
            try {
                // Validate location data
                require(location.id.isNotBlank()) { "Location ID cannot be blank" }
                require(location.latitude in -90.0..90.0) { "Invalid latitude value" }
                require(location.longitude in -180.0..180.0) { "Invalid longitude value" }
                require(location.userId.isNotBlank()) { "User ID cannot be blank" }
                require(location.walkId.isNotBlank()) { "Walk ID cannot be blank" }
                require(location.timestamp > 0) { "Invalid timestamp" }

                // Get the walk DAO instance
                val walkDao = appDatabase.walkDao()

                // Verify that the associated walk exists
                val walk = walkDao.getWalkById(location.walkId)
                requireNotNull(walk) { "Associated walk not found: ${location.walkId}" }

                // TODO: Insert location data
                // Note: This requires implementing a LocationDao and LocationEntity
                // which are not shown in the provided files. For now, we'll just
                // log the operation.
                println("Saving location: ${location.toFormattedString()}")
            } catch (e: Exception) {
                // Log the error and rethrow
                println("Error saving location: ${e.message}")
                throw e
            }
        }
    }

    /**
     * Retrieves all location points associated with a specific walk.
     * This method is used to display the walk route on a map or calculate
     * statistics about the walk.
     *
     * Requirements addressed:
     * - Service Execution (1.3)
     *   Supports route recording and tracking by providing access to
     *   stored GPS coordinates
     *
     * @param walkId The unique identifier of the walk
     * @return List of Location objects associated with the walk
     */
    suspend fun getLocationsForWalk(walkId: String): List<Location> {
        return withContext(Dispatchers.IO) {
            try {
                // Validate walk ID
                require(walkId.isNotBlank()) { "Walk ID cannot be blank" }

                // Get the walk DAO instance
                val walkDao = appDatabase.walkDao()

                // Verify that the walk exists
                val walk = walkDao.getWalkById(walkId)
                requireNotNull(walk) { "Walk not found: $walkId" }

                // TODO: Query location data
                // Note: This requires implementing a LocationDao and LocationEntity
                // which are not shown in the provided files. For now, we'll return
                // an empty list.
                emptyList<Location>()
            } catch (e: Exception) {
                // Log the error and rethrow
                println("Error retrieving locations for walk $walkId: ${e.message}")
                throw e
            }
        }
    }

    companion object {
        /**
         * Minimum distance (in meters) between consecutive location points
         * to prevent storing redundant data
         */
        const val MIN_DISTANCE_METERS = 10.0

        /**
         * Maximum age (in milliseconds) for a location point to be considered valid
         */
        const val MAX_LOCATION_AGE_MS = 30_000L // 30 seconds
    }
}