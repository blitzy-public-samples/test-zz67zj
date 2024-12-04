/**
 * Human Tasks:
 * 1. Verify Room database configuration in app's build.gradle (version 2.5.0)
 * 2. Ensure proper error handling is implemented in the UI layer for database operations
 * 3. Configure database testing with sample walk data
 * 4. Verify that the database indices are optimized for walk-related queries
 */

package com.dogwalker.app.data.repository

// Room Database - version 2.5.0
import com.dogwalker.app.data.database.dao.WalkDao
import com.dogwalker.app.domain.model.Walk

/**
 * Repository class that provides an abstraction layer for managing walk-related data operations.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements the data layer for managing walk sessions, providing methods for
 *   persisting and retrieving walk data including GPS tracking and route recording.
 */
class WalkRepository(
    private val walkDao: WalkDao
) {
    /**
     * Inserts a new walk record into the database.
     * 
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Handles the persistence of walk data when a new walk session is started
     *   or updated during the walk.
     *
     * @param walk The Walk object to be inserted
     */
    suspend fun insertWalk(walk: Walk) {
        require(walk.id.isNotBlank()) { "Walk ID cannot be blank" }
        require(walk.userId.isNotBlank()) { "User ID cannot be blank" }
        require(walk.dogId.isNotBlank()) { "Dog ID cannot be blank" }
        require(walk.bookingId.isNotBlank()) { "Booking ID cannot be blank" }
        require(walk.startTime.isNotBlank()) { "Start time cannot be blank" }
        require(walk.endTime.isNotBlank()) { "End time cannot be blank" }
        require(walk.status in Walk.VALID_STATUSES) { "Invalid walk status: ${walk.status}" }

        walkDao.insertWalk(walk)
    }

    /**
     * Retrieves a walk record by its ID from the database.
     * 
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Enables retrieval of walk data for displaying walk details, tracking
     *   progress, and managing walk status.
     *
     * @param id The unique identifier of the walk to retrieve
     * @return The Walk object if found, null otherwise
     */
    suspend fun getWalkById(id: String): Walk? {
        require(id.isNotBlank()) { "Walk ID cannot be blank" }
        return walkDao.getWalkById(id)
    }

    /**
     * Deletes a walk record from the database.
     * 
     * Requirements addressed:
     * - Service Execution (1.3 Scope/Core Features/Service Execution)
     *   Supports the removal of walk data when needed, such as for cancelled
     *   walks or data cleanup operations.
     *
     * @param walk The Walk object to be deleted
     */
    suspend fun deleteWalk(walk: Walk) {
        require(walk.id.isNotBlank()) { "Walk ID cannot be blank" }
        walkDao.deleteWalk(walk)
    }
}