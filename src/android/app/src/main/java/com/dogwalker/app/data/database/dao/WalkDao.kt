/**
 * Human Tasks:
 * 1. Verify Room database configuration in app's build.gradle (version 2.5.0)
 * 2. Ensure proper database migration strategy is in place when modifying DAO queries
 * 3. Configure database testing with sample walk data
 * 4. Verify that the database indices are optimized for the queries being performed
 */

package com.dogwalker.app.data.database.dao

// Room Database - version 2.5.0
import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import com.dogwalker.app.domain.model.Walk

/**
 * Data Access Object (DAO) interface for walk-related database operations.
 * 
 * Requirements addressed:
 * - Service Execution (1.3 Scope/Core Features/Service Execution)
 *   Implements database operations for managing walk data, including
 *   storing walk sessions, GPS tracking data, and route recording.
 */
@Dao
interface WalkDao {
    /**
     * Inserts a new walk record into the database.
     * If a walk with the same ID already exists, the transaction will fail.
     *
     * @param walk The Walk object to be inserted
     */
    @Insert
    suspend fun insertWalk(walk: Walk)

    /**
     * Retrieves a specific walk record by its ID.
     *
     * @param id The unique identifier of the walk to retrieve
     * @return The Walk object if found, null otherwise
     */
    @Query("SELECT * FROM Walk WHERE id = :id")
    suspend fun getWalkById(id: String): Walk?

    /**
     * Deletes a walk record from the database.
     * If the walk doesn't exist, the transaction will fail.
     *
     * @param walk The Walk object to be deleted
     */
    @Delete
    suspend fun deleteWalk(walk: Walk)
}