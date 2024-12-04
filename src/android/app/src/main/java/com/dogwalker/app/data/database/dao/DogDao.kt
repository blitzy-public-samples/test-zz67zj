package com.dogwalker.app.data.database.dao

import androidx.room.Dao // Room version: 2.5.0
import androidx.room.Delete // Room version: 2.5.0
import androidx.room.Insert // Room version: 2.5.0
import androidx.room.Query // Room version: 2.5.0
import com.dogwalker.app.data.database.entity.DogEntity

/**
 * Human Tasks:
 * 1. Verify that Room database configuration includes this DAO in the database builder
 * 2. Ensure proper database migration strategy is in place for schema changes
 * 3. Consider adding indices on frequently queried columns in the database
 * 4. Implement proper error handling for database operations at the repository layer
 */

/**
 * Data Access Object interface for dog-related database operations.
 *
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Provides database operations for managing dog profiles including
 *   retrieval, insertion, and deletion of dog records.
 */
@Dao
interface DogDao {
    /**
     * Retrieves all dogs stored in the database.
     *
     * @return List of all DogEntity objects in the database
     */
    @Query("SELECT * FROM dogs")
    suspend fun getAllDogs(): List<DogEntity>

    /**
     * Inserts a new dog record into the database.
     * If a dog with the same ID already exists, the operation will fail.
     *
     * @param dogEntity The dog entity to be inserted
     */
    @Insert
    suspend fun insertDog(dogEntity: DogEntity)

    /**
     * Deletes a specific dog record from the database.
     *
     * @param dogEntity The dog entity to be deleted
     */
    @Delete
    suspend fun deleteDog(dogEntity: DogEntity)
}